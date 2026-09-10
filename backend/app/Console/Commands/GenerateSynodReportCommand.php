<?php

namespace App\Console\Commands;

use App\Jobs\GenerateSynodReportSnapshotJob;
use Illuminate\Console\Command;

class GenerateSynodReportCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'synod:generate-report
                            {--sync : Execute the report snapshot calculation synchronously}
                            {--period= : Specific period date for the snapshot (YYYY-MM-DD)}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Generate an aggregated synod-wide report snapshot across all tenant churches';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $period = $this->option('period');
        $isSync = (bool) $this->option('sync');

        $this->info('Dispatching Synod report snapshot generation...');

        if ($isSync) {
            GenerateSynodReportSnapshotJob::dispatchSync($period);
            $this->info('Synod report snapshot generated successfully (sync).');
        } else {
            GenerateSynodReportSnapshotJob::dispatch($period);
            $this->info('Synod report snapshot generation job pushed to queue.');
        }

        return self::SUCCESS;
    }
}
