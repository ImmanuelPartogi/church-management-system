<?php

namespace Database\Factories;

use App\Models\Resort;
use App\Models\Sector;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Sector>
 */
class SectorFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'resort_id' => Resort::factory(),
            'name' => 'Sektor '.fake()->unique()->numberBetween(1, 99),
            'code' => 'SEK-'.fake()->numberBetween(1, 99),
            'description' => fake()->sentence(),
            'active' => true,
        ];
    }
}
