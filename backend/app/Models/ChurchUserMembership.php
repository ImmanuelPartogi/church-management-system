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
}
