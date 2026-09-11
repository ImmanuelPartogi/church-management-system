<?php

namespace App\Models;

use App\Enums\ChurchServantRole;
use App\Observers\ChurchServantObserver;
use App\Traits\BelongsToChurch;
use Database\Factories\ChurchServantFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\ObservedBy;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @property ChurchServantRole $role
 * @property bool $is_lead_pastor
 * @property bool $active
 */
#[Fillable([
    'member_id',
    'name',
    'role',
    'is_lead_pastor',
    'phone',
    'email',
    'resort_id',
    'sector_id',
    'fellowship_id',
    'description',
    'active',
])]
#[ObservedBy([ChurchServantObserver::class])]
class ChurchServant extends Model
{
    /** @use HasFactory<ChurchServantFactory> */
    use BelongsToChurch, HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'role' => ChurchServantRole::class,
            'is_lead_pastor' => 'boolean',
            'active' => 'boolean',
        ];
    }

    /**
     * Get the church member associated with this servant.
     *
     * @return BelongsTo<ChurchMember, $this>
     */
    public function member(): BelongsTo
    {
        return $this->belongsTo(ChurchMember::class, 'member_id');
    }

    /**
     * Get the resort associated with this servant.
     *
     * @return BelongsTo<Resort, $this>
     */
    public function resort(): BelongsTo
    {
        return $this->belongsTo(Resort::class);
    }

    /**
     * Get the sector associated with this servant.
     *
     * @return BelongsTo<Sector, $this>
     */
    public function sector(): BelongsTo
    {
        return $this->belongsTo(Sector::class);
    }

    /**
     * Get the sectors assigned to this servant (e.g. for Sintua).
     *
     * @return BelongsToMany<Sector, $this>
     */
    public function assignedSectors(): BelongsToMany
    {
        return $this->belongsToMany(Sector::class, 'church_servant_sectors', 'church_servant_id', 'sector_id')
            ->withPivot('church_id')
            ->withTimestamps();
    }

    /**
     * Get the fellowship associated with this servant.
     *
     * @return BelongsTo<Fellowship, $this>
     */
    public function fellowship(): BelongsTo
    {
        return $this->belongsTo(Fellowship::class);
    }

    /**
     * Get the sermons delivered by this servant.
     *
     * @return HasMany<Sermon, $this>
     */
    public function sermons(): HasMany
    {
        return $this->hasMany(Sermon::class, 'servant_id');
    }

    /**
     * Scope a query to only include active servants.
     *
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('active', true);
    }
}
