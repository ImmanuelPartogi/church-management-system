<?php

namespace Database\Factories;

use App\Models\DailyVerse;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<DailyVerse>
 */
class DailyVerseFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'verse_reference' => 'Yohanes '.fake()->numberBetween(1, 21).':'.fake()->numberBetween(1, 30),
            'content' => fake()->sentence(),
            'date' => fake()->unique()->date(),
        ];
    }
}
