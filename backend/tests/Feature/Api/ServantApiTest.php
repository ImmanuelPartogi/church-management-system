<?php

namespace Tests\Feature\Api;

use App\Enums\ChurchServantRole;
use App\Models\ChurchServant;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ServantApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_active_church_servants(): void
    {
        ChurchServant::factory()->create([
            'name' => 'Pdt. Stiven Hutapea',
            'role' => ChurchServantRole::PdtResort,
            'active' => true,
        ]);

        ChurchServant::factory()->create([
            'name' => 'St. Maria Simanjuntak',
            'role' => ChurchServantRole::Sintua,
            'active' => true,
        ]);

        ChurchServant::factory()->create([
            'name' => 'Non Active Servant',
            'active' => false,
        ]);

        $response = $this->getJson('/api/v1/servants');

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data')
            ->assertJsonFragment([
                'name' => 'Pdt. Stiven Hutapea',
                'role' => 'pdt_resort',
                'role_label' => 'Pendeta Resort',
            ]);
    }

    public function test_can_filter_servants_by_search_and_role(): void
    {
        ChurchServant::factory()->create([
            'name' => 'Pdt. Stiven Hutapea',
            'role' => ChurchServantRole::PdtResort,
            'active' => true,
        ]);

        ChurchServant::factory()->create([
            'name' => 'St. Maria Simanjuntak',
            'role' => ChurchServantRole::Sintua,
            'active' => true,
        ]);

        $response = $this->getJson('/api/v1/servants?search=Stiven');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonFragment(['name' => 'Pdt. Stiven Hutapea']);

        $roleResponse = $this->getJson('/api/v1/servants?role=sintua');

        $roleResponse->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonFragment(['name' => 'St. Maria Simanjuntak']);
    }

    public function test_can_view_single_servant_detail(): void
    {
        $servant = ChurchServant::factory()->create([
            'name' => 'Pdt. Stiven Hutapea',
            'role' => ChurchServantRole::PdtResort,
            'active' => true,
        ]);

        $response = $this->getJson("/api/v1/servants/{$servant->id}");

        $response->assertStatus(200)
            ->assertJsonPath('data.id', $servant->id)
            ->assertJsonPath('data.name', 'Pdt. Stiven Hutapea');
    }
}
