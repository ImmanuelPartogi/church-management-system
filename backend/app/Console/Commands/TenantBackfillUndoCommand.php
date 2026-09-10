<?php

namespace App\Console\Commands;

use App\Services\Tenant\TenantBackfillService;
use Illuminate\Console\Command;

class TenantBackfillUndoCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'tenant:backfill-undo {--force : Force execution without confirmation}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Revert tenant data backfill (resets church_id to NULL, purges default church, modules, and memberships)';

    /**
     * Execute the console command.
     */
    public function handle(TenantBackfillService $service): int
    {
        $this->warn('========================================================================');
        $this->warn(' TENANT BACKFILL: UNDO / REVERT OPERATION');
        $this->warn('========================================================================');

        if (! $this->option('force') && ! $this->confirm('Are you sure you want to revert all backfilled tenant data? This will set church_id = NULL on all records linked to default church and remove seeded memberships.')) {
            $this->info('Operation cancelled.');

            return self::SUCCESS;
        }

        $result = $service->executeUndo();

        $this->info("\n--- UNDO EXECUTION SUMMARY ---");
        $this->line("Super Admins Reset       : {$result['reset_super_admins']}");
        $this->line("Memberships Deleted      : {$result['deleted_memberships']}");
        $this->line("Church Modules Deleted   : {$result['deleted_church_modules']}");
        $this->line("Modules Deleted          : {$result['deleted_modules']}");

        $this->info("\n--- 16 DOMAIN TABLES REVERTED ---");
        $tableData = [];
        foreach ($result['tables_reverted'] as $table => $count) {
            $tableData[] = [$table, $count];
        }
        $this->table(['Domain Table', 'church_id Rows Reset to NULL'], $tableData);

        $this->info("\n[SUCCESS] Tenant data backfill reverted cleanly! Database restored to pre-backfill state.");

        return self::SUCCESS;
    }
}
