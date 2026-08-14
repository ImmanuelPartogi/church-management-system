<?php

namespace Tests\Feature\Services;

use App\Models\DeviceToken;
use App\Models\User;
use App\Services\Notifications\FcmNotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
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

    public function test_broadcast_sends_to_all_registered_device_tokens(): void
    {
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();

        DeviceToken::create([
            'user_id' => $user1->id,
            'token' => 'token-user-1',
            'platform' => 'android',
        ]);

        DeviceToken::create([
            'user_id' => $user2->id,
            'token' => 'token-user-2',
            'platform' => 'android',
        ]);

        $messagingMock = Mockery::mock(Messaging::class);
        $messagingMock->shouldReceive('send')
            ->twice()
            ->andReturn([]);

        $service = new FcmNotificationService($messagingMock);

        $count = $service->broadcast('Judul Broadcast', 'Body Broadcast');

        $this->assertEquals(2, $count);
    }

    public function test_gracefully_handles_unbound_messaging_service(): void
    {
        $service = new FcmNotificationService(null);

        $result = $service->sendToToken('token-123', 'Judul', 'Body');

        $this->assertFalse($result);
    }
}
