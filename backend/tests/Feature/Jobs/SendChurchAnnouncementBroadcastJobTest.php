<?php

namespace Tests\Feature\Jobs;

use App\Contracts\Queue\TenantAwareJob;
use App\Jobs\Middleware\ScopeJobToTenant;
use App\Jobs\SendChurchAnnouncementBroadcastJob;
use App\Models\Announcement;
use App\Models\Church;
use App\Models\DeviceToken;
use App\Models\User;
use App\Services\Notifications\FcmNotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Str;
use Kreait\Firebase\Contract\Messaging;
use Mockery;
use Tests\TestCase;

class SendChurchAnnouncementBroadcastJobTest extends TestCase
{
    use RefreshDatabase;

    public function test_job_implements_tenant_aware_job_contract(): void
    {
        $job = new SendChurchAnnouncementBroadcastJob(
            announcementId: 10,
            title: 'Test Title',
            body: 'Test Body',
            route: '/announcements/10',
            churchId: 99
        );

        $this->assertInstanceOf(TenantAwareJob::class, $job);
        $this->assertEquals(99, $job->getChurchId());

        $middleware = $job->middleware();
        $this->assertCount(1, $middleware);
        $this->assertInstanceOf(ScopeJobToTenant::class, $middleware[0]);
    }

    public function test_job_has_retry_policy_and_failed_hook_logging(): void
    {
        $job = new SendChurchAnnouncementBroadcastJob(
            announcementId: 10,
            title: 'Test Title',
            body: 'Test Body',
            route: '/announcements/10',
            churchId: 99
        );

        $this->assertEquals(3, $job->tries);
        $this->assertEquals([15, 60, 300], $job->backoff);
        $this->assertTrue($job->deleteWhenMissingModels);

        Log::shouldReceive('error')
            ->once()
            ->with(Mockery::pattern('/SendChurchAnnouncementBroadcastJob permanently failed for announcement \[10\] in church \[99\]/'));

        $job->failed(new \RuntimeException('Firebase connection timeout'));
    }

    public function test_job_execution_sends_broadcast_only_to_tenant_members(): void
    {
        /** @var Church $churchA */
        $churchA = app('current_church');
        $churchB = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Pematang Siantar',
            'slug' => 'hkbp-pematang-siantar',
            'status' => 'active',
        ]);

        $announcement = Announcement::create([
            'title' => 'Warta Khusus',
            'content' => 'Isi warta khusus jemaat A',
            'published_at' => now(),
            'church_id' => $churchA->id,
        ]);

        // Member of Church A
        $userA = User::factory()->create();
        DeviceToken::create([
            'user_id' => $userA->id,
            'token' => 'token-device-a',
            'platform' => 'android',
        ]);

        // Member of Church B
        $userB = User::factory()->create();
        $userB->memberships()->delete();
        $userB->memberships()->create([
            'church_id' => $churchB->id,
            'role' => 'member',
            'status' => 'active',
            'joined_at' => now(),
        ]);
        DeviceToken::create([
            'user_id' => $userB->id,
            'token' => 'token-device-b',
            'platform' => 'android',
        ]);

        $messagingMock = Mockery::mock(Messaging::class);
        // Expect only 1 send call for token-device-a
        $messagingMock->shouldReceive('send')
            ->once()
            ->andReturn([]);

        $fcmService = new FcmNotificationService($messagingMock);

        $job = new SendChurchAnnouncementBroadcastJob(
            announcementId: $announcement->id,
            title: 'Warta Khusus',
            body: 'Isi warta khusus jemaat A',
            route: '/announcements/'.$announcement->id,
            churchId: $churchA->id
        );

        // Run through queue middleware
        $middleware = new ScopeJobToTenant;
        $middleware->handle($job, fn ($j) => $j->handle($fcmService));

        // After job execution, context must be clean
        $this->assertFalse(app()->bound('current_church_id'));
    }

    public function test_dispatching_job_to_queue(): void
    {
        Queue::fake();

        SendChurchAnnouncementBroadcastJob::dispatch(
            announcementId: 5,
            title: 'Queued Announcement',
            body: 'Queued Body',
            route: '/announcements/5',
            churchId: 1
        );

        Queue::assertPushed(SendChurchAnnouncementBroadcastJob::class, function ($job) {
            return $job->announcementId === 5
                && $job->getChurchId() === 1
                && $job->title === 'Queued Announcement';
        });
    }
}
