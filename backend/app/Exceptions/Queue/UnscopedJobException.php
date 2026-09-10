<?php

namespace App\Exceptions\Queue;

use RuntimeException;

/**
 * Thrown when a queued job touches background execution without implementing either TenantAwareJob or CrossTenantJob.
 */
class UnscopedJobException extends RuntimeException
{
    //
}
