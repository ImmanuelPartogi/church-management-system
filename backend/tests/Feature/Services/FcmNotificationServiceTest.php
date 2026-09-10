<?php

namespace Tests\Feature\Services;

use App\Models\Church;
use App\Models\ChurchUserMembership;
use App\Models\DeviceToken;
use App\Models\User;
use App\Services\Notifications\FcmNotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Kreait\Firebase\Contract\Messaging;
use Mockery;
use Tests\TestCase;

class FcmNotificationServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_send_to_token_invokes_messaging_contract(): void
    {
        $messagingMock = Mockery::mock(Messaging::class);
        $messagingMock->shouldReceive('send')
            ->once()
            ->andReturn([]);

        $service = new FcmNotificationService($messagingMock);

        $result = $service->sendToToken(
            'target-token-123',
            'Judul Pengumuman',
            'Isi pengumuman gereja',
            ['route' => '/announcements']
        );

        $this->assertTrue($result);
    }

    public function test_broadcast_sends_only_to_active_members_of_specified_church(): void
    {
        /** @var Church $churchA */
        $churchA = app('current_church');
        $churchB = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Sudirman',
            'slug' => 'hkbp-sudirman',
            'status' => 'active',
        ]);

        // User 1 is active member in Church A (default from factory)
        $user1 = User::factory()->create();

        // User 2 belongs ONLY to Church B
        $user2 = User::factory()->create();
        $user2->memberships()->delete();
        ChurchUserMembership::create([
            'user_id' => $user2->id,
            'church_id' => $churchB->id,
            'role' => 'member',
            'status' => 'active',
            'joined_at' => now(),
        ]);

        // User 3 belongs to Church A but has inactive/pending status
        $user3 = User::factory()->create();
        $user3->memberships()->delete();
        ChurchUserMembership::create([
            'user_id' => $user3->id,
            'church_id' => $churchA->id,
            'role' => 'member',
            'status' => 'pending',
            'joined_at' => now(),
        ]);

        DeviceToken::create([
            'user_id' => $user1->id,
            'token' => 'token-user-1-church-a',
            'platform' => 'android',
        ]);

        DeviceToken::create([
            'user_id' => $user2->id,
            'token' => 'token-user-2-church-b',
            'platform' => 'android',
        ]);

        DeviceToken::create([
            'user_id' => $user3->id,
            'token' => 'token-user-3-church-a-pending',
            'platform' => 'android',
        ]);

        $messagingMock = Mockery::mock(Messaging::class);
        // Expect ONLY 1 send call for token-user-1-church-a
        $messagingMock->shouldReceive('send')
            ->once()
            ->andReturn([]);

        $service = new FcmNotificationService($messagingMock);

        // Broadcast specifically for Church A
        $count = $service->broadcast(
            'Judul Broadcast HKBP Bandung',
            'Body Broadcast',
            [],
            churchId: $churchA->id
        );

        // Only User 1 should receive the notification!
        $this->assertEquals(1, $count);
    }

    public function test_broadcast_falls_back_to_current_church_id_bound_in_container(): void
    {
        $churchA = app('current_church');
        $user = User::factory()->create();

        DeviceToken::create([
            'user_id' => $user->id,
            'token' => 'token-user-default-church',
            'platform' => 'android',
        ]);

        $messagingMock = Mockery::mock(Messaging::class);
        $messagingMock->shouldReceive('send')
            ->once()
            ->andReturn([]);

        $service = new FcmNotificationService($messagingMock);

        // Call broadcast without passing churchId parameter; should use app('current_church_id')
        $count = $service->broadcast('Judul Default', 'Body Default');

        $this->assertEquals(1, $count);
    }

    public function test_broadcast_fails_loudly_when_no_church_context_available(): void
    {
        // Unbind current_church_id
        app()->forgetInstance('current_church_id');

        $service = new FcmNotificationService(null);

        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Church ID is required to broadcast notifications.');

        $service->broadcast('Judul', 'Body');
    }

    public function test_gracefully_handles_unbound_messaging_service(): void
    {
        $service = new FcmNotificationService(null);

        $result = $service->sendToToken('token-123', 'Judul', 'Body');

        $this->assertFalse($result);
    }
}
