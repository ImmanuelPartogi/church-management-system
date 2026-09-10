<?php

namespace App\Exceptions\Queue;

use RuntimeException;

/**
 * Thrown when a cross-tenant job is dispatched or executed without active Super Admin authorization or verified system context.
 */
class UnauthorizedCrossTenantDispatchException extends RuntimeException
{
    //
}
