<?php

namespace App\Scopes;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Scope;

/**
 * ============================================================================
 * NOT YET ACTIVATED — akan diaktifkan di Phase 3 setelah data backfill selesai (Phase 1D/1E)
 * ============================================================================
 *
 * This scope automatically filters queries by the currently active church/tenant.
 *
 * Phase 1C Status: Dormant. NOT attached to any models.
 * Planned Activation: Phase 3 (Multi-Church Enforcement & Global Tenant Scoping).
 *
 * @template TModel of Model
 *
 * @implements Scope<TModel>
 */
class ChurchScope implements Scope
{
    /**
     * Apply the scope to a given Eloquent query builder.
     */
    public function apply(Builder $builder, Model $model): void
    {
        if (! app()->bound('current_church_id') || ($churchId = app('current_church_id')) === null) {
            throw new \RuntimeException(
                'Tenant context is missing — cannot query ['.get_class($model).'] without an active church context. Use withoutChurch() for global queries.'
            );
        }

        $builder->where($model->getTable().'.church_id', $churchId);
    }

    /**
     * Extend the query builder with the needed functions.
     *
     * @param  Builder<TModel>  $builder
     */
    public function extend(Builder $builder): void
    {
        $builder->macro('withoutChurch', function (Builder $builder) {
            return $builder->withoutGlobalScope(ChurchScope::class);
        });
    }
}
