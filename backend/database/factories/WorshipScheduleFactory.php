<?php

namespace Database\Factories;

use App\Models\WorshipSchedule;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<WorshipSchedule>
 */
class WorshipScheduleFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'title' => 'Ibadah Minggu '.fake()->word(),
            'description' => fake()->sentence(),
            'day' => fake()->randomElement(['Sunday', 'Saturday', 'Wednesday']),
            'start_time' => '08:00',
            'end_time' => '10:00',
            'location' => 'Gereja Utama',
            'active' => true,
        ];
    }
}
