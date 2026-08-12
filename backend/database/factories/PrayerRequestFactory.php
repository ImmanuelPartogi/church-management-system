<?php

namespace Database\Factories;

use App\Enums\PrayerRequestStatus;
use App\Models\ChurchMember;
use App\Models\PrayerRequest;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<PrayerRequest>
 */
class PrayerRequestFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'member_id' => ChurchMember::factory(),
            'title' => fake()->sentence(),
            'content' => fake()->paragraph(),
            'category' => fake()->randomElement(['Kesehatan', 'Keluarga', 'Pekerjaan', 'Ucapan Syukur']),
            'is_private' => true,
            'status' => PrayerRequestStatus::Submitted,
            'follow_up_notes' => null,
            'followed_up_by' => null,
            'followed_up_at' => null,
        ];
    }

    /**
     * State for prayed request.
     */
    public function prayed(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => PrayerRequestStatus::Prayed,
        ]);
    }

    /**
     * State for followed up request.
     */
    public function followedUp(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => PrayerRequestStatus::FollowedUp,
            'follow_up_notes' => 'Telah didoakan dan dilayani oleh Pendeta Resort.',
            'followed_up_by' => User::factory(),
            'followed_up_at' => now(),
        ]);
    }
}
