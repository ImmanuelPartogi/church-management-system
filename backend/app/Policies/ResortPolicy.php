<?php

namespace App\Policies;

use App\Models\Resort;
use App\Models\User;

class ResortPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view resorts') || $user->hasPermissionTo('manage resorts');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, Resort $resort): bool
    {
        return $user->hasPermissionTo('view resorts') || $user->hasPermissionTo('manage resorts');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage resorts');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Resort $resort): bool
    {
        return $user->hasPermissionTo('manage resorts');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, Resort $resort): bool
    {
        return $user->hasPermissionTo('manage resorts');
    }
}
