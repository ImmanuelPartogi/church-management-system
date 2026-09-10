<?php

namespace App\Policies;

use App\Models\Church;
use App\Models\User;

class ChurchPolicy
{
    /**
     * Determine whether the user can view any churches in the registry.
     */
    public function viewAny(User $user): bool
    {
        return (bool) $user->is_super_admin;
    }

    /**
     * Determine whether the user can view a specific church.
     */
    public function view(User $user, Church $church): bool
    {
        return (bool) $user->is_super_admin;
    }

    /**
     * Determine whether the user can create churches.
     */
    public function create(User $user): bool
    {
        return (bool) $user->is_super_admin;
    }

    /**
     * Determine whether the user can update the church.
     */
    public function update(User $user, Church $church): bool
    {
        return (bool) $user->is_super_admin;
    }

    /**
     * Determine whether the user can delete the church.
     * Architectural Decision: UI deletion of church tenants is strictly disabled to prevent
     * accidental cascading deletions on 11 operational tables. Deactivation must be done
     * exclusively via `status: suspended`.
     */
    public function delete(User $user, Church $church): bool
    {
        return false;
    }

    /**
     * Determine whether the user can restore the church.
     */
    public function restore(User $user, Church $church): bool
    {
        return false;
    }

    /**
     * Determine whether the user can permanently delete the church.
     */
    public function forceDelete(User $user, Church $church): bool
    {
        return false;
    }
}
