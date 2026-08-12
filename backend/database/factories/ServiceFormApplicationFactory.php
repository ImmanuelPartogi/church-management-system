<?php

namespace Database\Factories;

use App\Enums\PaymentStatus;
use App\Enums\ServiceFormStatus;
use App\Models\ChurchMember;
use App\Models\ServiceFormApplication;
use App\Models\ServiceFormType;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<ServiceFormApplication>
 */
class ServiceFormApplicationFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'application_number' => 'APP-'.strtoupper(Str::random(8)),
            'user_id' => User::factory(),
            'member_id' => ChurchMember::factory(),
            'service_form_type_id' => ServiceFormType::factory(),
            'status' => ServiceFormStatus::Pending,
            'applicant_notes' => fake()->sentence(),
            'rejection_reason' => null,
            'payment_status' => PaymentStatus::Unpaid,
            'payment_notes' => null,
            'reviewed_by' => null,
            'reviewed_at' => null,
        ];
    }

    /**
     * State for approved application.
     */
    public function approved(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => ServiceFormStatus::Approved,
            'payment_status' => PaymentStatus::Paid,
            'reviewed_by' => User::factory(),
            'reviewed_at' => now(),
        ]);
    }

    /**
     * State for rejected application.
     */
    public function rejected(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => ServiceFormStatus::Rejected,
            'rejection_reason' => 'Dokumen pendukung tidak lengkap.',
            'reviewed_by' => User::factory(),
            'reviewed_at' => now(),
        ]);
    }
}
