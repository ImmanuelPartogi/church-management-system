<?php

namespace Tests\Feature\Queue;

use App\Contracts\Queue\CrossTenantJob;
use App\Contracts\Queue\TenantAwareJob;
use App\Exceptions\Queue\UnauthorizedCrossTenantDispatchException;
use App\Exceptions\Queue\UnscopedJobException;
use App\Jobs\Middleware\ScopeJobToTenant;
use App\Models\Church;
use App\Models\User;
use App\Traits\Queue\CrossTenantJobTrait;
use App\Traits\Queue\TenantAwareJobTrait;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use RuntimeException;
use Tests\TestCase;

class TenantAwareJobScopingTest extends TestCase
{
    use RefreshDatabase;

    public function test_tenant_aware_job_binds_context_and_team_id_during_execution(): void
    {
        $church = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Balige',
            'slug' => 'hkbp-balige',
            'status' => 'active',
        ]);

        $executed = false;
        $capturedChurchId = null;
        $capturedTeamId = null;

        $job = new TestTenantAwareJob($church->id, function ($cId, $tId) use (&$executed, &$capturedChurchId, &$capturedTeamId) {
            $executed = true;
            $capturedChurchId = $cId;
            $capturedTeamId = $tId;
        });

        $middleware = new ScopeJobToTenant;
        $middleware->handle($job, fn ($j) => $j->handle());

        $this->assertTrue($executed);
        $this->assertEquals($church->id, $capturedChurchId);
        $this->assertEquals($church->id, $capturedTeamId);
    }

    public function test_worker_context_is_completely_cleared_after_job_finishes(): void
    {
        $church = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Tarutung',
            'slug' => 'hkbp-tarutung',
            'status' => 'active',
        ]);

        $job = new TestTenantAwareJob($church->id);

        $middleware = new ScopeJobToTenant;
        $middleware->handle($job, fn ($j) => $j->handle());

        // Worker context MUST be completely clean
        $this->assertFalse(app()->bound('current_church_id'));
        $this->assertFalse(app()->bound('current_church'));
        $this->assertNull(getPermissionsTeamId());
    }

    public function test_worker_context_is_cleared_even_when_job_throws_exception(): void
    {
        $church = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Medan',
            'slug' => 'hkbp-medan',
            'status' => 'active',
        ]);

        $job = new TestFailingJob($church->id);
        $middleware = new ScopeJobToTenant;

        try {
            $middleware->handle($job, fn ($j) => $j->handle());
            $this->fail('Expected RuntimeException was not thrown.');
        } catch (RuntimeException $e) {
            $this->assertEquals('Catastrophic failure inside job', $e->getMessage());
        }

        // Even after crash, worker context MUST be clean
        $this->assertFalse(app()->bound('current_church_id'));
        $this->assertFalse(app()->bound('current_church'));
        $this->assertNull(getPermissionsTeamId());
    }

    public function test_unscoped_job_fails_loudly_with_unscoped_job_exception(): void
    {
        $job = new TestUnscopedJob;
        $middleware = new ScopeJobToTenant;

        $this->expectException(UnscopedJobException::class);
        $this->expectExceptionMessage('must implement either TenantAwareJob or CrossTenantJob');

        $middleware->handle($job, fn ($j) => $j->handle());
    }

    public function test_tenant_aware_job_fails_if_church_tenant_is_suspended(): void
    {
        $church = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Suspended',
            'slug' => 'hkbp-suspended',
            'status' => 'suspended',
        ]);

        $job = new TestTenantAwareJob($church->id);
        $middleware = new ScopeJobToTenant;

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage('is not active or does not exist');

        $middleware->handle($job, fn ($j) => $j->handle());
    }

    public function test_cross_tenant_job_succeeds_when_dispatched_by_active_super_admin(): void
    {
        $superAdmin = User::factory()->create(['is_super_admin' => true]);

        $job = new TestCrossTenantJob($superAdmin->id, false);

        $middleware = new ScopeJobToTenant;
        $result = $middleware->handle($job, fn ($j) => $j->handle());

        $this->assertTrue($result);
        $this->assertFalse(app()->bound('current_church_id'));
    }

    public function test_cross_tenant_job_fails_if_super_admin_privilege_revoked_before_execution(): void
    {
        // User is Super Admin at dispatch time
        $user = User::factory()->create(['is_super_admin' => true]);

        $job = new TestCrossTenantJob($user->id, false);

        // Revoke super admin status BEFORE worker execution
        $user->update(['is_super_admin' => false]);

        $middleware = new ScopeJobToTenant;

        $this->expectException(UnauthorizedCrossTenantDispatchException::class);
        $this->expectExceptionMessage('is no longer an active Super Admin at execution time');

        $middleware->handle($job, fn ($j) => $j->handle());
    }

    public function test_cross_tenant_job_fails_at_dispatch_time_if_dispatched_by_regular_user(): void
    {
        $regularUser = User::factory()->create(['is_super_admin' => false]);
        $this->actingAs($regularUser);

        $this->expectException(UnauthorizedCrossTenantDispatchException::class);
        $this->expectExceptionMessage('Only Super Administrators are authorized to dispatch cross-tenant background jobs.');

        new TestDispatchTimeCrossTenantJob;
    }

    public function test_cross_tenant_job_fails_when_dispatched_without_authenticated_user_outside_console_context(): void
    {
        // Simulate non-console HTTP web environment
        $ref = new \ReflectionProperty($this->app, 'isRunningInConsole');
        $ref->setValue($this->app, false);

        try {
            // Ensure no user is authenticated (guest/unauthenticated HTTP context)
            auth()->logout();

            $this->expectException(UnauthorizedCrossTenantDispatchException::class);
            $this->expectExceptionMessage('Only Super Administrators are authorized to dispatch cross-tenant background jobs.');

            new TestDispatchTimeCrossTenantJob;
        } finally {
            // Restore console environment state
            $ref->setValue($this->app, true);
        }
    }

    public function test_cross_tenant_job_succeeds_when_dispatched_by_system(): void
    {
        $job = new TestCrossTenantJob(null, true);

        $middleware = new ScopeJobToTenant;
        $result = $middleware->handle($job, fn ($j) => $j->handle());

        $this->assertTrue($result);
        $this->assertFalse(app()->bound('current_church_id'));
    }
}

