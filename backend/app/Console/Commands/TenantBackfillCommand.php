<?php

namespace App\Console\Commands;

use App\Services\Tenant\TenantBackfillService;
use Illuminate\Console\Command;

class TenantBackfillCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'tenant:backfill {--dry-run : Display pre-flight report without writing to database}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Backfill tenant context (churches, modules, church_user_memberships, church_id) to all domain records';

    /**
     * Execute the console command.
     */
    public function handle(TenantBackfillService $service): int
    {
        $dryRun = (bool) $this->option('dry-run');

        $this->info('========================================================================');
        $this->info($dryRun ? ' TENANT BACKFILL: PRE-FLIGHT AUDIT REPORT (--dry-run)' : ' TENANT BACKFILL: EXECUTING TENANT DATA BACKFILL');
        $this->info('========================================================================');

        if ($dryRun) {
            $snapshot = $service->getPreflightSnapshot();
            $this->renderSnapshotTables($snapshot);

            $this->warn("\n[DRY RUN COMPLETE] No records were modified or created in the database.");
            $this->line('To execute the real backfill, run: php artisan tenant:backfill');

            return self::SUCCESS;
        }

        $this->warn('Running backfill in REAL mode...');
        $result = $service->executeBackfill(false);

        $this->info("\n--- BACKFILL EXECUTION SUMMARY ---");
        $this->line("Default Church ID        : {$result['default_church_id']}");
        $this->line("Modules Seeded           : {$result['modules_seeded']}");
        $this->line("Church Modules Enabled   : {$result['church_modules_enabled']}");
        $this->line("Super Admins Flagged     : {$result['super_admins_set']}");
        $this->line("Memberships Created      : {$result['memberships_created']}");
        $this->line("Memberships Skipped      : {$result['memberships_skipped']}");

        $this->info("\n--- 16 DOMAIN TABLES UPDATED ---");
        $tableData = [];
        foreach ($result['tables_updated'] as $table => $count) {
            $tableData[] = [$table, $count];
        }
        $this->table(['Domain Table', 'church_id Rows Updated'], $tableData);

        $this->info("\n[SUCCESS] Tenant data backfill completed successfully!");

        return self::SUCCESS;
    }

    /**
     * Render rich terminal tables from preflight snapshot.
     *
     * @param  array<string, mixed>  $snapshot
     */
    protected function renderSnapshotTables(array $snapshot): void
    {
        // 1. Default Church Info
        $this->info("\n1. TARGET DEFAULT CHURCH");
        $this->table(
            ['Property', 'Value'],
            [
                ['Name', $snapshot['default_church']['name'].' [NEEDS BUSINESS DECISION]'],
                ['Slug', $snapshot['default_church']['slug']],
                ['Status', $snapshot['default_church']['status']],
                ['Timezone', $snapshot['default_church']['timezone']],
            ]
        );

        // 2. Domain Tables Status
        $this->info("\n2. DOMAIN TABLES STATUS (16 CHURCH-SCOPED TABLES)");
        $domainRows = [];
        foreach ($snapshot['domain_tables'] as $table => $data) {
            $domainRows[] = [
                $table,
                $data['total'],
                $data['church_id_null'],
                $data['church_id_set'],
                $data['church_id_null'] > 0 ? 'PENDING BACKFILL' : 'UP-TO-DATE',
            ];
        }
        $this->table(['Table Name', 'Total Rows', 'church_id NULL', 'church_id SET', 'Status'], $domainRows);
        $this->line("Total domain rows: {$snapshot['total_domain_rows']} | Total rows requiring backfill: {$snapshot['total_null_rows']}");

        // 3. User & Role Summary
        $this->info("\n3. USERS & ROLE MAPPING SUMMARY");
        $this->table(
            ['Metric', 'Count'],
            [
                ['Total Users', $snapshot['total_users']],
                ['Users with Single Role', $snapshot['users_by_role_count']['single_role_count']],
                ['Users with Multiple Roles', $snapshot['users_by_role_count']['multi_role_count']],
                ['Users with 0 Roles (Fallback to member)', $snapshot['users_by_role_count']['no_role_count']],
                ['Users Flagged as Super Admin (is_super_admin = true)', $snapshot['super_admin_count']],
            ]
        );

        // 4. Role Distribution Preview
        $this->info("\n4. RESULTING CHURCH USER MEMBERSHIP ROLES");
        $distRows = [];
        foreach ($snapshot['role_distribution'] as $role => $count) {
            $distRows[] = [$role, $count];
        }
        $this->table(['Membership Role', 'User Count'], $distRows);

        // 5. User Details Table
        $this->info("\n5. INDIVIDUAL USER MAPPING DETAILS");
        $userRows = [];
        foreach ($snapshot['users_by_role_count']['details']['single_role'] as $u) {
            $userRows[] = [$u['id'], $u['name'], $u['email'], implode(', ', $u['spatie_roles']), $u['mapped_membership_role']];
        }
        foreach ($snapshot['users_by_role_count']['details']['multi_role'] as $u) {
            $userRows[] = [$u['id'], $u['name'], $u['email'], implode(', ', $u['spatie_roles']), $u['mapped_membership_role'].' (multi-role resolved)'];
        }
        foreach ($snapshot['users_by_role_count']['details']['no_role'] as $u) {
            $userRows[] = [$u['id'], $u['name'], $u['email'], 'None', $u['mapped_membership_role'].' (default fallback)'];
        }
        $this->table(['User ID', 'Name', 'Email', 'Spatie Roles', 'Target Membership Role'], $userRows);

        // 6. Module Catalogue
        $this->info("\n6. MODULE CATALOGUE ({$snapshot['modules_count']} VALIDATED MODULES)");
        $moduleRows = [];
        foreach (TenantBackfillService::MODULE_CATALOG as $key => $meta) {
            $moduleRows[] = [
                $key,
                $meta['name'],
                $meta['is_core'] ? 'YES [NEEDS BUSINESS DECISION]' : 'NO',
                $meta['depends_on'] ?: 'none',
                $meta['description'],
            ];
        }
        $this->table(['Module Key', 'Name', 'Is Core?', 'Depends On', 'Description'], $moduleRows);

        // 7. Anomalies
        $this->info("\n7. ANOMALY AUDIT");
        if (empty($snapshot['anomalies'])) {
            $this->info('No data anomalies detected. System is clean and ready for backfill.');
        } else {
            foreach ($snapshot['anomalies'] as $anomaly) {
                $this->warn("! {$anomaly}");
            }
        }
    }
}
