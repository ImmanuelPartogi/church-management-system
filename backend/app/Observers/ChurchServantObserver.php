<?php

namespace App\Observers;

use App\Enums\ChurchServantRole;
use App\Models\ChurchMember;
use App\Models\ChurchServant;
use App\Scopes\ChurchScope;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class ChurchServantObserver
{
    /**
     * Handle the ChurchServant "saved" event (covers created and updated).
     */
    public function saved(ChurchServant $servant): void
    {
        $this->syncSintuaRole($servant);
    }

    /**
     * Handle the ChurchServant "deleted" event.
     */
    public function deleted(ChurchServant $servant): void
    {
        $this->revokeSintuaRole($servant);
    }

    /**
     * Sync the Spatie "sintua" role for the servant's associated user within the church tenant.
     */
    protected function syncSintuaRole(ChurchServant $servant): void
    {
        $member = $servant->relationLoaded('member')
            ? $servant->member
            : ChurchMember::withoutGlobalScope(ChurchScope::class)->find($servant->member_id);

        $user = $member?->user;
        if (! $user || ! $servant->church_id) {
            return;
        }

        $registrar = app(PermissionRegistrar::class);
        $previousTeamId = $registrar->getPermissionsTeamId();
        $registrar->setPermissionsTeamId($servant->church_id);

        try {
            $roleValue = $servant->role instanceof ChurchServantRole
                ? $servant->role->value
                : (string) $servant->role;

            $isSintuaRole = ($roleValue === 'sintua');

            // Ensure the role exists for this church tenant
            $sintuaRole = Role::firstOrCreate([
                'name' => 'sintua',
                'guard_name' => 'web',
                'church_id' => $servant->church_id,
            ]);

            if ($isSintuaRole && $servant->active) {
                if (! $user->hasRole('sintua')) {
                    $user->assignRole($sintuaRole);
                }
            } else {
                if ($user->hasRole('sintua')) {
                    $user->removeRole($sintuaRole);
                }
            }
        } finally {
            $registrar->setPermissionsTeamId($previousTeamId);
        }
    }

    /**
     * Revoke the "sintua" role from the servant's user within this church.
     */
    protected function revokeSintuaRole(ChurchServant $servant): void
    {
        $member = $servant->relationLoaded('member')
            ? $servant->member
            : ChurchMember::withoutGlobalScope(ChurchScope::class)->find($servant->member_id);

        $user = $member?->user;
        if (! $user || ! $servant->church_id) {
            return;
        }

        $registrar = app(PermissionRegistrar::class);
        $previousTeamId = $registrar->getPermissionsTeamId();
        $registrar->setPermissionsTeamId($servant->church_id);

        try {
            $sintuaRole = Role::where('name', 'sintua')
                ->where('church_id', $servant->church_id)
                ->first();

            if ($sintuaRole && $user->hasRole('sintua')) {
                $user->removeRole($sintuaRole);
            }
        } finally {
            $registrar->setPermissionsTeamId($previousTeamId);
        }
    }
}
