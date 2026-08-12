<?php

namespace App\Models;

use Database\Factories\SongFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'songbook_id',
    'number',
    'title',
    'lyrics',
    'active',
])]
class Song extends Model
{
    /** @use HasFactory<SongFactory> */
    use HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'number' => 'integer',
            'active' => 'boolean',
        ];
    }

    /**
     * Get the songbook associated with this song.
     *
     * @return BelongsTo<Songbook, $this>
     */
    public function songbook(): BelongsTo
    {
        return $this->belongsTo(Songbook::class);
    }

    /**
     * Scope a query to only include active songs.
     *
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('active', true);
    }
}
