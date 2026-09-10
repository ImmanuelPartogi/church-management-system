<?php

namespace App\Traits\Queue;

use App\Exceptions\Queue\UnauthorizedCrossTenantDispatchException;
use App\Jobs\Middleware\ScopeJobToTenant;

/**
 * Trait for jobs implementing CrossTenantJob.
 * Enforces Tier 1 Dispatcher Guard upon dispatch.
 */
trait CrossTenantJobTrait
{
    public ?int $dispatchedByUserId = null;

    public bool $isSystemDispatched = false;

    /**
     * Initialize dispatcher context during dispatch.
     *
     * @throws UnauthorizedCrossTenantDispatchException If dispatched in non-super-admin context.
     */
    public function initCrossTenantDispatcher(): void
    {
        if (app()->runningInConsole() && ! auth()->check()) {
            $this->isSystemDispatched = true;
            $this->dispatchedByUserId = null;

            return;
        }

        $user = auth()->user();
        if (! $user || ! $user->is_super_admin) {
            throw new UnauthorizedCrossTenantDispatchException(
                'Only Super Administrators are authorized to dispatch cross-tenant background jobs.'
            );
        }

        $this->dispatchedByUserId = $user->id;
        $this->isSystemDispatched = false;
    }

    public function allowCrossTenant(): bool
    {
        return true;
    }

    public function getDispatchedByUserId(): ?int
    {
        return $this->dispatchedByUserId;
    }

    public function isSystemDispatched(): bool
    {
        return $this->isSystemDispatched;
    }

    /**
     * Get the middleware the job should pass through.
     *
     * @return array<int, object>
     */
    public function middleware(): array
    {
        return [new ScopeJobToTenant];
    }
}
