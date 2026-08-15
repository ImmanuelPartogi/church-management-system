<?php

namespace Tests\Feature\Api;

use App\Models\ChurchMember;
use App\Models\DeviceToken;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProfileApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_get_profile(): void
    {
        $user = User::factory()->create([
            'name' => 'Profile User',
            'email' => 'profile@example.com',
            'phone' => '081234567890',
            'address' => 'Jl. Gereja No. 1',
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/profile');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.name', 'Profile User')
            ->assertJsonPath('data.email', 'profile@example.com')
            ->assertJsonPath('data.phone', '081234567890')
            ->assertJsonPath('data.address', 'Jl. Gereja No. 1')
            ->assertJsonPath('data.member', null);
    }

    public function test_unauthenticated_user_cannot_get_profile(): void
    {
        $response = $this->getJson('/api/v1/profile');

        $response->assertStatus(401);
    }

    public function test_profile_returns_linked_church_member_details(): void
    {
        $user = User::factory()->create();
        $member = ChurchMember::factory()->create([
            'user_id' => $user->id,
            'full_name' => 'Budi Jemaat',
            'membership_number' => 'MB-100',
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/profile');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.member.full_name', 'Budi Jemaat')
            ->assertJsonPath('data.member.membership_number', 'MB-100');
    }

    public function test_authenticated_user_can_update_allowed_fields(): void
    {
        $user = User::factory()->create([
            'name' => 'Old Name',
            'phone' => '081111111111',
            'address' => 'Old Address',
        ]);

        $member = ChurchMember::factory()->create([
            'user_id' => $user->id,
            'full_name' => 'Old Name',
            'phone' => '081111111111',
            'address' => 'Old Address',
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/profile', [
                'name' => 'Updated Name',
                'phone' => '082222222222',
                'address' => 'Updated Address',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.name', 'Updated Name')
            ->assertJsonPath('data.phone', '082222222222')
            ->assertJsonPath('data.address', 'Updated Address');

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'name' => 'Updated Name',
            'phone' => '082222222222',
        ]);

        $this->assertDatabaseHas('church_members', [
            'id' => $member->id,
            'full_name' => 'Updated Name',
            'phone' => '082222222222',
        ]);
    }

    public function test_validation_rejects_empty_name(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/profile', [
                'name' => '',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['name']);
    }

    public function test_user_cannot_modify_protected_fields(): void
    {
        $user = User::factory()->create([
            'email' => 'original@example.com',
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->putJson('/api/v1/profile', [
                'name' => 'Valid Name',
                'email' => 'hacked@example.com',
                'roles' => ['admin'],
            ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'email' => 'original@example.com',
        ]);
    }

    public function test_authenticated_user_can_delete_own_account_and_revoke_tokens(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('test_token')->plainTextToken;

        DeviceToken::factory()->create([
            'user_id' => $user->id,
            'token' => 'fcm_token_123',
        ]);

        $member = ChurchMember::factory()->create([
            'user_id' => $user->id,
        ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->deleteJson('/api/v1/profile');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'Account deleted successfully.');

        // User should be deleted
        $this->assertDatabaseMissing('users', [
            'id' => $user->id,
        ]);

        // Sanctum tokens should be purged
        $this->assertDatabaseMissing('personal_access_tokens', [
            'tokenable_id' => $user->id,
        ]);

        // FCM device tokens should be purged
        $this->assertDatabaseMissing('device_tokens', [
            'user_id' => $user->id,
        ]);

        // ChurchMember historical record should remain intact with unlinked user_id
        $this->assertDatabaseHas('church_members', [
            'id' => $member->id,
            'user_id' => null,
        ]);
    }

    public function test_unauthenticated_user_cannot_delete_profile(): void
    {
        $response = $this->deleteJson('/api/v1/profile');

        $response->assertStatus(401);
    }
}
