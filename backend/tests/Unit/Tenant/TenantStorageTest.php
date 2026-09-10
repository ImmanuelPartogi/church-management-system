<?php

namespace Tests\Unit\Tenant;

use App\Support\TenantStorage;
use Tests\TestCase;

class TenantStorageTest extends TestCase
{
    public function test_path_generates_tenant_partitioned_path_from_container_context(): void
    {
        app()->instance('current_church_id', 42);

        $path = TenantStorage::path('announcements');
        $this->assertEquals('tenants/42/announcements', $path);

        $nestedPath = TenantStorage::path('/sermons/audio/');
        $this->assertEquals('tenants/42/sermons/audio', $nestedPath);
    }

    public function test_path_respects_explicit_church_id_override(): void
    {
        app()->instance('current_church_id', 1);

        $path = TenantStorage::path('donation_proofs', churchId: 99);
        $this->assertEquals('tenants/99/donation_proofs', $path);
    }

    public function test_path_falls_back_to_global_when_no_tenant_context_bound(): void
    {
        app()->forgetInstance('current_church_id');

        $path = TenantStorage::path('wartas');
        $this->assertEquals('tenants/global/wartas', $path);
    }
}
