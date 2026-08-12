<?php

namespace Tests\Feature\Filament;

use App\Enums\DonationStatus;
use App\Enums\FinanceAccountType;
use App\Filament\Resources\DonationConfirmationResource;
use App\Models\ChartOfAccount;
use App\Models\DonationConfirmation;
use App\Models\FinancialTransaction;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class DonationConfirmationResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_treasurer_can_render_donation_confirmations_list(): void
    {
        $treasurer = User::factory()->create();
        $treasurer->assignRole('bendahara');

        $donation = DonationConfirmation::factory()->create();

        $this->actingAs($treasurer)
            ->get(DonationConfirmationResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($treasurer)
            ->test(DonationConfirmationResource\Pages\ListDonationConfirmations::class)
            ->assertCanSeeTableRecords([$donation]);
    }

    public function test_unauthorized_user_cannot_access_donations(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(DonationConfirmationResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_treasurer_can_approve_donation_and_atomic_ledger_creation(): void
    {
        $treasurer = User::factory()->create();
        $treasurer->assignRole('bendahara');

        $chart = ChartOfAccount::factory()->create(['type' => FinanceAccountType::Income]);

        $donation = DonationConfirmation::factory()->create([
            'status' => DonationStatus::Processing,
            'chart_of_account_id' => $chart->id,
            'amount' => 500000.00,
        ]);

        Livewire::actingAs($treasurer)
            ->test(DonationConfirmationResource\Pages\ViewDonationConfirmation::class, [
                'record' => $donation->getRouteKey(),
            ])
            ->callAction('approve')
            ->assertHasNoActionErrors();

        $donation->refresh();

        $this->assertEquals(DonationStatus::Approved, $donation->status);
        $this->assertEquals($treasurer->id, $donation->reviewed_by);
        $this->assertNotNull($donation->reviewed_at);

        // Verify atomic creation of financial transaction
        $this->assertDatabaseHas('financial_transactions', [
            'donation_confirmation_id' => $donation->id,
            'chart_of_account_id' => $chart->id,
            'amount' => 500000.00,
            'type' => FinanceAccountType::Income->value,
        ]);

        $this->assertEquals(1, FinancialTransaction::where('donation_confirmation_id', $donation->id)->count());
    }

    public function test_treasurer_can_reject_donation_with_reason(): void
    {
        $treasurer = User::factory()->create();
        $treasurer->assignRole('bendahara');

        $donation = DonationConfirmation::factory()->create([
            'status' => DonationStatus::Processing,
        ]);

        Livewire::actingAs($treasurer)
            ->test(DonationConfirmationResource\Pages\ViewDonationConfirmation::class, [
                'record' => $donation->getRouteKey(),
            ])
            ->callAction('reject', [
                'rejection_reason' => 'Bukti transfer tidak terbaca / tidak valid',
            ])
            ->assertHasNoActionErrors();

        $donation->refresh();

        $this->assertEquals(DonationStatus::Rejected, $donation->status);
        $this->assertEquals('Bukti transfer tidak terbaca / tidak valid', $donation->rejection_reason);
        $this->assertEquals($treasurer->id, $donation->reviewed_by);
    }
}
