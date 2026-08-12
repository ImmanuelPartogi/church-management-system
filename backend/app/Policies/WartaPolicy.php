<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Warta;

class WartaPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view wartas') || $user->hasPermissionTo('manage wartas');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, Warta $warta): bool
    {
        return $user->hasPermissionTo('view wartas') || $user->hasPermissionTo('manage wartas');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage wartas');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Warta $warta): bool
    {
        return $user->hasPermissionTo('manage wartas');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, Warta $warta): bool
    {
        return $user->hasPermissionTo('manage wartas');
    }
}
