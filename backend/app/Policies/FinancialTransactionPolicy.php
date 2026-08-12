<?php

namespace App\Policies;

use App\Models\FinancialTransaction;
use App\Models\User;

class FinancialTransactionPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view financial transactions') || $user->hasPermissionTo('manage financial transactions');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, FinancialTransaction $transaction): bool
    {
        return $user->hasPermissionTo('view financial transactions') || $user->hasPermissionTo('manage financial transactions');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage financial transactions');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, FinancialTransaction $transaction): bool
    {
        return $user->hasPermissionTo('manage financial transactions');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, FinancialTransaction $transaction): bool
    {
        return $user->hasPermissionTo('manage financial transactions');
    }
}
