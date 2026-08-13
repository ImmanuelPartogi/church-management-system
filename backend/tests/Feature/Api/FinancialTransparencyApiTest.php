<?php

namespace Tests\Feature\Api;

use App\Enums\FinanceAccountType;
use App\Models\ChartOfAccount;
use App\Models\FinancialTransaction;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FinancialTransparencyApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_public_can_retrieve_financial_transparency_report(): void
    {
        $incomeAccount = ChartOfAccount::factory()->create([
            'code' => '4001',
            'name' => 'Persembahan Kebaktian',
            'type' => FinanceAccountType::Income,
        ]);

        $expenseAccount = ChartOfAccount::factory()->create([
            'code' => '5001',
            'name' => 'Operasional Gereja',
            'type' => FinanceAccountType::Expense,
        ]);

        FinancialTransaction::factory()->create([
            'chart_of_account_id' => $incomeAccount->id,
            'type' => FinanceAccountType::Income,
            'amount' => 5000000,
            'transaction_date' => now()->format('Y-m-d'),
        ]);

        FinancialTransaction::factory()->create([
            'chart_of_account_id' => $expenseAccount->id,
            'type' => FinanceAccountType::Expense,
            'amount' => 2000000,
            'transaction_date' => now()->format('Y-m-d'),
        ]);

        $response = $this->getJson('/api/v1/finances/transparency');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'summary' => [
                        'total_income' => 5000000,
                        'total_expense' => 2000000,
                        'net_balance' => 3000000,
                    ],
                ],
            ])
            ->assertJsonFragment(['account_code' => '4001', 'account_name' => 'Persembahan Kebaktian', 'total_amount' => 5000000])
            ->assertJsonFragment(['account_code' => '5001', 'account_name' => 'Operasional Gereja', 'total_amount' => 2000000]);
    }

    public function test_financial_transparency_filters_by_date_range(): void
    {
        $incomeAccount = ChartOfAccount::factory()->create([
            'type' => FinanceAccountType::Income,
        ]);

        FinancialTransaction::factory()->create([
            'chart_of_account_id' => $incomeAccount->id,
            'type' => FinanceAccountType::Income,
            'amount' => 1000000,
            'transaction_date' => '2026-01-15',
        ]);

        FinancialTransaction::factory()->create([
            'chart_of_account_id' => $incomeAccount->id,
            'type' => FinanceAccountType::Income,
            'amount' => 2000000,
            'transaction_date' => '2026-05-20',
        ]);

        $response = $this->getJson('/api/v1/finances/transparency?from=2026-01-01&to=2026-02-01');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'summary' => [
                        'total_income' => 1000000,
                    ],
                ],
            ]);
    }

    public function test_invalid_date_range_is_rejected(): void
    {
        $response = $this->getJson('/api/v1/finances/transparency?from=2026-12-01&to=2026-01-01');

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['to']);
    }

    public function test_transparency_report_never_exposes_donor_identity_or_proofs(): void
    {
        $incomeAccount = ChartOfAccount::factory()->create(['type' => FinanceAccountType::Income]);

        FinancialTransaction::factory()->create([
            'chart_of_account_id' => $incomeAccount->id,
            'type' => FinanceAccountType::Income,
            'amount' => 500000,
            'transaction_date' => now()->format('Y-m-d'),
        ]);

        $response = $this->getJson('/api/v1/finances/transparency');

        $response->assertStatus(200);

        $json = $response->getContent();
        $this->assertStringNotContainsString('donor', strtolower((string) $json));
        $this->assertStringNotContainsString('proof_file_path', strtolower((string) $json));
        $this->assertStringNotContainsString('depositor_phone', strtolower((string) $json));
    }
}