class TestTenantAwareJob implements TenantAwareJob
{
    use TenantAwareJobTrait;

    protected $callback;

    public function __construct(int $churchId, ?callable $callback = null)
    {
        $this->churchId = $churchId;
        $this->callback = $callback;
    }

    public function handle(): void
    {
        if ($this->callback) {
            ($this->callback)(
                app()->bound('current_church_id') ? app('current_church_id') : null,
                getPermissionsTeamId()
            );
        }
    }
}

class TestFailingJob implements TenantAwareJob
{
    use TenantAwareJobTrait;

    public function __construct(int $churchId)
    {
        $this->churchId = $churchId;
    }

    public function handle(): void
    {
        throw new RuntimeException('Catastrophic failure inside job');
    }
}

class TestUnscopedJob
{
    public function handle(): void
    {
        // Unscoped
    }
}

class TestCrossTenantJob implements CrossTenantJob
{
    use CrossTenantJobTrait;

    public function __construct(?int $userId = null, bool $isSystem = false)
    {
        $this->dispatchedByUserId = $userId;
        $this->isSystemDispatched = $isSystem;
    }

    public function handle(): bool
    {
        return true;
    }
}

class TestDispatchTimeCrossTenantJob implements CrossTenantJob
{
    use CrossTenantJobTrait;

    public function __construct()
    {
        $this->initCrossTenantDispatcher();
    }

    public function handle(): void
    {
        // no-op
    }
}
