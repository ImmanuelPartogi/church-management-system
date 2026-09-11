<?php

namespace Tests\Feature\Theme;

use App\Filament\Pages\ManageChurchTheme;
use App\Models\Church;
use App\Models\ChurchUserMembership;
use App\Models\User;
use Database\Seeders\ModuleSeeder;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Str;
use Livewire\Livewire;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class ChurchThemeAuthorizationTest extends TestCase
{
    use RefreshDatabase;

    protected Church $churchA;

    protected Church $churchB;

    protected User $adminA;

    protected User $adminB;

    protected User $superAdmin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(RolesAndPermissionsSeeder::class);
        $this->seed(ModuleSeeder::class);

        $this->churchA = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Church Alpha',
            'slug' => 'hkbp-alpha',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'theme_primary_color' => '#1B4B66',
            'theme_secondary_color' => '#F5A623',
            'theme_version' => 1,
        ]);

        $this->churchB = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Church Beta',
            'slug' => 'hkbp-beta',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'theme_primary_color' => '#1B4B66',
            'theme_secondary_color' => '#F5A623',
            'theme_version' => 1,
        ]);

        $this->superAdmin = User::create([
            'name' => 'Super Admin',
            'email' => 'super@synod.org',
            'password' => bcrypt('password'),
            'is_super_admin' => true,
        ]);

        $this->adminA = User::create([
            'name' => 'Admin Alpha',
            'email' => 'admin.alpha@church.org',
            'password' => bcrypt('password'),
            'is_super_admin' => false,
        ]);

        $this->adminB = User::create([
            'name' => 'Admin Beta',
            'email' => 'admin.beta@church.org',
            'password' => bcrypt('password'),
            'is_super_admin' => false,
        ]);

        // Memberships
        ChurchUserMembership::create([
            'church_id' => $this->churchA->id,
            'user_id' => $this->adminA->id,
            'role' => 'church_admin',
            'status' => 'active',
        ]);

        ChurchUserMembership::create([
            'church_id' => $this->churchB->id,
            'user_id' => $this->adminB->id,
            'role' => 'church_admin',
            'status' => 'active',
        ]);

        // Create team-scoped roles
        Role::firstOrCreate(['name' => 'church_admin', 'guard_name' => 'web', 'church_id' => $this->churchA->id]);
        Role::firstOrCreate(['name' => 'church_admin', 'guard_name' => 'web', 'church_id' => $this->churchB->id]);

        // Assign Spatie role with team scoping
        setPermissionsTeamId($this->churchA->id);
        $this->adminA->assignRole('church_admin');

        setPermissionsTeamId($this->churchB->id);
        $this->adminB->assignRole('church_admin');
    }

    /**
     * Test 1 (Happy Path): church_admin can update theme for their own actively resolved church.
     */
    public function test_church_admin_can_update_theme_for_own_active_church(): void
    {
        // Bind canonical tenant context
        app()->instance('current_church_id', $this->churchA->id);
        setPermissionsTeamId($this->churchA->id);

        $this->assertTrue(Gate::forUser($this->adminA)->allows('updateTheme', $this->churchA));

        Livewire::actingAs($this->adminA)
            ->test(ManageChurchTheme::class)
            ->assertSuccessful()
            ->set('data.theme_primary_color', '#0F2C3F')
            ->set('data.theme_secondary_color', '#E58A1F')
            ->call('save')
            ->assertHasNoErrors();

        $this->churchA->refresh();
        $this->assertSame('#0F2C3F', $this->churchA->theme_primary_color);
        $this->assertSame('#E58A1F', $this->churchA->theme_secondary_color);
        $this->assertSame(2, $this->churchA->theme_version);
    }

    /**
     * Test 2 (Cross-Tenant Rejection): church_admin is rejected from updating theme of another church.
     */
    public function test_church_admin_cannot_update_theme_of_another_church_cross_tenant(): void
    {
        // Admin A has context of Church A
        app()->instance('current_church_id', $this->churchA->id);
        setPermissionsTeamId($this->churchA->id);

        // Attempting to authorize updateTheme for Church B must be strictly FORBIDDEN
        $this->assertFalse(Gate::forUser($this->adminA)->allows('updateTheme', $this->churchB));
    }

    /**
     * Test 3 (Anti-Tampering): church_admin cannot tamper with slug or status during theme save.
     */
    public function test_church_admin_cannot_tamper_with_slug_or_status_via_payload_injection(): void
    {
        app()->instance('current_church_id', $this->churchA->id);
        setPermissionsTeamId($this->churchA->id);

        Livewire::actingAs($this->adminA)
            ->test(ManageChurchTheme::class)
            ->assertSuccessful()
            ->set('data.theme_primary_color', '#2E7D32')
            ->set('data.slug', 'malicious-injected-slug')
            ->set('data.status', 'suspended')
            ->call('save')
            ->assertHasNoErrors();

        $this->churchA->refresh();
        $this->assertSame('#2E7D32', $this->churchA->theme_primary_color);
        $this->assertSame('hkbp-alpha', $this->churchA->slug); // UNCHANGED!
        $this->assertSame('active', $this->churchA->status);     // UNCHANGED!
    }

    /**
     * Test 4 (WCAG Contrast Warning): Low-contrast color combinations trigger warning notifications.
     */
    public function test_low_contrast_colors_trigger_wcag_contrast_warning_notification(): void
    {
        app()->instance('current_church_id', $this->churchA->id);
        setPermissionsTeamId($this->churchA->id);

        // Bright yellow (#FFFF00) has contrast ratio < 4.5 against white (#FFFFFF)
        Livewire::actingAs($this->adminA)
            ->test(ManageChurchTheme::class)
            ->set('data.theme_primary_color', '#FFFF00')
            ->call('save')
            ->assertNotified();
    }

    /**
     * Test 5 (Super Admin Access): Super Admin can update any church theme without restriction.
     */
    public function test_super_admin_can_update_theme_for_any_church(): void
    {
        $this->assertTrue(Gate::forUser($this->superAdmin)->allows('updateTheme', $this->churchA));
        $this->assertTrue(Gate::forUser($this->superAdmin)->allows('updateTheme', $this->churchB));
    }
}
