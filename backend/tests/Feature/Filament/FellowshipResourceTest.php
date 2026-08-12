<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\FellowshipResource;
use App\Models\Fellowship;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class FellowshipResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_pastor_can_render_fellowship_list(): void
    {
        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        $fellowship = Fellowship::factory()->create();

        $this->actingAs($pastor)
            ->get(FellowshipResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($pastor)
            ->test(FellowshipResource\Pages\ListFellowships::class)
            ->assertCanSeeTableRecords([$fellowship]);
    }

    public function test_unauthorized_user_cannot_access_fellowships(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(FellowshipResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_pastor_can_create_fellowship(): void
    {
        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        Livewire::actingAs($pastor)
            ->test(FellowshipResource\Pages\CreateFellowship::class)
            ->fillForm([
                'name' => 'Punguan Naposobulung (HKBP Youth)',
                'code' => 'NHKB',
                'description' => 'Kategori pemuda pemudi gereja',
                'active' => true,
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('fellowships', [
            'name' => 'Punguan Naposobulung (HKBP Youth)',
            'code' => 'NHKB',
        ]);
    }
}
