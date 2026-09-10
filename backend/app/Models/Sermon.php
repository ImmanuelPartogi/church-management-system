<?php

namespace App\Models;

use App\Traits\BelongsToChurch;
use Database\Factories\SermonFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * @property Carbon|null $published_at
 * @property bool $is_published
 * @property int $download_count
 * @property int|null $file_size
 */
#[Fillable([
    'title',
    'description',
    'preacher_name',
    'servant_id',
    'file_path',
    'file_name',
    'file_size',
    'mime_type',
    'published_at',
    'is_published',
    'download_count',
])]
class Sermon extends Model
{
    /** @use HasFactory<SermonFactory> */
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
     * Get the servant associated with this sermon.
     *
     * @return BelongsTo<ChurchServant, $this>
     */
    public function servant(): BelongsTo
    {
        return $this->belongsTo(ChurchServant::class, 'servant_id');
    }

    /**
     * Scope a query to only include published sermons.
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
     * Scope a query to order sermons by latest published date.
     *
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeLatestPublished(Builder $query): Builder
    {
        return $query->published()->orderByDesc('published_at');
    }
}
