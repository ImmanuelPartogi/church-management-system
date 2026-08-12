<?php

namespace Tests\Feature\Domain;

use App\Enums\DonationStatus;
use App\Enums\FinanceAccountType;
use App\Models\ChartOfAccount;
use App\Models\ChurchBankAccount;
use App\Models\ChurchMember;
use App\Models\DonationConfirmation;
use App\Models\FinancialTransaction;
use App\Models\User;
use Database\Seeders\ChartOfAccountSeeder;
use Database\Seeders\ChurchBankAccountSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FinanceAndDonationFoundationTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test 1 & 2: Church bank account creation and active scope.
     */
    public function test_church_bank_account_can_be_created_and_filtered_by_active_scope(): void
    {
        $activeAccount = ChurchBankAccount::factory()->create([
            'bank_name' => 'Bank Mandiri',
            'is_active' => true,
            'display_order' => 1,
        ]);

        $inactiveAccount = ChurchBankAccount::factory()->create([
            'bank_name' => 'BCA',
            'is_active' => false,
            'display_order' => 2,
        ]);

        $activeAccounts = ChurchBankAccount::active()->get();

        $this->assertTrue($activeAccounts->contains($activeAccount));
        $this->assertFalse($activeAccounts->contains($inactiveAccount));
    }

    /**
     * Test 3 & 4: Chart of account creation and parent/child relationship.
     */
    public function test_chart_of_account_supports_parent_child_relationship_and_type_casts(): void
    {
        $parentAccount = ChartOfAccount::factory()->create([
            'code' => '4000',
            'name' => 'Penerimaan Persembahan',
            'type' => FinanceAccountType::Income,
        ]);

        $childAccount = ChartOfAccount::factory()->create([
            'code' => '4010',
            'name' => 'Persembahan Ibadah Minggu',
            'type' => FinanceAccountType::Income,
            'parent_id' => $parentAccount->id,
        ]);

        $this->assertInstanceOf(FinanceAccountType::class, $parentAccount->type);
        $this->assertEquals(FinanceAccountType::Income, $parentAccount->type);

        $this->assertTrue($childAccount->parent->is($parentAccount));
        $this->assertTrue($parentAccount->children->contains($childAccount));
    }

    /**
     * Test 5, 6, 7, 8, 9: Donation confirmation creation, enum casting, and relationships.
     */
    public function test_donation_confirmation_relationships_and_enum_casting(): void
    {
        $user = User::factory()->create();
        $member = ChurchMember::factory()->create(['user_id' => $user->id]);
        $chartAccount = ChartOfAccount::factory()->create();
        $reviewer = User::factory()->create();

        $donation = DonationConfirmation::factory()->create([
            'user_id' => $user->id,
            'member_id' => $member->id,
            'chart_of_account_id' => $chartAccount->id,
            'amount' => 150000.00,
            'status' => DonationStatus::Pending,
            'reviewed_by' => $reviewer->id,
            'reviewed_at' => now(),
        ]);

        $this->assertInstanceOf(DonationStatus::class, $donation->status);
        $this->assertEquals(DonationStatus::Pending, $donation->status);
        $this->assertEquals(150000.00, $donation->amount);

        $this->assertTrue($donation->user->is($user));
        $this->assertTrue($donation->member->is($member));
        $this->assertTrue($donation->chartOfAccount->is($chartAccount));
        $this->assertTrue($donation->reviewer->is($reviewer));
    }

    /**
     * Test 10, 11, 12, 13, 14: Financial transaction relationships and linkage with approved donation.
     */
    public function test_approved_donation_can_be_linked_to_resulting_financial_transaction(): void
    {
        $treasurer = User::factory()->create();
        $chartAccount = ChartOfAccount::factory()->create(['type' => FinanceAccountType::Income]);

        $donation = DonationConfirmation::factory()->approved()->create([
            'chart_of_account_id' => $chartAccount->id,
            'amount' => 500000.00,
            'reviewed_by' => $treasurer->id,
        ]);

        $transaction = FinancialTransaction::factory()->fromDonation($donation)->create();

        $this->assertTrue($transaction->chartOfAccount->is($chartAccount));
        $this->assertTrue($transaction->donationConfirmation->is($donation));
        $this->assertTrue($donation->financialTransaction->is($transaction));
        $this->assertEquals(FinanceAccountType::Income, $transaction->type);
        $this->assertEquals(500000.00, $transaction->amount);
    }

    /**
     * Test 15: Seeders execute successfully and populate initial accounts and bank details.
     */
    public function test_finance_and_bank_seeders_populate_initial_records(): void
    {
        $this->seed([
            ChartOfAccountSeeder::class,
            ChurchBankAccountSeeder::class,
        ]);

        $this->assertDatabaseHas('chart_of_accounts', ['code' => '4000']);
        $this->assertDatabaseHas('chart_of_accounts', ['code' => '5000']);
        $this->assertDatabaseHas('church_bank_accounts', ['bank_name' => 'Bank Mandiri']);
        $this->assertDatabaseHas('church_bank_accounts', ['bank_name' => 'BCA']);
    }
}
