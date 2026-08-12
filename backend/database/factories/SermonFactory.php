<?php

namespace Database\Factories;

use App\Models\ChurchServant;
use App\Models\Sermon;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Sermon>
 */
class SermonFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'title' => 'Khotbah: '.fake()->sentence(4),
            'description' => fake()->paragraph(),
            'preacher_name' => fake()->name(),
            'servant_id' => null,
            'file_path' => 'sermons/'.fake()->uuid().'.pdf',
            'file_name' => fake()->word().'.pdf',
            'file_size' => fake()->numberBetween(100000, 5000000),
            'mime_type' => 'application/pdf',
            'published_at' => fake()->dateTimeBetween('-1 year', 'now'),
            'is_published' => true,
            'download_count' => fake()->numberBetween(0, 100),
        ];
    }

    /**
     * State for unpublished sermon.
     */
    public function unpublished(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_published' => false,
            'published_at' => null,
        ]);
    }

    /**
     * State for a sermon by a specific servant.
     */
    public function byServant(ChurchServant $servant): static
    {
        return $this->state(fn (array $attributes) => [
            'servant_id' => $servant->id,
            'preacher_name' => $servant->name,
        ]);
    }
}
