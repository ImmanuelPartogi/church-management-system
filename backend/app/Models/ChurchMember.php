<?php

namespace App\Models;

use App\Traits\BelongsToChurch;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

#[Fillable([
    'user_id',
    'membership_number',
    'full_name',
    'gender',
    'birth_date',
    'phone',
    'email',
    'address',
    'sector_id',
    'baptism_date',
    'sidi_date',
    'status',
])]
class ChurchMember extends Model
{
    /** @use HasFactory<Factory<self>> */
    use BelongsToChurch, HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'birth_date' => 'date',
            'baptism_date' => 'date',
            'sidi_date' => 'date',
        ];
    }

    /**
     * Get the user account associated with the member.
     *
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the sector (wijk) this member belongs to.
     *
     * @return BelongsTo<Sector, $this>
     */
    public function sector(): BelongsTo
    {
        return $this->belongsTo(Sector::class);
    }

    /**
     * Get the worship assignments for this member.
     *
     * @return HasMany<WorshipOfficer, $this>
     */
    public function officerRoles(): HasMany
    {
        return $this->hasMany(WorshipOfficer::class, 'member_id');
    }

    /**
     * Get the fellowships this member belongs to.
     *
     * @return BelongsToMany<Fellowship, $this>
     */
    public function fellowships(): BelongsToMany
    {
        return $this->belongsToMany(Fellowship::class, 'fellowship_member', 'member_id', 'fellowship_id')
            ->withTimestamps();
    }

    /**
     * Get the servant profile for this member if assigned.
     *
     * @return HasOne<ChurchServant, $this>
     */
    public function servantProfile(): HasOne
    {
        return $this->hasOne(ChurchServant::class, 'member_id');
    }
}
