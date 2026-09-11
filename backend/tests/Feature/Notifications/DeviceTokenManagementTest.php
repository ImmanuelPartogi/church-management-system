<?php

namespace Tests\Feature\Notifications;

use App\Models\Church;
use App\Models\ChurchUserMembership;
use App\Models\DeviceToken;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DeviceTokenManagementTest extends TestCase
{
    use RefreshDatabase;

    protected Church $churchA;

    protected Church $churchB;

    protected User $user;

    protected function setUp(): void
    {
        parent::setUp();

        $this->churchA = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Tarutung',
            'slug' => 'hkbp-tarutung',
            'status' => 'active',
        ]);

        $this->churchB = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Sipoholon',
            'slug' => 'hkbp-sipoholon',
            'status' => 'active',
        ]);

        $this->user = User::create([
            'name' => 'Pendeta Lintas Ressort',
            'email' => 'pastor@hkbp.org',
            'password' => bcrypt('password'),
        ]);
    }

    /**
     * Test authenticated user with multi-membership registers tokens across all active churches atomically.
     */
    public function test_authenticated_user_fans_out_token_across_all_active_memberships(): void
    {
        // Setup 2 active memberships
        ChurchUserMembership::create([
            'church_id' => $this->churchA->id,
            'user_id' => $this->user->id,
            'role' => 'pastor',
            'status' => 'active',
        ]);

        ChurchUserMembership::create([
            'church_id' => $this->churchB->id,
            'user_id' => $this->user->id,
            'role' => 'pastor',
            'status' => 'active',
        ]);

        Sanctum::actingAs($this->user);

        $response = $this->postJson('/api/v1/notifications/device-token', [
            'token' => 'fcm_multi_church_token_999',
            'platform' => 'android',
            'device_name' => 'Google Pixel 8',
        ], [
            'X-Church-Id' => (string) $this->churchA->id,
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.registered_count', 2);

        // Verify row exists for Church A
        $this->assertDatabaseHas('device_tokens', [
            'user_id' => $this->user->id,
            'church_id' => $this->churchA->id,
            'token' => 'fcm_multi_church_token_999',
            'platform' => 'android',
            'is_active' => 1,
        ]);

        // Verify row exists for Church B
        $this->assertDatabaseHas('device_tokens', [
            'user_id' => $this->user->id,
            'church_id' => $this->churchB->id,
            'token' => 'fcm_multi_church_token_999',
            'platform' => 'android',
            'is_active' => 1,
        ]);

        // Exact row count for this token across whole database must be 2
        $this->assertSame(2, DeviceToken::where('token', 'fcm_multi_church_token_999')->count());
    }

    /**
     * Test that updating membership status to suspended immediately deactivates device tokens for that church.
     */
    public function test_suspending_membership_deactivates_associated_device_tokens(): void
    {
        $membershipA = ChurchUserMembership::create([
            'church_id' => $this->churchA->id,
            'user_id' => $this->user->id,
            'role' => 'pastor',
            'status' => 'active',
        ]);

        $membershipB = ChurchUserMembership::create([
            'church_id' => $this->churchB->id,
            'user_id' => $this->user->id,
            'role' => 'pastor',
            'status' => 'active',
        ]);

        // Register token for both churches
        Sanctum::actingAs($this->user);
        $this->postJson('/api/v1/notifications/device-token', [
            'token' => 'fcm_token_lifecycle_test',
            'platform' => 'android',
        ], ['X-Church-Id' => (string) $this->churchA->id]);

        $this->assertTrue(DeviceToken::where('church_id', $this->churchA->id)->value('is_active'));
        $this->assertTrue(DeviceToken::where('church_id', $this->churchB->id)->value('is_active'));

        // Admin suspends membership in Church A
        $membershipA->update(['status' => 'suspended']);

        // Church A token must now be inactive
        $this->assertFalse(
            DeviceToken::where('church_id', $this->churchA->id)
                ->where('token', 'fcm_token_lifecycle_test')
                ->value('is_active')
        );

        // Church B token must remain active
        $this->assertTrue(
            DeviceToken::where('church_id', $this->churchB->id)
                ->where('token', 'fcm_token_lifecycle_test')
                ->value('is_active')
        );

        // Admin reactivates membership in Church A
        $membershipA->update(['status' => 'active']);

        // Church A token must be reactivated
        $this->assertTrue(
            DeviceToken::where('church_id', $this->churchA->id)
                ->where('token', 'fcm_token_lifecycle_test')
                ->value('is_active')
        );
    }

    /**
     * Test that deleting a membership deactivates tokens for that church.
     */
    public function test_deleting_membership_deactivates_associated_device_tokens(): void
    {
        $membership = ChurchUserMembership::create([
            'church_id' => $this->churchA->id,
            'user_id' => $this->user->id,
            'role' => 'member',
            'status' => 'active',
        ]);

        Sanctum::actingAs($this->user);
        $this->postJson('/api/v1/notifications/device-token', [
            'token' => 'fcm_token_delete_test',
            'platform' => 'ios',
        ], ['X-Church-Id' => (string) $this->churchA->id]);

        $this->assertTrue(DeviceToken::where('church_id', $this->churchA->id)->value('is_active'));

        // Membership deleted
        $membership->delete();

        // Token must be deactivated
        $this->assertFalse(
            DeviceToken::where('church_id', $this->churchA->id)
                ->where('token', 'fcm_token_delete_test')
                ->value('is_active')
        );
    }

    /**
     * Test deleting device token via API removes records cleanly.
     */
    public function test_user_can_delete_token_specifically_or_globally(): void
    {
        ChurchUserMembership::create([
            'church_id' => $this->churchA->id,
            'user_id' => $this->user->id,
            'status' => 'active',
        ]);

        ChurchUserMembership::create([
            'church_id' => $this->churchB->id,
            'user_id' => $this->user->id,
            'status' => 'active',
        ]);

        Sanctum::actingAs($this->user);
        $this->postJson('/api/v1/notifications/device-token', [
            'token' => 'fcm_token_to_purge',
        ], ['X-Church-Id' => (string) $this->churchA->id]);

        $this->assertSame(2, DeviceToken::where('token', 'fcm_token_to_purge')->count());

        // Delete specifically for Church A
        $deleteResponse = $this->deleteJson('/api/v1/notifications/device-token', [
            'token' => 'fcm_token_to_purge',
            'church_id' => $this->churchA->id,
        ], ['X-Church-Id' => (string) $this->churchA->id]);

        $deleteResponse->assertOk();

        // Church A row gone, Church B row still exists
        $this->assertDatabaseMissing('device_tokens', [
            'token' => 'fcm_token_to_purge',
            'church_id' => $this->churchA->id,
        ]);
        $this->assertDatabaseHas('device_tokens', [
            'token' => 'fcm_token_to_purge',
            'church_id' => $this->churchB->id,
        ]);

        // Global delete without church_id purges all rows for this user
        $this->deleteJson('/api/v1/notifications/device-token', [
            'token' => 'fcm_token_to_purge',
        ], ['X-Church-Id' => (string) $this->churchB->id])->assertOk();

        $this->assertDatabaseMissing('device_tokens', [
            'token' => 'fcm_token_to_purge',
        ]);
    }
}
