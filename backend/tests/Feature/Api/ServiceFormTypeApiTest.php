<?php

namespace Tests\Feature\Api;

use App\Models\ServiceFormType;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ServiceFormTypeApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_active_service_form_types(): void
    {
        $activeType = ServiceFormType::factory()->create([
            'name' => 'Form Baptisan Kudus',
            'slug' => 'baptisan-kudus',
            'active' => true,
        ]);

        $inactiveType = ServiceFormType::factory()->create([
            'name' => 'Form Inactive',
            'slug' => 'inactive-type',
            'active' => false,
        ]);

        $response = $this->getJson('/api/v1/service-form-types');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonFragment(['name' => 'Form Baptisan Kudus'])
            ->assertJsonMissing(['name' => 'Form Inactive']);
    }

    public function test_can_view_active_service_form_type_detail(): void
    {
        $type = ServiceFormType::factory()->create([
            'name' => 'Form Peneguhan Sidi',
            'slug' => 'peneguhan-sidi',
            'active' => true,
        ]);

        $response = $this->getJson('/api/v1/service-form-types/'.$type->id);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $type->id,
                    'name' => 'Form Peneguhan Sidi',
                    'slug' => 'peneguhan-sidi',
                ],
            ]);
    }

    public function test_cannot_view_inactive_service_form_type(): void
    {
        $type = ServiceFormType::factory()->create([
            'active' => false,
        ]);

        $response = $this->getJson('/api/v1/service-form-types/'.$type->id);

        $response->assertStatus(404)
            ->assertJson([
                'success' => false,
                'message' => 'Service form type not found.',
            ]);
    }
}
