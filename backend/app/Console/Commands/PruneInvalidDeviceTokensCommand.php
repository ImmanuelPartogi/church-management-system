<?php

namespace App\Console\Commands;

use App\Models\DeviceToken;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class PruneInvalidDeviceTokensCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'device-tokens:prune
                            {--days=60 : Days of inactivity before a token is considered stale}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Prune inactive or obsolete FCM device tokens older than the threshold';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $days = (int) $this->option('days');

        if ($days < 1) {
            $this->error('The --days option must be at least 1.');

            return self::FAILURE;
        }

        $cutoff = now()->subDays($days);

        $this->info("Scanning for stale device tokens inactive since {$cutoff->toDateTimeString()} ({$days} days)...");

        $count = DeviceToken::where(function ($query) use ($cutoff) {
            $query->where('last_used_at', '<', $cutoff)
                ->orWhere(function ($q) use ($cutoff) {
                    $q->whereNull('last_used_at')
                        ->where('created_at', '<', $cutoff);
                })
                ->orWhere(function ($q) use ($cutoff) {
                    $q->where('is_active', false)
                        ->where('updated_at', '<', $cutoff);
                });
        })->delete();

        $this->info("Successfully pruned {$count} stale device token(s).");
        Log::info("PruneInvalidDeviceTokensCommand: Pruned {$count} stale device tokens older than {$days} days.");

        return self::SUCCESS;
    }
}
