<?php

namespace App\Policies;

use App\Models\ServiceFormApplication;
use App\Models\User;

class ServiceFormApplicationPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view form applications') || $user->hasPermissionTo('manage form applications');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, ServiceFormApplication $application): bool
    {
        return $user->hasPermissionTo('view form applications') || $user->hasPermissionTo('manage form applications');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage form applications');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, ServiceFormApplication $application): bool
    {
        return $user->hasPermissionTo('manage form applications');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, ServiceFormApplication $application): bool
    {
        return $user->hasPermissionTo('manage form applications');
    }

    /**
     * Determine whether the user (Sintua) can verify the sacrament application for their sector.
     */
    public function verifySector(User $user, ServiceFormApplication $application): bool
    {
        if (! $application->isSacrament()) {
            return false;
        }

        if (! $user->hasPermissionTo('verify sectoral sacraments')) {
            return false;
        }

        $servant = $user->member?->servantProfile;
        if (! $servant || ! $servant->active) {
            return false;
        }

        $applicantSectorId = $application->member?->sector_id;
        if (! $applicantSectorId) {
            return false;
        }

        $assignedSectorIds = $servant->assignedSectors->pluck('id')->all();

        return in_array($applicantSectorId, $assignedSectorIds, true);
    }

    /**
     * Determine whether the user (Lead Pastor) can give final pastoral approval for the sacrament.
     */
    public function approvePastoral(User $user, ServiceFormApplication $application): bool
    {
        if (! $application->isSacrament()) {
            return false;
        }

        if (! $user->hasPermissionTo('approve final sacraments')) {
            return false;
        }

        $servant = $user->member?->servantProfile;

        return (bool) ($servant && $servant->active && $servant->is_lead_pastor);
    }

    /**
     * Determine whether the user can reject the sacrament application.
     */
    public function rejectSacrament(User $user, ServiceFormApplication $application): bool
    {
        return $this->verifySector($user, $application) || $this->approvePastoral($user, $application);
    }

    /**
     * Determine whether the user can mark the sacrament application as completed.
     */
    public function complete(User $user, ServiceFormApplication $application): bool
    {
        if (! $application->isSacrament()) {
            return false;
        }

        return $this->approvePastoral($user, $application) || $user->hasPermissionTo('manage form applications');
    }
}
