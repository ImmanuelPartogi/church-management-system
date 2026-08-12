<?php

namespace Database\Factories;

use App\Models\ChurchBankAccount;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ChurchBankAccount>
 */
class ChurchBankAccountFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'bank_name' => fake()->randomElement(['Bank Mandiri', 'BCA', 'BRI', 'BNI']),
            'account_number' => fake()->numerify('##########'),
            'account_holder_name' => 'Gereja HKBP Resort',
            'is_active' => true,
            'display_order' => fake()->numberBetween(1, 10),
        ];
    }
}
