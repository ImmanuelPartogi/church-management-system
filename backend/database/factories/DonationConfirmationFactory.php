<?php

namespace Database\Factories;

use App\Enums\DonationStatus;
use App\Models\ChartOfAccount;
use App\Models\ChurchMember;
use App\Models\DonationConfirmation;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<DonationConfirmation>
 */
class DonationConfirmationFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'donation_number' => 'DON-'.strtoupper(Str::random(8)),
            'user_id' => User::factory(),
            'member_id' => ChurchMember::factory(),
            'chart_of_account_id' => ChartOfAccount::factory(),
            'amount' => fake()->randomFloat(2, 50000, 2000000),
            'transfer_date' => fake()->date(),
            'sender_bank' => fake()->randomElement(['Bank Mandiri', 'BCA', 'BRI']),
            'depositor_phone' => fake()->phoneNumber(),
            'proof_file_path' => 'donations/'.fake()->uuid().'.jpg',
            'status' => DonationStatus::Pending,
            'notes' => fake()->sentence(),
            'rejection_reason' => null,
            'reviewed_by' => null,
            'reviewed_at' => null,
        ];
    }

    /**
     * State for approved donation.
     */
    public function approved(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => DonationStatus::Approved,
            'reviewed_by' => User::factory(),
            'reviewed_at' => now(),
        ]);
    }

    /**
     * State for rejected donation.
     */
    public function rejected(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => DonationStatus::Rejected,
            'rejection_reason' => 'Bukti mentransfer tidak jelas / dana tidak masuk.',
            'reviewed_by' => User::factory(),
            'reviewed_at' => now(),
        ]);
    }
}
