<?php

namespace Tests\Feature\Filament;

use App\Enums\FinanceAccountType;
use App\Filament\Resources\ChartOfAccountResource;
use App\Models\ChartOfAccount;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class ChartOfAccountResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_treasurer_can_render_chart_of_accounts_list(): void
    {
        $treasurer = User::factory()->create();
        $treasurer->assignRole('bendahara');

        $account = ChartOfAccount::factory()->create();

        $this->actingAs($treasurer)
            ->get(ChartOfAccountResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($treasurer)
            ->test(ChartOfAccountResource\Pages\ListChartOfAccounts::class)
            ->assertCanSeeTableRecords([$account]);
    }

    public function test_unauthorized_user_cannot_access_chart_of_accounts(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(ChartOfAccountResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_treasurer_can_create_chart_of_account(): void
    {
        $treasurer = User::factory()->create();
        $treasurer->assignRole('bendahara');

        Livewire::actingAs($treasurer)
            ->test(ChartOfAccountResource\Pages\CreateChartOfAccount::class)
            ->fillForm([
                'code' => '401-PERSEMBAHAN',
                'name' => 'Persembahan Kebaktian Minggu',
                'type' => 'income',
                'description' => 'Kantong persembahan ibadah minggu',
                'is_active' => true,
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('chart_of_accounts', [
            'code' => '401-PERSEMBAHAN',
            'type' => FinanceAccountType::Income->value,
        ]);
    }
}
