<?php

namespace Database\Factories;

use App\Models\Resort;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Resort>
 */
class ResortFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $name = 'Resort HKBP '.fake()->unique()->city();

        return [
            'name' => $name,
            'code' => 'RES-'.fake()->unique()->numberBetween(100, 999),
            'description' => fake()->sentence(),
            'active' => true,
        ];
    }
}
