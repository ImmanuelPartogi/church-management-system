<?php

namespace App\Models;

use App\Traits\BelongsToChurch;
use Database\Factories\WartaFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

#[Fillable([
    'title',
    'description',
    'file_path',
    'file_name',
    'file_size',
    'mime_type',
    'published_at',
    'is_published',
    'download_count',
])]
class Warta extends Model
{
    /** @use HasFactory<WartaFactory> */
    use BelongsToChurch, HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'published_at' => 'datetime',
            'is_published' => 'boolean',
            'download_count' => 'integer',
            'file_size' => 'integer',
        ];
    }

    /**
     * Scope a query to only include published wartas.
     *
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopePublished(Builder $query): Builder
    {
        return $query->where('is_published', true)
            ->whereNotNull('published_at')
            ->where('published_at', '<=', now());
    }

    /**
     * Scope a query to order wartas by latest published date.
     *
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeLatestPublished(Builder $query): Builder
    {
        return $query->published()->orderByDesc('published_at');
    }
}
