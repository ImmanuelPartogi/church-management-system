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
}
