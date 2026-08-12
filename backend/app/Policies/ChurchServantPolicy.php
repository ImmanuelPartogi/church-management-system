<?php

namespace App\Policies;

use App\Models\ChurchServant;
use App\Models\User;

class ChurchServantPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view church servants') || $user->hasPermissionTo('manage church servants');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, ChurchServant $servant): bool
    {
        return $user->hasPermissionTo('view church servants') || $user->hasPermissionTo('manage church servants');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage church servants');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, ChurchServant $servant): bool
    {
        return $user->hasPermissionTo('manage church servants');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, ChurchServant $servant): bool
    {
        return $user->hasPermissionTo('manage church servants');
    }
}
