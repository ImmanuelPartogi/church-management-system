<?php

namespace Database\Factories;

use App\Models\Song;
use App\Models\Songbook;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Song>
 */
class SongFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'songbook_id' => Songbook::factory(),
            'number' => fake()->unique()->numberBetween(1, 500),
            'title' => 'Nyanyian '.fake()->words(3, true),
            'lyrics' => implode("\n\n", [
                'Bait 1:',
                fake()->paragraph(),
                'Bait 2:',
                fake()->paragraph(),
            ]),
            'active' => true,
        ];
    }
}
