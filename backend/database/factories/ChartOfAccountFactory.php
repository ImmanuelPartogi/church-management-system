<?php

namespace Database\Factories;

use App\Enums\FinanceAccountType;
use App\Models\ChartOfAccount;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ChartOfAccount>
 */
class ChartOfAccountFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'code' => fake()->unique()->numerify('4###'),
            'name' => fake()->words(2, true),
            'type' => FinanceAccountType::Income,
            'description' => fake()->sentence(),
            'is_active' => true,
            'parent_id' => null,
        ];
    }

    /**
     * State for expense account.
     */
    public function expense(): static
    {
        return $this->state(fn (array $attributes) => [
            'code' => fake()->unique()->numerify('5###'),
            'type' => FinanceAccountType::Expense,
        ]);
    }
}
