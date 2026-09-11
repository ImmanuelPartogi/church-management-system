<?php

namespace App\Traits;

use App\Models\User;
use Illuminate\Database\Eloquent\Builder;

/**
 * Trait providing member-level ownership scoping within a tenant church.
 * Used for intra-tenant privacy isolation (e.g. personal donations, prayer requests, form applications).
 */
trait BelongsToMember
{
    /**
     * Scope a query to only include records belonging to a specific user/member.
     *
     * @param  Builder<static>  $query
     * @return Builder<static>
     */
    public function scopeForMember(Builder $query, ?User $user = null): Builder
    {
        $user ??= auth()->user();

        if (! $user) {
            return $query->whereRaw('1 = 0');
        }

        return $query->where($this->getTable().'.user_id', $user->id);
    }

    /**
     * Determine whether this record is owned by the given user.
     */
    public function isOwnedBy(User $user): bool
    {
        return (int) $this->user_id === (int) $user->id;
    }
}
