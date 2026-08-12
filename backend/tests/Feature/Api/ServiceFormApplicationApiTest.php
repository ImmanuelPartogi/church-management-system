<?php

namespace Tests\Feature\Api;

use App\Enums\ServiceFormStatus;
use App\Models\ChurchMember;
use App\Models\ServiceFormApplication;
use App\Models\ServiceFormType;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ServiceFormApplicationApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_cannot_submit_service_form_application(): void
    {
        $type = ServiceFormType::factory()->create(['active' => true]);

        $response = $this->postJson('/api/v1/service-form-applications', [
            'service_form_type_id' => $type->id,
            'applicant_notes' => 'Permohonan baptisan anak',
        ]);

        $response->assertStatus(401);
    }

    public function test_authenticated_user_can_submit_application_with_documents(): void
    {
        Storage::fake('public');

        $user = User::factory()->create();
        $member = ChurchMember::factory()->create(['user_id' => $user->id]);
        $type = ServiceFormType::factory()->create(['active' => true]);

        Sanctum::actingAs($user);

        $docFile = UploadedFile::fake()->create('kartu_keluarga.pdf', 200, 'application/pdf');

        $response = $this->postJson('/api/v1/service-form-applications', [
            'service_form_type_id' => $type->id,
            'applicant_notes' => 'Permohonan baptisan kudus anak pertama',
            'documents' => [
                [
                    'document_name' => 'Kartu Keluarga',
                    'file' => $docFile,
                ],
            ],
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'user_id' => $user->id,
                    'member_id' => $member->id,
                    'status' => 'pending',
                    'applicant_notes' => 'Permohonan baptisan kudus anak pertama',
                    'rejection_reason' => null,
                    'payment_status' => 'unpaid',
                ],
            ]);

        $this->assertDatabaseHas('service_form_applications', [
            'user_id' => $user->id,
            'member_id' => $member->id,
            'service_form_type_id' => $type->id,
            'status' => ServiceFormStatus::Pending->value,
            'reviewed_by' => null,
            'reviewed_at' => null,
        ]);

        $this->assertDatabaseHas('service_form_documents', [
            'document_name' => 'Kartu Keluarga',
            'file_name' => 'kartu_keluarga.pdf',
        ]);
    }

    public function test_submitting_application_for_inactive_form_type_is_rejected(): void
    {
        $user = User::factory()->create();
        $type = ServiceFormType::factory()->create(['active' => false]);

        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/service-form-applications', [
            'service_form_type_id' => $type->id,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['service_form_type_id']);
    }

    public function test_authenticated_user_can_list_their_own_applications(): void
    {
        $userA = User::factory()->create();
        $userB = User::factory()->create();

        $appA = ServiceFormApplication::factory()->create(['user_id' => $userA->id]);
        $appB = ServiceFormApplication::factory()->create(['user_id' => $userB->id]);

        Sanctum::actingAs($userA);

        $response = $this->getJson('/api/v1/service-form-applications');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonFragment(['id' => $appA->id])
            ->assertJsonMissing(['id' => $appB->id]);
    }

    public function test_user_cannot_view_another_users_application_detail(): void
    {
        $userA = User::factory()->create();
        $userB = User::factory()->create();

        $appB = ServiceFormApplication::factory()->create(['user_id' => $userB->id]);

        Sanctum::actingAs($userA);

        $response = $this->getJson('/api/v1/service-form-applications/'.$appB->id);

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'You are not authorized to view this application.',
            ]);
    }
}
