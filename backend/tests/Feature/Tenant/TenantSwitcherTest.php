<?php

namespace Tests\Feature\Tenant;

use App\Livewire\TenantSwitcher;
use App\Models\Church;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Livewire\Livewire;
use Tests\TestCase;

class TenantSwitcherTest extends TestCase
{
    use RefreshDatabase;

    private Church $churchA;

    private Church $churchB;

    private Church $suspendedChurch;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);

        $this->churchA = Church::firstOrCreate(
            ['slug' => (string) config('tenant.default_church_slug', 'default')],
            [
                'uuid' => (string) Str::uuid(),
                'name' => 'HKBP Church Alpha',
                'status' => 'active',
                'timezone' => 'Asia/Jakarta',
            ]
        );

        $this->churchB = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Church Beta',
            'slug' => 'hkbp-beta',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        $this->suspendedChurch = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Suspended',
            'slug' => 'hkbp-suspended',
            'status' => 'suspended',
            'timezone' => 'Asia/Jakarta',
        ]);
    }

    public function test_super_admin_can_switch_tenant_via_livewire(): void
    {
        $superAdmin = User::factory()->create(['is_super_admin' => true]);

        Livewire::actingAs($superAdmin)
            ->test(TenantSwitcher::class)
            ->call('switchTenant', $this->churchB->id)
            ->assertRedirect('/admin');

        $this->assertSame($this->churchB->id, session('active_church_id'));
    }

    public function test_subsequent_request_resolves_switched_church_context(): void
    {
        $superAdmin = User::factory()->create(['is_super_admin' => true]);

        $this->actingAs($superAdmin)
            ->withSession(['active_church_id' => $this->churchB->id])
            ->get('/admin')
            ->assertSuccessful();

        $this->assertSame($this->churchB->id, app('current_church_id'));
        $this->assertSame($this->churchB->id, app('current_church')->id);
    }

    public function test_non_super_admin_is_forbidden_from_switching_tenants(): void
    {
        $churchAdmin = User::factory()->create(['is_super_admin' => false]);
        $churchAdmin->assignRole('church_admin');

        Livewire::actingAs($churchAdmin)
            ->test(TenantSwitcher::class)
            ->call('switchTenant', $this->churchB->id)
            ->assertForbidden();
    }

    public function test_cannot_switch_to_suspended_church(): void
    {
        $superAdmin = User::factory()->create(['is_super_admin' => true]);

        $this->expectException(ModelNotFoundException::class);

        Livewire::actingAs($superAdmin)
            ->test(TenantSwitcher::class)
            ->call('switchTenant', $this->suspendedChurch->id);
    }

    public function test_switcher_view_renders_selection_menu_only_for_super_admin(): void
    {
        $superAdmin = User::factory()->create(['is_super_admin' => true]);
        $regularAdmin = User::factory()->create(['is_super_admin' => false]);

        // Super Admin sees the switcher dropdown
        Livewire::actingAs($superAdmin)
            ->test(TenantSwitcher::class)
            ->assertSee('Pilih Gereja (Super Admin)')
            ->assertSee($this->churchA->name)
            ->assertSee($this->churchB->name);

        // Regular user does not see the switcher dropdown
        Livewire::actingAs($regularAdmin)
            ->test(TenantSwitcher::class)
            ->assertDontSee('Pilih Gereja (Super Admin)');
    }
}
