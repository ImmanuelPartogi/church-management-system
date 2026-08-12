<?php

namespace Tests\Feature\Filament;

use App\Enums\FinanceAccountType;
use App\Filament\Resources\FinancialTransactionResource;
use App\Models\ChartOfAccount;
use App\Models\FinancialTransaction;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class FinancialTransactionResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_treasurer_can_render_financial_ledger_list(): void
    {
        $treasurer = User::factory()->create();
        $treasurer->assignRole('bendahara');

        $transaction = FinancialTransaction::factory()->create();

        $this->actingAs($treasurer)
            ->get(FinancialTransactionResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($treasurer)
            ->test(FinancialTransactionResource\Pages\ListFinancialTransactions::class)
            ->assertCanSeeTableRecords([$transaction]);
    }

    public function test_unauthorized_user_cannot_access_financial_ledger(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(FinancialTransactionResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_treasurer_can_create_manual_ledger_transaction(): void
    {
        $treasurer = User::factory()->create();
        $treasurer->assignRole('bendahara');

        $chart = ChartOfAccount::factory()->create(['type' => FinanceAccountType::Expense]);

        Livewire::actingAs($treasurer)
            ->test(FinancialTransactionResource\Pages\CreateFinancialTransaction::class)
            ->fillForm([
                'transaction_number' => 'TRX-MAN-001',
                'transaction_date' => '2026-08-12',
                'chart_of_account_id' => $chart->id,
                'type' => 'expense',
                'amount' => 150000.00,
                'description' => 'Pembelian Lilin dan Perlengkapan Altar',
                'reference' => 'NOTA-778',
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('financial_transactions', [
            'transaction_number' => 'TRX-MAN-001',
            'amount' => 150000.00,
            'type' => FinanceAccountType::Expense->value,
            'created_by' => $treasurer->id,
        ]);
    }
}
