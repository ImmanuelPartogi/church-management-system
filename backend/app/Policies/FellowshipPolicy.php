<?php

namespace App\Policies;

use App\Models\Fellowship;
use App\Models\User;

class FellowshipPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view fellowships') || $user->hasPermissionTo('manage fellowships');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, Fellowship $fellowship): bool
    {
        return $user->hasPermissionTo('view fellowships') || $user->hasPermissionTo('manage fellowships');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage fellowships');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Fellowship $fellowship): bool
    {
        return $user->hasPermissionTo('manage fellowships');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, Fellowship $fellowship): bool
    {
        return $user->hasPermissionTo('manage fellowships');
    }
}
