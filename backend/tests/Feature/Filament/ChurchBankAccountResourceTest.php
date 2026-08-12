<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\ChurchBankAccountResource;
use App\Models\ChurchBankAccount;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class ChurchBankAccountResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_treasurer_can_render_bank_account_list(): void
    {
        $treasurer = User::factory()->create();
        $treasurer->assignRole('bendahara');

        $account = ChurchBankAccount::factory()->create();

        $this->actingAs($treasurer)
            ->get(ChurchBankAccountResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($treasurer)
            ->test(ChurchBankAccountResource\Pages\ListChurchBankAccounts::class)
            ->assertCanSeeTableRecords([$account]);
    }

    public function test_unauthorized_user_cannot_access_bank_accounts(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(ChurchBankAccountResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_treasurer_can_create_bank_account(): void
    {
        $treasurer = User::factory()->create();
        $treasurer->assignRole('bendahara');

        Livewire::actingAs($treasurer)
            ->test(ChurchBankAccountResource\Pages\CreateChurchBankAccount::class)
            ->fillForm([
                'bank_name' => 'Bank Mandiri',
                'account_number' => '1234567890',
                'account_holder_name' => 'Gereja HKBP',
                'display_order' => 1,
                'is_active' => true,
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('church_bank_accounts', [
            'bank_name' => 'Bank Mandiri',
            'account_number' => '1234567890',
        ]);
    }
}
