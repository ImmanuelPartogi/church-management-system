<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

/**
 * Phase 2 Task 4: Backfill church_id on Spatie Permission tables
 * and rename role 'admin' → 'church_admin'.
 *
 * This command ONLY handles database changes.
 * Code changes (canAccessPanel, seeder, tests) must be applied
 * separately before running this command — they are NOT part of dry-run.
 *
 * TEMPORARY: This command is a one-time migration utility.
 * After successful execution, it can be removed.
 */
class SpatieTeamsBackfillCommand extends Command
{
    protected $signature = 'spatie:backfill-church-id {--dry-run : Preview changes without writing to database}';

    protected $description = 'Backfill church_id on Spatie roles/model_has_roles and rename admin → church_admin';

    public function handle(): int
    {
        $isDryRun = $this->option('dry-run');

        $this->info($isDryRun ? '=== DRY RUN MODE (no database changes) ===' : '=== REAL RUN MODE ===');
        $this->newLine();

        // Step 1: Resolve default church
        $defaultChurch = DB::table('churches')->where('slug', 'default')->first();
        if (! $defaultChurch) {
            $this->error('Default church (slug=\'default\') not found. Cannot proceed.');

            return self::FAILURE;
        }
        $this->info("Default church: id={$defaultChurch->id}, name=\"{$defaultChurch->name}\"");
        $this->newLine();

        // Step 2: Show current state (BEFORE)
        $this->info('--- BEFORE STATE ---');
        $this->showRolesTable();
        $this->showModelHasRolesTable();
        $this->showModelHasPermissionsTable();
        $this->newLine();

        if ($isDryRun) {
            // Step 3 (dry-run): Show what WOULD change
            $this->info('--- PLANNED CHANGES (dry-run) ---');
            $this->newLine();

            // Rename
            $adminRole = DB::table('roles')->where('name', 'admin')->first();
            if ($adminRole) {
                $this->line("  [RENAME] roles.id={$adminRole->id}: name 'admin' → 'church_admin'");
                $this->line("           model_has_roles: role_id={$adminRole->id} rows auto-update (reference by id, not name)");
                $this->line("           role_has_permissions: role_id={$adminRole->id} rows unaffected (reference by id)");
            } else {
                $this->line('  [RENAME] SKIP: No role named \'admin\' found (already renamed or never existed).');
            }
            $this->newLine();

            // Backfill roles
            $rolesNullCount = DB::table('roles')->whereNull('church_id')->count();
            $this->line("  [BACKFILL] roles: {$rolesNullCount} rows with church_id=NULL → church_id={$defaultChurch->id}");

            // Backfill model_has_roles
            $mhrNullCount = DB::table('model_has_roles')->whereNull('church_id')->count();
            $this->line("  [BACKFILL] model_has_roles: {$mhrNullCount} rows with church_id=NULL → church_id={$defaultChurch->id}");

            // Backfill model_has_permissions
            $mhpNullCount = DB::table('model_has_permissions')->whereNull('church_id')->count();
            $this->line("  [BACKFILL] model_has_permissions: {$mhpNullCount} rows with church_id=NULL → church_id={$defaultChurch->id}");
            if ($mhpNullCount === 0) {
                $this->line('             (table is empty — nothing to backfill)');
            }

            $this->newLine();
            $this->warn('NOTE: This dry-run only previews DATABASE changes (rename + church_id backfill).');
            $this->warn('Code changes (canAccessPanel, seeder, tests) must be applied separately and are NOT part of this command.');

            return self::SUCCESS;
        }

        // Step 3 (real run): Execute changes in transaction
        DB::transaction(function () use ($defaultChurch) {
            // 3a: Rename role 'admin' → 'church_admin'
            $renamed = DB::table('roles')
                ->where('name', 'admin')
                ->update(['name' => 'church_admin']);
            $this->line("  [RENAME] roles: {$renamed} row(s) renamed 'admin' → 'church_admin'");

            // 3b: Backfill church_id on roles
            $rolesUpdated = DB::table('roles')
                ->whereNull('church_id')
                ->update(['church_id' => $defaultChurch->id]);
            $this->line("  [BACKFILL] roles: {$rolesUpdated} row(s) set church_id={$defaultChurch->id}");

            // 3c: Backfill church_id on model_has_roles
            $mhrUpdated = DB::table('model_has_roles')
                ->whereNull('church_id')
                ->update(['church_id' => $defaultChurch->id]);
            $this->line("  [BACKFILL] model_has_roles: {$mhrUpdated} row(s) set church_id={$defaultChurch->id}");

            // 3d: Backfill church_id on model_has_permissions (expected: 0)
            $mhpUpdated = DB::table('model_has_permissions')
                ->whereNull('church_id')
                ->update(['church_id' => $defaultChurch->id]);
            $this->line("  [BACKFILL] model_has_permissions: {$mhpUpdated} row(s) set church_id={$defaultChurch->id}");
        });

        $this->newLine();

        // Step 4: Show final state (AFTER)
        $this->info('--- AFTER STATE ---');
        $this->showRolesTable();
        $this->showModelHasRolesTable();
        $this->showModelHasPermissionsTable();

        $this->newLine();
        $this->info('Backfill completed successfully.');

        return self::SUCCESS;
    }

    private function showRolesTable(): void
    {
        $roles = DB::table('roles')->select('id', 'name', 'guard_name', 'church_id')->get();
        $this->table(
            ['id', 'name', 'guard_name', 'church_id'],
            $roles->map(fn ($r) => [$r->id, $r->name, $r->guard_name, $r->church_id ?? 'NULL'])->toArray()
        );
    }

    private function showModelHasRolesTable(): void
    {
        $rows = DB::table('model_has_roles')
            ->join('roles', 'model_has_roles.role_id', '=', 'roles.id')
            ->join('users', 'model_has_roles.model_id', '=', 'users.id')
            ->select(
                'users.id as user_id',
                'users.name as user_name',
                'roles.name as role_name',
                'model_has_roles.church_id'
            )
            ->orderBy('users.id')
            ->get();
        $this->table(
            ['user_id', 'user_name', 'role_name', 'church_id'],
            $rows->map(fn ($r) => [$r->user_id, $r->user_name, $r->role_name, $r->church_id ?? 'NULL'])->toArray()
        );
    }

    private function showModelHasPermissionsTable(): void
    {
        $count = DB::table('model_has_permissions')->count();
        $this->line("  model_has_permissions: {$count} rows".($count === 0 ? ' (empty — nothing to backfill)' : ''));
    }
}
