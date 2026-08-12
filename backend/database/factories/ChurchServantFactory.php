<?php

namespace Database\Factories;

use App\Enums\ChurchServantRole;
use App\Models\ChurchMember;
use App\Models\ChurchServant;
use App\Models\Fellowship;
use App\Models\Resort;
use App\Models\Sector;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ChurchServant>
 */
class ChurchServantFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'member_id' => ChurchMember::factory(),
            'name' => fake()->name(),
            'role' => fake()->randomElement(ChurchServantRole::cases()),
            'phone' => fake()->phoneNumber(),
            'email' => fake()->safeEmail(),
            'resort_id' => null,
            'sector_id' => null,
            'fellowship_id' => null,
            'description' => fake()->sentence(),
            'active' => true,
        ];
    }

    /**
     * State for a servant assigned to a resort.
     */
    public function inResort(Resort $resort): static
    {
        return $this->state(fn (array $attributes) => [
            'resort_id' => $resort->id,
        ]);
    }

    /**
     * State for a servant assigned to a sector.
     */
    public function inSector(Sector $sector): static
    {
        return $this->state(fn (array $attributes) => [
            'sector_id' => $sector->id,
            'resort_id' => $sector->resort_id,
        ]);
    }

    /**
     * State for a servant assigned to a fellowship.
     */
    public function inFellowship(Fellowship $fellowship): static
    {
        return $this->state(fn (array $attributes) => [
            'fellowship_id' => $fellowship->id,
        ]);
    }
}
