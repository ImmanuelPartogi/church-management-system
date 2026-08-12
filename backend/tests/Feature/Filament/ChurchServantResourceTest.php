<?php

namespace Tests\Feature\Filament;

use App\Enums\ChurchServantRole;
use App\Filament\Resources\ChurchServantResource;
use App\Models\ChurchMember;
use App\Models\ChurchServant;
use App\Models\Sector;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class ChurchServantResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_pastor_can_render_church_servant_list(): void
    {
        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        $servant = ChurchServant::factory()->create();

        $this->actingAs($pastor)
            ->get(ChurchServantResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($pastor)
            ->test(ChurchServantResource\Pages\ListChurchServants::class)
            ->assertCanSeeTableRecords([$servant]);
    }

    public function test_unauthorized_user_cannot_access_church_servants(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(ChurchServantResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_pastor_can_create_church_servant(): void
    {
        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        $member = ChurchMember::factory()->create();
        $sector = Sector::factory()->create();

        Livewire::actingAs($pastor)
            ->test(ChurchServantResource\Pages\CreateChurchServant::class)
            ->fillForm([
                'member_id' => $member->id,
                'name' => 'St. Johannes Pardede',
                'role' => 'sintua',
                'phone' => '08123456789',
                'email' => 'sintua@example.com',
                'sector_id' => $sector->id,
                'description' => 'Sintua Penanggung Jawab Sektor 1',
                'active' => true,
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('church_servants', [
            'name' => 'St. Johannes Pardede',
            'role' => ChurchServantRole::Sintua->value,
            'member_id' => $member->id,
        ]);
    }
}
