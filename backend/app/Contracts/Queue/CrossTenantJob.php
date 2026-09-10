<?php

namespace App\Contracts\Queue;

/**
 * Contract for background jobs that legitimately operate across all church tenants (e.g. Synod aggregation, platform cleanup).
 */
interface CrossTenantJob
{
    /**
     * Whether cross-tenant execution is explicitly allowed for this job.
     */
    public function allowCrossTenant(): bool;

    /**
     * Get the ID of the user who dispatched this job, if dispatched by a user.
     */
    public function getDispatchedByUserId(): ?int;

    /**
     * Whether this job was dispatched by system/console/scheduler.
     */
    public function isSystemDispatched(): bool;
}
