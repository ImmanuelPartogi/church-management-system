<?php

namespace App\Jobs;

use App\Contracts\Queue\TenantAwareJob;
use App\Models\Announcement;
use App\Services\Notifications\FcmNotificationService;
use App\Traits\Queue\TenantAwareJobTrait;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;

/**
 * Background job to broadcast church announcement push notifications
 * strictly scoped to active members of the tenant.
 */
class SendChurchAnnouncementBroadcastJob implements ShouldQueue, TenantAwareJob
{
    use Queueable, TenantAwareJobTrait;

    /**
     * The number of times the job may be attempted before failing.
     */
    public int $tries = 3;

    /**
     * The number of seconds to wait before retrying the job (exponential backoff).
     *
     * @var array<int, int>
     */
    public array $backoff = [15, 60, 300];

    /**
     * Delete the job if its associated models no longer exist.
     */
    public bool $deleteWhenMissingModels = true;

    public function __construct(
        public int $announcementId,
        public string $title,
        public string $body,
        public string $route,
        int $churchId
    ) {
        $this->churchId = $churchId;
    }

    /**
     * Execute the job.
     */
    public function handle(FcmNotificationService $fcmService): void
    {
        Log::info("Executing SendChurchAnnouncementBroadcastJob for announcement [{$this->announcementId}] in church [{$this->churchId}].");

        $announcement = Announcement::find($this->announcementId);

        $count = $fcmService->broadcast(
            $this->title,
            $this->body,
            [
                'type' => 'announcement',
                'entity_id' => (string) $this->announcementId,
                'route' => $this->route,
            ],
            churchId: $this->churchId
        );

        Log::info("Broadcast completed for announcement [{$this->announcementId}]. Sent to {$count} devices in church [{$this->churchId}].");
    }

    /**
     * Handle a job failure after all retries are exhausted.
     * The failure is permanently recorded in failed_jobs table and logged with tenant context.
     */
    public function failed(?\Throwable $exception): void
    {
        Log::error("SendChurchAnnouncementBroadcastJob permanently failed for announcement [{$this->announcementId}] in church [{$this->churchId}]: {$exception?->getMessage()}");
    }
}
