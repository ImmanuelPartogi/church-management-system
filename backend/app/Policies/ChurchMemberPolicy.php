<?php

namespace App\Policies;

use App\Models\ChurchMember;
use App\Models\User;

class ChurchMemberPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view members') || $user->hasPermissionTo('manage members');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, ChurchMember $churchMember): bool
    {
        return $user->hasPermissionTo('view members') || $user->hasPermissionTo('manage members');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage members');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, ChurchMember $churchMember): bool
    {
        return $user->hasPermissionTo('manage members');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, ChurchMember $churchMember): bool
    {
        return $user->hasPermissionTo('manage members');
    }
}
