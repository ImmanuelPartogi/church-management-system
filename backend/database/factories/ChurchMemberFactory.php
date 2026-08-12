<?php

namespace Database\Factories;

use App\Models\ChurchMember;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ChurchMember>
 */
class ChurchMemberFactory extends Factory
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
            'membership_number' => 'MEM-'.fake()->unique()->numberBetween(10000, 99999),
            'full_name' => fake()->name(),
            'gender' => fake()->randomElement(['Male', 'Female']),
            'birth_date' => fake()->date(),
            'phone' => fake()->phoneNumber(),
            'email' => fake()->safeEmail(),
            'address' => fake()->address(),
            'baptism_date' => fake()->date(),
            'status' => 'active',
        ];
    }
}
