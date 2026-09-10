<?php

namespace App\Traits;

use App\Models\Church;
use App\Scopes\ChurchScope;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * ============================================================================
 * NOT YET ACTIVATED — akan diaktifkan di Phase 3 setelah data backfill selesai (Phase 1D/1E)
 * ============================================================================
 *
 * Trait for models that belong to a single church tenant.
 * Provides the church relation and registers the ChurchScope upon model boot.
 *
 * Phase 1C Status: Dormant. NOT attached to any existing models.
 * Planned Activation: Phase 3 (Multi-Church Enforcement & Global Tenant Scoping).
 */
trait BelongsToChurch
{
    /**
     * Boot the trait to apply ChurchScope and auto-assign church_id on creation.
     */
    public static function bootBelongsToChurch(): void
    {
        static::addGlobalScope(new ChurchScope);

        static::creating(function ($model) {
            if (empty($model->church_id)) {
                if (! app()->bound('current_church_id') || ($churchId = app('current_church_id')) === null) {
                    throw new \RuntimeException(
                        'Tenant context is missing — cannot create ['.get_class($model).'] without an active church context.'
                    );
                }

                $model->church_id = $churchId;
            }
        });
    }

    /**
     * Get the church that owns this entity.
     *
     * @return BelongsTo<Church, $this>
     */
    public function church(): BelongsTo
    {
        return $this->belongsTo(Church::class, 'church_id');
    }
}
