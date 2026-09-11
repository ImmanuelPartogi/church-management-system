<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'user_id',
    'church_id',
    'church_member_id',
    'role',
    'status',
    'joined_at',
])]
class ChurchUserMembership extends Model
{
    /** @use HasFactory<Factory<self>> */
    use HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'joined_at' => 'datetime',
        ];
    }

    /**
     * Get the user account for this membership.
     *
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Get the church for this membership.
     *
     * @return BelongsTo<Church, $this>
     */
    public function church(): BelongsTo
    {
        return $this->belongsTo(Church::class, 'church_id');
    }

    /**
     * Get the congregation member profile for this membership if linked.
     *
     * @return BelongsTo<ChurchMember, $this>
     */
    public function churchMember(): BelongsTo
    {
        return $this->belongsTo(ChurchMember::class, 'church_member_id');
    }

    /**
     * The "booted" method of the model.
     * Synchronizes device token lifecycle with membership status changes (defense-in-depth).
     */
    protected static function booted(): void
    {
        // 1. When membership status is updated
        static::updated(function (self $membership) {
            if ($membership->isDirty('status')) {
                $isActive = $membership->status === 'active';
                DeviceToken::where('user_id', $membership->user_id)
                    ->where('church_id', $membership->church_id)
                    ->update(['is_active' => $isActive]);
            }
        });

        // 2. When membership is deleted (both hard-delete and future soft-delete)
        static::deleted(function (self $membership) {
            DeviceToken::where('user_id', $membership->user_id)
                ->where('church_id', $membership->church_id)
                ->update(['is_active' => false]);
        });

        // 3. When membership is restored (anticipating future SoftDeletes)
        if (method_exists(static::class, 'restored')) {
            static::restored(function (self $membership) {
                if ($membership->status === 'active') {
                    DeviceToken::where('user_id', $membership->user_id)
                        ->where('church_id', $membership->church_id)
                        ->update(['is_active' => true]);
                }
            });
        }
    }
}
