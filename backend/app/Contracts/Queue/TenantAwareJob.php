<?php

namespace App\Contracts\Queue;

/**
 * Contract for background jobs that operate within a single church tenant context.
 */
interface TenantAwareJob
{
    /**
     * Get the ID of the church tenant this job belongs to.
     */
    public function getChurchId(): int;
}
