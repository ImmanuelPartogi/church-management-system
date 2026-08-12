<?php

namespace App\Policies;

use App\Models\Sermon;
use App\Models\User;

class SermonPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view sermons') || $user->hasPermissionTo('manage sermons');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, Sermon $sermon): bool
    {
        return $user->hasPermissionTo('view sermons') || $user->hasPermissionTo('manage sermons');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage sermons');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Sermon $sermon): bool
    {
        return $user->hasPermissionTo('manage sermons');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, Sermon $sermon): bool
    {
        return $user->hasPermissionTo('manage sermons');
    }
}
