<?php

namespace App\Traits\Queue;

use App\Jobs\Middleware\ScopeJobToTenant;

/**
 * Trait for jobs implementing TenantAwareJob.
 */
trait TenantAwareJobTrait
{
    public int $churchId;

    /**
     * Get the ID of the church tenant this job belongs to.
     */
    public function getChurchId(): int
    {
        return $this->churchId;
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
