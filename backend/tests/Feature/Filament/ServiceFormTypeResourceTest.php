<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\ServiceFormTypeResource;
use App\Models\ServiceFormType;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class ServiceFormTypeResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_admin_can_render_service_form_type_list(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('church_admin');

        $type = ServiceFormType::factory()->create();

        $this->actingAs($admin)
            ->get(ServiceFormTypeResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($admin)
            ->test(ServiceFormTypeResource\Pages\ListServiceFormTypes::class)
            ->assertCanSeeTableRecords([$type]);
    }

    public function test_unauthorized_user_cannot_access_service_form_types(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(ServiceFormTypeResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_admin_can_create_service_form_type(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('church_admin');

        Livewire::actingAs($admin)
            ->test(ServiceFormTypeResource\Pages\CreateServiceFormType::class)
            ->fillForm([
                'name' => 'Formulir Baptis Kudus',
                'slug' => 'baptis-kudus',
                'description' => 'Persyaratan pendaftaran Baptis Kudus',
                'fee_amount' => 50000,
                'active' => true,
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('service_form_types', [
            'slug' => 'baptis-kudus',
            'fee_amount' => 50000,
        ]);
    }
}
