<?php

namespace Tests\Feature\Api;

use App\Enums\PrayerRequestStatus;
use App\Models\ChurchMember;
use App\Models\PrayerRequest;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class PrayerRequestApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_cannot_access_or_submit_prayer_requests(): void
    {
        $this->getJson('/api/v1/prayer-requests')->assertStatus(401);
        $this->postJson('/api/v1/prayer-requests', ['title' => 'Test', 'content' => 'Test'])->assertStatus(401);
    }

    public function test_authenticated_user_can_submit_prayer_request(): void
    {
        $user = User::factory()->create();
        $member = ChurchMember::factory()->create(['user_id' => $user->id]);

        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/prayer-requests', [
            'title' => 'Mohon Doa Pemulihan Kesehatan',
            'content' => 'Mohon bantuan doa dari hamba-Nya untuk kesembuhan dari sakit.',
            'category' => 'Kesehatan',
            'is_private' => true,
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'user_id' => $user->id,
                    'member_id' => $member->id,
                    'title' => 'Mohon Doa Pemulihan Kesehatan',
                    'category' => 'Kesehatan',
                    'is_private' => true,
                    'status' => 'submitted',
                    'follow_up_notes' => null,
                ],
            ]);

        $this->assertDatabaseHas('prayer_requests', [
            'user_id' => $user->id,
            'title' => 'Mohon Doa Pemulihan Kesehatan',
            'status' => PrayerRequestStatus::Submitted->value,
            'is_private' => true,
        ]);
    }

    public function test_validation_fails_for_missing_required_fields(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/prayer-requests', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['title', 'content']);
    }

    public function test_authenticated_user_can_list_their_own_prayer_requests(): void
    {
        $userA = User::factory()->create();
        $userB = User::factory()->create();

        $prayerA = PrayerRequest::factory()->create(['user_id' => $userA->id]);
        $prayerB = PrayerRequest::factory()->create(['user_id' => $userB->id]);

        Sanctum::actingAs($userA);

        $response = $this->getJson('/api/v1/prayer-requests');

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonFragment(['id' => $prayerA->id])
            ->assertJsonMissing(['id' => $prayerB->id]);
    }

    public function test_user_cannot_view_another_users_prayer_request_detail(): void
    {
        $userA = User::factory()->create();
        $userB = User::factory()->create();

        $prayerB = PrayerRequest::factory()->create(['user_id' => $userB->id]);

        Sanctum::actingAs($userA);

        $response = $this->getJson('/api/v1/prayer-requests/'.$prayerB->id);

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'You are not authorized to view this prayer request.',
            ]);
    }

    public function test_user_can_view_their_own_prayer_request_detail_with_pastoral_notes(): void
    {
        $user = User::factory()->create();
        $pastor = User::factory()->create();

        $prayer = PrayerRequest::factory()->create([
            'user_id' => $user->id,
            'status' => PrayerRequestStatus::FollowedUp,
            'follow_up_notes' => 'Telah didoakan oleh tim pastoral.',
            'followed_up_by' => $pastor->id,
            'followed_up_at' => now(),
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/prayer-requests/'.$prayer->id);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $prayer->id,
                    'status' => 'followed_up',
                    'follow_up_notes' => 'Telah didoakan oleh tim pastoral.',
                ],
            ]);
    }
}
