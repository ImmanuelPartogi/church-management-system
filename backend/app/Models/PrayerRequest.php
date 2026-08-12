<?php

namespace App\Models;

use App\Enums\PrayerRequestStatus;
use Database\Factories\PrayerRequestFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'user_id',
    'member_id',
    'title',
    'content',
    'category',
    'is_private',
    'status',
    'follow_up_notes',
    'followed_up_by',
    'followed_up_at',
])]
class PrayerRequest extends Model
{
    /** @use HasFactory<PrayerRequestFactory> */
    use HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'is_private' => 'boolean',
            'status' => PrayerRequestStatus::class,
            'followed_up_at' => 'datetime',
        ];
    }

    /**
     * Get the user account associated with the prayer request.
     *
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the church member associated with the prayer request.
     *
     * @return BelongsTo<ChurchMember, $this>
     */
    public function member(): BelongsTo
    {
        return $this->belongsTo(ChurchMember::class, 'member_id');
    }

    /**
     * Get the user that followed up on the prayer request.
     *
     * @return BelongsTo<User, $this>
     */
    public function followedUpBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'followed_up_by');
    }
}
