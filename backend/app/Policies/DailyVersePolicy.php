<?php

namespace App\Policies;

use App\Models\DailyVerse;
use App\Models\User;

class DailyVersePolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view daily verses') || $user->hasPermissionTo('manage daily verses');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, DailyVerse $dailyVerse): bool
    {
        return $user->hasPermissionTo('view daily verses') || $user->hasPermissionTo('manage daily verses');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage daily verses');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, DailyVerse $dailyVerse): bool
    {
        return $user->hasPermissionTo('manage daily verses');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, DailyVerse $dailyVerse): bool
    {
        return $user->hasPermissionTo('manage daily verses');
    }
}
