<?php

namespace Database\Factories;

use App\Models\ServiceFormApplication;
use App\Models\ServiceFormDocument;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ServiceFormDocument>
 */
class ServiceFormDocumentFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'service_form_application_id' => ServiceFormApplication::factory(),
            'document_name' => 'KTP Pelapor',
            'file_path' => 'form_documents/'.fake()->uuid().'.pdf',
            'file_name' => 'ktp_pelapor.pdf',
            'mime_type' => 'application/pdf',
            'file_size' => fake()->numberBetween(100000, 2000000),
        ];
    }
}
