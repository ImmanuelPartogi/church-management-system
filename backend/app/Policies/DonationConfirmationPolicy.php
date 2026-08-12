<?php

namespace App\Policies;

use App\Models\DonationConfirmation;
use App\Models\User;

class DonationConfirmationPolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasPermissionTo('view donations') || $user->hasPermissionTo('manage donations');
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, DonationConfirmation $donation): bool
    {
        return $user->hasPermissionTo('view donations') || $user->hasPermissionTo('manage donations');
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return $user->hasPermissionTo('manage donations');
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, DonationConfirmation $donation): bool
    {
        return $user->hasPermissionTo('manage donations');
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, DonationConfirmation $donation): bool
    {
        return $user->hasPermissionTo('manage donations');
    }
}
