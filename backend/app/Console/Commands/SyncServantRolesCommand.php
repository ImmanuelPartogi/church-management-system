<?php

namespace App\Console\Commands;

use App\Enums\ChurchServantRole;
use App\Models\ChurchServant;
use App\Scopes\ChurchScope;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class SyncServantRolesCommand extends Command
{
    protected $signature = 'church:sync-servant-roles {--dry-run : Preview changes without modifying database}';

    protected $description = 'Synchronize Spatie sintua roles for active church servants across tenants';

    public function handle(): int
    {
        $isDryRun = (bool) $this->option('dry-run');

        $this->info($isDryRun ? '=== DRY RUN MODE: Sync Servant Roles ===' : '=== SYNC SERVANT ROLES ===');

        $servants = ChurchServant::withoutGlobalScope(ChurchScope::class)
            ->with([
                'member' => fn ($q) => $q->withoutGlobalScope(ChurchScope::class)->with('user'),
                'church',
            ])
            ->where('active', true)
            ->where(function ($query) {
                $query->where('role', 'sintua')
                    ->orWhere('role', ChurchServantRole::Sintua->value);
            })
            ->whereHas('member', function ($query) {
                $query->withoutGlobalScope(ChurchScope::class)->whereNotNull('user_id');
            })
            ->get();

        $this->info("Found {$servants->count()} active Sintua servants with linked user accounts.");

        if ($servants->isEmpty()) {
            $this->info('No servants to sync.');

            return self::SUCCESS;
        }

        $assignedCount = 0;
        $alreadyHasRoleCount = 0;

        $syncLogic = function () use ($servants, $isDryRun, &$assignedCount, &$alreadyHasRoleCount) {
            $registrar = app(PermissionRegistrar::class);
            $previousTeamId = $registrar->getPermissionsTeamId();

            try {
                foreach ($servants as $servant) {
                    $user = $servant->member->user;
                    $churchId = $servant->church_id;

                    $registrar->setPermissionsTeamId($churchId);

                    $role = Role::firstOrCreate([
                        'name' => 'sintua',
                        'guard_name' => 'web',
                        'church_id' => $churchId,
                    ]);

                    if ($user->hasRole('sintua')) {
                        $alreadyHasRoleCount++;
                        $this->line("  [EXISTS] User #{$user->id} ({$user->name}) already has role 'sintua' in Church #{$churchId}");
                    } else {
                        $assignedCount++;
                        if (! $isDryRun) {
                            $user->assignRole($role);
                        }
                        $this->info("  [ASSIGNED] User #{$user->id} ({$user->name}) -> role 'sintua' in Church #{$churchId}");
                    }
                }
            } finally {
                $registrar->setPermissionsTeamId($previousTeamId);
            }
        };

        if ($isDryRun) {
            $syncLogic();
        } else {
            DB::transaction($syncLogic);
        }

        $this->newLine();
        $this->info("Summary: {$assignedCount} newly assigned, {$alreadyHasRoleCount} already possessed.");

        return self::SUCCESS;
    }
}
