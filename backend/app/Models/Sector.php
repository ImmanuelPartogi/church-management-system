<?php

namespace App\Models;

use Database\Factories\SectorFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable([
    'resort_id',
    'name',
    'code',
    'description',
    'active',
])]
class Sector extends Model
{
    /** @use HasFactory<SectorFactory> */
    use HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'active' => 'boolean',
        ];
    }

    /**
     * Get the resort associated with the sector.
     *
     * @return BelongsTo<Resort, $this>
     */
    public function resort(): BelongsTo
    {
        return $this->belongsTo(Resort::class);
    }

    /**
     * Get the servants assigned to this sector.
     *
     * @return HasMany<ChurchServant, $this>
     */
    public function servants(): HasMany
    {
        return $this->hasMany(ChurchServant::class);
    }

    /**
     * Scope a query to only include active sectors.
     *
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('active', true);
    }
}
