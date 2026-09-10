<?php

namespace Tests\Unit\Tenant;

use App\Services\Tenant\TenantBackfillService;
use PHPUnit\Framework\TestCase;

class RoleMappingPriorityTest extends TestCase
{
    private TenantBackfillService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new TenantBackfillService;
    }

    public function test_admin_and_super_admin_map_to_church_admin(): void
    {
        $this->assertSame('church_admin', $this->service->resolveMembershipRole(['church_admin']));
        $this->assertSame('church_admin', $this->service->resolveMembershipRole(['admin']));
        $this->assertSame('church_admin', $this->service->resolveMembershipRole(['super_admin']));
        $this->assertSame('church_admin', $this->service->resolveMembershipRole(['church_admin', 'pastor']));
        $this->assertSame('church_admin', $this->service->resolveMembershipRole(['admin', 'pastor']));
        $this->assertSame('church_admin', $this->service->resolveMembershipRole(['member', 'church_admin']));
        $this->assertSame('church_admin', $this->service->resolveMembershipRole(['member', 'admin']));
    }

    public function test_pastor_has_priority_over_bendahara_staff_and_member(): void
    {
        $this->assertSame('pastor', $this->service->resolveMembershipRole(['pastor']));
        $this->assertSame('pastor', $this->service->resolveMembershipRole(['pastor', 'bendahara']));
        $this->assertSame('pastor', $this->service->resolveMembershipRole(['pastor', 'staff', 'member']));
    }

    public function test_bendahara_has_priority_over_staff_and_member(): void
    {
        $this->assertSame('bendahara', $this->service->resolveMembershipRole(['bendahara']));
        $this->assertSame('bendahara', $this->service->resolveMembershipRole(['bendahara', 'staff']));
        $this->assertSame('bendahara', $this->service->resolveMembershipRole(['bendahara', 'member']));
    }

    public function test_staff_has_priority_over_member(): void
    {
        $this->assertSame('staff', $this->service->resolveMembershipRole(['staff']));
        $this->assertSame('staff', $this->service->resolveMembershipRole(['staff', 'member']));
    }

    public function test_empty_roles_default_to_member(): void
    {
        $this->assertSame('member', $this->service->resolveMembershipRole([]));
        $this->assertSame('member', $this->service->resolveMembershipRole(['unknown_role']));
    }
}
