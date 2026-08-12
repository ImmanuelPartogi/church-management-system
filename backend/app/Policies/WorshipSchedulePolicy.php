<?php

namespace App\Policies;

use App\Models\User;
use App\Models\WorshipSchedule;

class WorshipSchedulePolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view schedules') || $user->hasPermissionTo('manage schedules');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, WorshipSchedule $worshipSchedule): bool
    {
        return $user->hasPermissionTo('view schedules') || $user->hasPermissionTo('manage schedules');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage schedules');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, WorshipSchedule $worshipSchedule): bool
    {
        return $user->hasPermissionTo('manage schedules');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, WorshipSchedule $worshipSchedule): bool
    {
        return $user->hasPermissionTo('manage schedules');
    }
}
