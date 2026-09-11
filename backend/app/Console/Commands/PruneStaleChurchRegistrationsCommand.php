<?php

namespace App\Console\Commands;

use App\Services\Registration\ChurchRegistrationService;
use Illuminate\Console\Command;

class PruneStaleChurchRegistrationsCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'church-registrations:prune-stale
                            {--days=7 : Number of days before an unverified registration is pruned}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Prune abandoned unverified church registrations older than 7 days to release held slugs';

    /**
     * Execute the console command.
     */
    public function handle(ChurchRegistrationService $service): int
    {
        $days = (int) $this->option('days');

        if ($days < 1) {
            $this->error('The --days option must be at least 1.');

            return self::FAILURE;
        }

        $this->info("Scanning for unverified church registrations older than {$days} days...");

        $count = $service->pruneStaleUnverified($days);

        $this->info("Successfully pruned {$count} stale unverified church registration(s).");

        return self::SUCCESS;
    }
}
