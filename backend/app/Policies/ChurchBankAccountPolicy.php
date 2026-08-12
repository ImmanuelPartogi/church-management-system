<?php

namespace App\Policies;

use App\Models\ChurchBankAccount;
use App\Models\User;

class ChurchBankAccountPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view bank accounts') || $user->hasPermissionTo('manage bank accounts');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, ChurchBankAccount $account): bool
    {
        return $user->hasPermissionTo('view bank accounts') || $user->hasPermissionTo('manage bank accounts');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage bank accounts');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, ChurchBankAccount $account): bool
    {
        return $user->hasPermissionTo('manage bank accounts');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, ChurchBankAccount $account): bool
    {
        return $user->hasPermissionTo('manage bank accounts');
    }
}
