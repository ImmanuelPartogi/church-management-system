<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\ChurchResource;
use App\Models\Announcement;
use App\Models\Church;
use App\Models\User;
use App\Policies\ChurchPolicy;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Str;
use Livewire\Livewire;
use Tests\TestCase;

class ChurchResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_super_admin_can_render_church_list(): void
    {
        $superAdmin = User::factory()->create(['is_super_admin' => true]);

        $church = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Tarutung Resort',
            'slug' => 'hkbp-tarutung',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        $this->actingAs($superAdmin)
            ->get(ChurchResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($superAdmin)
            ->test(ChurchResource\Pages\ListChurches::class)
            ->assertCanSeeTableRecords([$church]);
    }

    public function test_non_super_admin_with_church_admin_role_is_forbidden_from_church_resource(): void
    {
        $churchAdmin = User::factory()->create(['is_super_admin' => false]);
        $churchAdmin->assignRole('church_admin');

        $this->actingAs($churchAdmin)
            ->get(ChurchResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_regular_member_is_forbidden_from_church_resource(): void
    {
        $member = User::factory()->create(['is_super_admin' => false]);
        $member->assignRole('member');

        $this->actingAs($member)
            ->get(ChurchResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_super_admin_can_create_new_church(): void
    {
        $superAdmin = User::factory()->create(['is_super_admin' => true]);

        Livewire::actingAs($superAdmin)
            ->test(ChurchResource\Pages\CreateChurch::class)
            ->fillForm([
                'name' => 'Gereja HKBP Surabaya Resort',
                'slug' => 'hkbp-surabaya',
                'status' => 'active',
                'timezone' => 'Asia/Jakarta',
                'phone' => '+6281234567899',
                'address' => 'Jl. Diponegoro No. 1, Surabaya',
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('churches', [
            'name' => 'Gereja HKBP Surabaya Resort',
            'slug' => 'hkbp-surabaya',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        $created = Church::where('slug', 'hkbp-surabaya')->first();
        $this->assertNotNull($created);
        $this->assertNotNull($created->uuid);
    }

    public function test_super_admin_can_toggle_church_status(): void
    {
        $superAdmin = User::factory()->create(['is_super_admin' => true]);

        $church = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Medan Kota',
            'slug' => 'hkbp-medan-kota',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        // Toggle active -> suspended
        Livewire::actingAs($superAdmin)
            ->test(ChurchResource\Pages\ListChurches::class)
            ->callTableAction('toggleStatus', $church);

        $this->assertSame('suspended', $church->fresh()->status);

        // Toggle suspended -> active
        Livewire::actingAs($superAdmin)
            ->test(ChurchResource\Pages\ListChurches::class)
            ->callTableAction('toggleStatus', $church);

        $this->assertSame('active', $church->fresh()->status);
    }

    public function test_church_deletion_is_strictly_forbidden_via_gate_and_resource(): void
    {
        $superAdmin = User::factory()->create(['is_super_admin' => true]);

        $church = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Protected',
            'slug' => 'hkbp-protected',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        // 1. Resource hooks return false
        $this->assertFalse(ChurchResource::canDelete($church));
        $this->assertFalse(ChurchResource::canDeleteAny());
        $this->assertFalse(ChurchResource::canForceDelete($church));

        // 2. Gate permanently denies delete for Church even for super admin
        $this->assertFalse(Gate::forUser($superAdmin)->allows('delete', $church));
        $this->assertFalse(Gate::forUser($superAdmin)->allows('forceDelete', $church));
        $this->assertTrue(Gate::forUser($superAdmin)->denies('delete', $church));
        $this->assertTrue(Gate::forUser($superAdmin)->denies('forceDelete', $church));
        $this->assertTrue(Gate::forUser($superAdmin)->denies('delete', Church::class));

        // 3. ChurchPolicy directly returns false
        $policy = new ChurchPolicy;
        $this->assertFalse($policy->delete($superAdmin, $church));
        $this->assertFalse($policy->forceDelete($superAdmin, $church));

        // 4. Verify super admin CAN still delete other models (e.g. Announcement) without restriction
        $announcement = Announcement::create([
            'title' => 'Sample Announcement',
            'content' => 'Sample content',
            'status' => 'published',
        ]);
        $this->assertTrue(Gate::forUser($superAdmin)->allows('delete', $announcement));
    }

    public function test_slug_is_disabled_on_edit_form(): void
    {
        $superAdmin = User::factory()->create(['is_super_admin' => true]);

        $church = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Immutable Slug',
            'slug' => 'hkbp-immutable',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        Livewire::actingAs($superAdmin)
            ->test(ChurchResource\Pages\EditChurch::class, ['record' => $church->getRouteKey()])
            ->assertFormFieldIsDisabled('slug');
    }
}
