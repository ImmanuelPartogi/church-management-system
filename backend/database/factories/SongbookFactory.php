<?php

namespace Database\Factories;

use App\Models\Songbook;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Songbook>
 */
class SongbookFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => 'Buku Nyanyian '.fake()->unique()->word(),
            'code' => strtoupper(fake()->unique()->lexify('??')),
            'description' => fake()->sentence(),
            'active' => true,
        ];
    }
}
