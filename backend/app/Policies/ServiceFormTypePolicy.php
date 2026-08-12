<?php

namespace App\Policies;

use App\Models\ServiceFormType;
use App\Models\User;

class ServiceFormTypePolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view form types') || $user->hasPermissionTo('manage form types');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, ServiceFormType $serviceFormType): bool
    {
        return $user->hasPermissionTo('view form types') || $user->hasPermissionTo('manage form types');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage form types');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, ServiceFormType $serviceFormType): bool
    {
        return $user->hasPermissionTo('manage form types');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, ServiceFormType $serviceFormType): bool
    {
        return $user->hasPermissionTo('manage form types');
    }
}
