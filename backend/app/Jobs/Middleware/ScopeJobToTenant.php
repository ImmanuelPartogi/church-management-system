<?php

namespace App\Jobs\Middleware;

use App\Contracts\Queue\CrossTenantJob;
use App\Contracts\Queue\TenantAwareJob;
use App\Exceptions\Queue\UnauthorizedCrossTenantDispatchException;
use App\Exceptions\Queue\UnscopedJobException;
use App\Models\Church;
use App\Models\User;
use RuntimeException;
use Spatie\Permission\PermissionRegistrar;

/**
 * Queue middleware to strictly scope worker processes to tenant context
 * and enforce zero-leak teardown upon job completion or failure.
 */
class ScopeJobToTenant
{
    /**
     * Process the queued job.
     */
    public function handle(object $job, callable $next): mixed
    {
        if ($job instanceof TenantAwareJob) {
            $churchId = $job->getChurchId();
            $church = Church::find($churchId);

            if (! $church || $church->status !== 'active') {
                throw new RuntimeException(
                    'Cannot execute job ['.get_class($job)."]: Church tenant [{$churchId}] is not active or does not exist."
                );
            }

            app()->instance('current_church_id', $churchId);
            app()->instance('current_church', $church);

            if (config('permission.teams')) {
                app(PermissionRegistrar::class)->setPermissionsTeamId($churchId);
            }

            try {
                return $next($job);
            } finally {
                $this->teardownContext();
            }
        }

        if ($job instanceof CrossTenantJob) {
            if (! $job->allowCrossTenant()) {
                throw new UnauthorizedCrossTenantDispatchException(
                    'Cross-tenant execution is disabled for job ['.get_class($job).'].'
                );
            }

            // Worker Execution-Time Dispatcher Re-evaluation (Two-Tier Guard):
            if (! $job->isSystemDispatched()) {
                $userId = $job->getDispatchedByUserId();

                if (! $userId) {
                    throw new UnauthorizedCrossTenantDispatchException(
                        'Cannot execute cross-tenant job ['.get_class($job).']: Missing dispatcher user ID.'
                    );
                }

                $dispatcher = User::find($userId);

                if (! $dispatcher || ! $dispatcher->is_super_admin) {
                    throw new UnauthorizedCrossTenantDispatchException(
                        'Cannot execute cross-tenant job ['.get_class($job)."]: Dispatcher [{$userId}] is no longer an active Super Admin at execution time."
                    );
                }
            }

            // Execute in global system context with clean teardown
            try {
                return $next($job);
            } finally {
                $this->teardownContext();
            }
        }

        // Fail-Loud Safety Guard: Ambiguous / unscoped jobs are strictly rejected
        throw new UnscopedJobException(
            'Job ['.get_class($job).'] must implement either TenantAwareJob or CrossTenantJob to be executed in queue.'
        );
    }

    /**
     * Completely clear tenant context and Spatie permissions team from memory.
     */
    protected function teardownContext(): void
    {
        app()->forgetInstance('current_church_id');
        app()->forgetInstance('current_church');

        if (config('permission.teams')) {
            app(PermissionRegistrar::class)->setPermissionsTeamId(null);
        }
    }
}
