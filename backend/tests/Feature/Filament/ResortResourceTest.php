<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\ResortResource;
use App\Models\Resort;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class ResortResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_pastor_can_render_resort_list(): void
    {
        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        $resort = Resort::factory()->create();

        $this->actingAs($pastor)
            ->get(ResortResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($pastor)
            ->test(ResortResource\Pages\ListResorts::class)
            ->assertCanSeeTableRecords([$resort]);
    }

    public function test_unauthorized_user_cannot_access_resorts(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(ResortResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_pastor_can_create_resort(): void
    {
        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        Livewire::actingAs($pastor)
            ->test(ResortResource\Pages\CreateResort::class)
            ->fillForm([
                'name' => 'Resort Medan II',
                'code' => 'RST-MDN-02',
                'description' => 'Resort HKBP Wilayah Medan 2',
                'active' => true,
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('resorts', [
            'name' => 'Resort Medan II',
            'code' => 'RST-MDN-02',
        ]);
    }
}
