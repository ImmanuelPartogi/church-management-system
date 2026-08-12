<?php

namespace App\Policies;

use App\Models\PrayerRequest;
use App\Models\User;

class PrayerRequestPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view prayer requests') || $user->hasPermissionTo('manage prayer requests');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, PrayerRequest $prayerRequest): bool
    {
        if ($prayerRequest->is_private) {
            return $user->hasPermissionTo('view private prayer requests')
                || $user->hasPermissionTo('manage prayer requests')
                || $user->id === $prayerRequest->user_id;
        }

        return $user->hasPermissionTo('view prayer requests') || $user->hasPermissionTo('manage prayer requests');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage prayer requests') || $user->hasPermissionTo('view prayer requests');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, PrayerRequest $prayerRequest): bool
    {
        return $user->hasPermissionTo('manage prayer requests');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, PrayerRequest $prayerRequest): bool
    {
        return $user->hasPermissionTo('manage prayer requests');
    }
}
