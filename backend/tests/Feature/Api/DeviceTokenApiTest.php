<?php

namespace Tests\Feature\Api;

use App\Models\DeviceToken;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeviceTokenApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_unauthenticated_user_cannot_register_device_token(): void
    {
        $response = $this->postJson('/api/v1/notifications/device-token', [
            'token' => 'fcm-token-123',
            'platform' => 'android',
        ]);

        $response->assertStatus(401);
    }

    public function test_authenticated_user_can_register_device_token(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/notifications/device-token', [
                'token' => 'fcm-token-123',
                'platform' => 'android',
                'device_name' => 'Samsung S22',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.token', 'fcm-token-123')
            ->assertJsonPath('data.user_id', $user->id);

        $this->assertDatabaseHas('device_tokens', [
            'user_id' => $user->id,
            'token' => 'fcm-token-123',
            'platform' => 'android',
        ]);
    }

    public function test_registering_existing_token_updates_owner_user(): void
    {
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();

        DeviceToken::create([
            'user_id' => $user1->id,
            'token' => 'shared-fcm-token',
            'platform' => 'android',
        ]);

        $response = $this->actingAs($user2, 'sanctum')
            ->postJson('/api/v1/notifications/device-token', [
                'token' => 'shared-fcm-token',
                'platform' => 'android',
            ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('device_tokens', [
            'token' => 'shared-fcm-token',
            'user_id' => $user2->id,
        ]);
    }

    public function test_user_can_delete_their_device_token(): void
    {
        $user = User::factory()->create();
        DeviceToken::create([
            'user_id' => $user->id,
            'token' => 'token-to-delete',
            'platform' => 'android',
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->deleteJson('/api/v1/notifications/device-token', [
                'token' => 'token-to-delete',
            ]);

        $response->assertStatus(200);

        $this->assertDatabaseMissing('device_tokens', [
            'token' => 'token-to-delete',
        ]);
    }
}
