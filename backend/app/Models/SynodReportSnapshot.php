<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'generated_by_user_id',
    'period_date',
    'total_churches',
    'active_churches',
    'suspended_churches',
    'total_active_members',
    'total_all_members',
    'total_active_donations',
    'total_all_donations',
    'total_active_sacraments',
    'total_all_sacraments',
    'church_comparisons',
    'module_adoption',
])]
class SynodReportSnapshot extends Model
{
    use HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'period_date' => 'date',
            'total_churches' => 'integer',
            'active_churches' => 'integer',
            'suspended_churches' => 'integer',
            'total_active_members' => 'integer',
            'total_all_members' => 'integer',
            'total_active_donations' => 'decimal:2',
            'total_all_donations' => 'decimal:2',
            'total_active_sacraments' => 'integer',
            'total_all_sacraments' => 'integer',
            'church_comparisons' => 'array',
            'module_adoption' => 'array',
        ];
    }

    /**
     * The Super Admin user who triggered this snapshot generation manually, if any.
     *
     * @return BelongsTo<User, $this>
     */
    public function generatedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'generated_by_user_id');
    }

    /**
     * Deterministic query scope for the latest snapshot.
     *
     * @param  Builder<SynodReportSnapshot>  $query
     * @return Builder<SynodReportSnapshot>
     */
    public function scopeLatestFirst(Builder $query): Builder
    {
        return $query->orderBy('created_at', 'desc')->orderBy('id', 'desc');
    }

    /**
     * Retrieve the most recent snapshot deterministically.
     */
    public static function latestSnapshot(): ?self
    {
        return static::query()->latestFirst()->first();
    }
}
