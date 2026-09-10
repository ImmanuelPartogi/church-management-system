<?php

namespace Tests\Feature\Auth;

use App\Models\Announcement;
use App\Models\User;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class SuperAdminBypassTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        // Create roles and permissions for non-super-admin tests
        $role = Role::firstOrCreate(['name' => 'member']);
        Permission::firstOrCreate(['name' => 'manage announcements']);
        Permission::firstOrCreate(['name' => 'view announcements']);
    }

    /**
     * Test: Super admin bypasses all Gate/Policy checks without any role or permission.
     */
    public function test_super_admin_bypasses_policy_without_any_role(): void
    {
        $superAdmin = User::factory()->create(['is_super_admin' => true]);
        // No roles assigned, no permissions assigned

        $this->assertTrue($superAdmin->can('manage announcements'));
        $this->assertTrue($superAdmin->can('viewAny', Announcement::class));
    }

    /**
     * Test: Non-super-admin without permissions is denied by policy.
     */
    public function test_non_super_admin_without_permissions_is_denied(): void
    {
        $normalUser = User::factory()->create(['is_super_admin' => false]);
        // No roles assigned, no permissions assigned

        $this->assertFalse($normalUser->can('manage announcements'));
        $this->assertFalse($normalUser->can('viewAny', Announcement::class));
    }

    /**
     * Test: Super admin can access Filament panel via canAccessPanel().
     * This proves the is_super_admin early return works even though
     * Gate::before does NOT intercept hasAnyRole().
     */
    public function test_super_admin_can_access_filament_panel(): void
    {
        $superAdmin = User::factory()->create(['is_super_admin' => true]);
        // No roles assigned — hasAnyRole() would return false

        $panel = Filament::getDefaultPanel();
        $this->assertTrue($superAdmin->canAccessPanel($panel));
    }

    /**
     * Test: Non-super-admin with correct role can access panel.
     */
    public function test_non_super_admin_with_correct_role_can_access_panel(): void
    {
        $user = User::factory()->create(['is_super_admin' => false]);
        Role::firstOrCreate(['name' => 'pastor']);
        $user->assignRole('pastor');

        $panel = Filament::getDefaultPanel();
        $this->assertTrue($user->canAccessPanel($panel));
    }

    /**
     * Test: Non-super-admin without correct role cannot access panel.
     */
    public function test_non_super_admin_member_cannot_access_panel(): void
    {
        $user = User::factory()->create(['is_super_admin' => false]);
        $user->assignRole('member');

        $panel = Filament::getDefaultPanel();
        $this->assertFalse($user->canAccessPanel($panel));
    }
}
