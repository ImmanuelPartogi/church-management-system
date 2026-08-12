<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\SectorResource;
use App\Models\Resort;
use App\Models\Sector;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class SectorResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_pastor_can_render_sector_list(): void
    {
        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        $sector = Sector::factory()->create();

        $this->actingAs($pastor)
            ->get(SectorResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($pastor)
            ->test(SectorResource\Pages\ListSectors::class)
            ->assertCanSeeTableRecords([$sector]);
    }

    public function test_unauthorized_user_cannot_access_sectors(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(SectorResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_pastor_can_create_sector(): void
    {
        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        $resort = Resort::factory()->create();

        Livewire::actingAs($pastor)
            ->test(SectorResource\Pages\CreateSector::class)
            ->fillForm([
                'resort_id' => $resort->id,
                'name' => 'Wijk III Teladan',
                'code' => 'WJK-03',
                'description' => 'Sektor Wilayah Teladan',
                'active' => true,
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('sectors', [
            'name' => 'Wijk III Teladan',
            'resort_id' => $resort->id,
        ]);
    }
}
