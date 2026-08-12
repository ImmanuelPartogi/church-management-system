<?php

namespace Database\Factories;

use App\Models\Fellowship;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Fellowship>
 */
class FellowshipFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $name = fake()->unique()->randomElement([
            'PNB/R '.fake()->word(),
            'Kaum Ibu '.fake()->word(),
            'Kaum Bapak '.fake()->word(),
            'SKM '.fake()->word(),
        ]);

        return [
            'name' => ucfirst($name),
            'code' => 'PUN-'.fake()->unique()->numberBetween(100, 999),
            'description' => fake()->sentence(),
            'active' => true,
        ];
    }
}
