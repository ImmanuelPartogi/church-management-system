<?php

namespace App\Policies;

use App\Models\Songbook;
use App\Models\User;

class SongbookPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view songbooks') || $user->hasPermissionTo('manage songbooks');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, Songbook $songbook): bool
    {
        return $user->hasPermissionTo('view songbooks') || $user->hasPermissionTo('manage songbooks');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage songbooks');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Songbook $songbook): bool
    {
        return $user->hasPermissionTo('manage songbooks');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, Songbook $songbook): bool
    {
        return $user->hasPermissionTo('manage songbooks');
    }
}
