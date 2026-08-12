<?php

namespace Database\Factories;

use App\Enums\FinanceAccountType;
use App\Models\ChartOfAccount;
use App\Models\DonationConfirmation;
use App\Models\FinancialTransaction;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<FinancialTransaction>
 */
class FinancialTransactionFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'transaction_number' => 'TRX-'.strtoupper(Str::random(8)),
            'transaction_date' => fake()->date(),
            'chart_of_account_id' => ChartOfAccount::factory(),
            'type' => FinanceAccountType::Income,
            'amount' => fake()->randomFloat(2, 50000, 5000000),
            'description' => fake()->sentence(),
            'reference' => 'REF-'.Str::random(6),
            'donation_confirmation_id' => null,
            'created_by' => User::factory(),
        ];
    }

    /**
     * State for donation-based financial transaction.
     */
    public function fromDonation(DonationConfirmation $donation): static
    {
        return $this->state(fn (array $attributes) => [
            'chart_of_account_id' => $donation->chart_of_account_id,
            'type' => FinanceAccountType::Income,
            'amount' => $donation->amount,
            'description' => 'Penerimaan persembahan/donasi '.$donation->donation_number,
            'donation_confirmation_id' => $donation->id,
            'created_by' => $donation->reviewed_by ?? User::factory(),
        ]);
    }
}
