<?php

namespace Database\Factories;

use App\Models\Warta;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Warta>
 */
class WartaFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'title' => 'Warta Jemaat Minggu '.fake()->date('d M Y'),
            'description' => fake()->sentence(),
            'file_path' => 'wartas/'.fake()->uuid().'.pdf',
            'file_name' => 'Warta_Jemaat_'.fake()->date('Y_m_d').'.pdf',
            'file_size' => fake()->numberBetween(500000, 5000000),
            'mime_type' => 'application/pdf',
            'published_at' => now(),
            'is_published' => true,
            'download_count' => fake()->numberBetween(0, 100),
        ];
    }

    /**
     * Indicate that the warta is draft / unpublished.
     */
    public function unpublished(): static
    {
        return $this->state(fn (array $attributes) => [
            'published_at' => null,
            'is_published' => false,
        ]);
    }
}
