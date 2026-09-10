<?php

namespace Tests\Feature\Tenant;

use App\Models\Announcement;
use App\Models\Church;
use App\Models\ChurchUserMembership;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Kreait\Firebase\Contract\Auth as FirebaseAuth;
use Laravel\Sanctum\Sanctum;
use Lcobucci\JWT\Token\DataSet;
use Lcobucci\JWT\UnencryptedToken;
use Mockery;
use RuntimeException;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class TenantContextResolutionTest extends TestCase
{
    use RefreshDatabase;

    private Church $churchA;

    private Church $churchB;

    private Church $suspendedChurch;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(RolesAndPermissionsSeeder::class);

        // Church A (default church)
        $this->churchA = Church::firstOrCreate(
            ['slug' => (string) config('tenant.default_church_slug', 'default')],
            [
                'uuid' => (string) Str::uuid(),
                'name' => 'Church Alpha',
                'status' => 'active',
                'timezone' => 'Asia/Jakarta',
            ]
        );

        // Church B (secondary church)
        $this->churchB = Church::firstOrCreate(
            ['slug' => 'church-beta'],
            [
                'uuid' => (string) Str::uuid(),
                'name' => 'Church Beta',
                'status' => 'active',
                'timezone' => 'Asia/Jakarta',
            ]
        );

        // Church C (suspended church)
        $this->suspendedChurch = Church::firstOrCreate(
            ['slug' => 'church-suspended'],
            [
                'uuid' => (string) Str::uuid(),
                'name' => 'Church Suspended',
                'status' => 'suspended',
                'timezone' => 'Asia/Jakarta',
            ]
        );

        // Ensure member role exists in Church B as well for multi-tenant registrations
        Role::firstOrCreate(['name' => 'member', 'church_id' => $this->churchB->id, 'guard_name' => 'web']);
        Role::firstOrCreate(['name' => 'church_admin', 'church_id' => $this->churchB->id, 'guard_name' => 'web']);
    }

    /**
     * Test 1: Non-super-admin sending unauthorized church header is strictly rejected with 403 on domain routes.
     */
    public function test_01_non_super_admin_sending_unauthorized_church_header_is_rejected_with_403(): void
    {
        // User belongs only to Church A
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        // Attempting to access domain route specifying Church B
        $response = $this->withHeader('X-Church-Id', (string) $this->churchB->id)
            ->getJson('/api/v1/prayer-requests');

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'Unauthorized tenant access: You are not an active member of this church.',
            ]);
    }

    /**
     * Test 2: Non-super-admin sending unauthorized header to :optional mode endpoint (/auth/me) is STILL rejected with 403.
     * (Contract: :optional relaxes missing memberships, NOT intentional header spoofing attempts).
     */
    public function test_02_non_super_admin_sending_unauthorized_header_to_optional_me_endpoint_is_still_rejected_with_403(): void
    {
        // User belongs only to Church A
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        // Explicitly passing unauthorized Church B header to /auth/me
        $response = $this->withHeader('X-Church-Id', (string) $this->churchB->id)
            ->getJson('/api/v1/auth/me');

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'Unauthorized tenant access: You are not an active member of this church.',
                'code' => 'TENANT_MEMBERSHIP_MISMATCH',
            ]);
    }

    /**
     * Test 3: Super admin can switch tenant via header freely.
     */
    public function test_03_super_admin_can_switch_tenant_via_header(): void
    {
        $superAdmin = User::factory()->create(['is_super_admin' => true]);
        Sanctum::actingAs($superAdmin);

        $response = $this->withHeader('X-Church-Id', (string) $this->churchB->id)
            ->getJson('/api/v1/auth/me');

        $response->assertStatus(200);
        $this->assertEquals($this->churchB->id, app('current_church_id'));
    }

    /**
     * Test 4: Authenticated user without header auto-resolves to active membership.
     */
    public function test_04_authenticated_user_without_header_auto_resolves_to_active_membership(): void
    {
        // User created with membership in Church B
        $user = User::factory()->withoutMembership()->create();
        ChurchUserMembership::create([
            'user_id' => $user->id,
            'church_id' => $this->churchB->id,
            'role' => 'member',
            'status' => 'active',
            'joined_at' => now(),
        ]);
        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/auth/me');

        $response->assertStatus(200);
        $this->assertEquals($this->churchB->id, app('current_church_id'));
    }

    /**
     * Test 5: Session with unauthorized church is cleansed defensively without blocking the user (Anti-Fixation / DoS Defense).
     */
    public function test_05_session_with_unauthorized_church_is_cleansed_defensively_without_blocking_user(): void
    {
        // Admin belongs only to Church A
        $admin = User::factory()->create();
        $admin->assignRole('church_admin');

        // Simulate stale session cookie from another user/session pointing to Church B in Filament panel (/admin)
        $response = $this->actingAs($admin)
            ->withSession(['active_church_id' => $this->churchB->id])
            ->get('/admin');

        $response->assertSuccessful();
        // Stale session key must be purged
        $this->assertNull(session('active_church_id'));
        // Context must fall back to user's legitimate active membership (Church A)
        $this->assertEquals($this->churchA->id, app('current_church_id'));
    }

    /**
     * Test 6: Authenticated user without membership can access :optional identity endpoints (/auth/me).
     */
    public function test_06_authenticated_user_without_membership_can_access_optional_identity_endpoints(): void
    {
        $user = User::factory()->withoutMembership()->create();
        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/auth/me');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $user->id,
                    'name' => $user->name,
                ],
            ]);
    }

    /**
     * Test 7: Authenticated user without membership is strictly rejected on domain endpoints.
     */
    public function test_07_authenticated_user_without_membership_is_rejected_on_domain_endpoints(): void
    {
        $user = User::factory()->withoutMembership()->create();
        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/prayer-requests');

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'User has no active church membership.',
                'code' => 'NO_ACTIVE_MEMBERSHIP',
            ]);
    }

    /**
     * Test 8: New user registration via /auth/firebase without header auto-assigns default church membership.
     */
    public function test_08_new_user_registration_via_firebase_without_header_auto_assigns_default_church_membership(): void
    {
        $claims = new DataSet([
            'sub' => 'mock-firebase-newbie-1',
            'email' => 'newbie1@example.com',
            'name' => 'Newbie One',
        ], 'payload');

        $tokenMock = Mockery::mock(UnencryptedToken::class);
        $tokenMock->shouldReceive('claims')->andReturn($claims);

        $firebaseAuthMock = Mockery::mock(FirebaseAuth::class);
        $firebaseAuthMock->shouldReceive('verifyIdToken')->once()->andReturn($tokenMock);
        $this->app->instance(FirebaseAuth::class, $firebaseAuthMock);

        $response = $this->postJson('/api/v1/auth/firebase', [
            'firebase_id_token' => 'valid-firebase-token-1',
        ]);

        $response->assertStatus(200);

        $user = User::where('email', 'newbie1@example.com')->first();
        $this->assertNotNull($user);

        // Verify ChurchUserMembership was created synchronously under default church
        $membership = $user->memberships()->where('church_id', $this->churchA->id)->first();
        $this->assertNotNull($membership);
        $this->assertEquals('member', $membership->role);
        $this->assertEquals('active', $membership->status);
    }

    /**
     * Test 9: New user registration via /auth/firebase with church header assigns requested church membership.
     */
    public function test_09_new_user_registration_via_firebase_with_church_header_assigns_requested_church_membership(): void
    {
        $claims = new DataSet([
            'sub' => 'mock-firebase-newbie-2',
            'email' => 'newbie2@example.com',
            'name' => 'Newbie Two',
        ], 'payload');

        $tokenMock = Mockery::mock(UnencryptedToken::class);
        $tokenMock->shouldReceive('claims')->andReturn($claims);

        $firebaseAuthMock = Mockery::mock(FirebaseAuth::class);
        $firebaseAuthMock->shouldReceive('verifyIdToken')->once()->andReturn($tokenMock);
        $this->app->instance(FirebaseAuth::class, $firebaseAuthMock);

        $response = $this->withHeader('X-Church-Id', (string) $this->churchB->id)
            ->postJson('/api/v1/auth/firebase', [
                'firebase_id_token' => 'valid-firebase-token-2',
            ]);

        $response->assertStatus(200);

        $user = User::where('email', 'newbie2@example.com')->first();
        $this->assertNotNull($user);

        // Verify ChurchUserMembership was created synchronously under Church B
        $membership = $user->memberships()->where('church_id', $this->churchB->id)->first();
        $this->assertNotNull($membership);
        $this->assertEquals('member', $membership->role);
        $this->assertEquals('active', $membership->status);
    }

    /**
     * Test 10: Request to suspended church is rejected with 403.
     */
    public function test_10_request_to_suspended_church_is_rejected_with_403(): void
    {
        $response = $this->withHeader('X-Church-Id', (string) $this->suspendedChurch->id)
            ->getJson('/api/v1/wartas');

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'Church tenant is suspended.',
            ]);
    }

    /**
     * Test 11: Request with non-existent church ID returns 404.
     */
    public function test_11_request_with_non_existent_church_id_returns_404(): void
    {
        $response = $this->withHeader('X-Church-Id', '999999')
            ->getJson('/api/v1/wartas');

        $response->assertStatus(404)
            ->assertJson([
                'success' => false,
                'message' => 'Church tenant not found.',
            ]);
    }

    /**
     * Test 12: Unauthenticated request without header resolves default church.
     */
    public function test_12_unauthenticated_request_without_header_resolves_default_church(): void
    {
        $response = $this->getJson('/api/v1/wartas');

        $response->assertStatus(200);
        $this->assertEquals($this->churchA->id, app('current_church_id'));
    }

    /**
     * Test 13: Exempt routes (/health) bypass tenant middleware cleanly.
     */
    public function test_13_exempt_routes_bypass_tenant_middleware(): void
    {
        $response = $this->getJson('/api/v1/health');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'API is running',
            ]);
    }

    /**
     * Test 14: Domain model read isolation under ChurchScope.
     * Records belonging to Church A cannot be seen in Church B context.
     */
    public function test_14_domain_model_read_isolation_under_church_scope(): void
    {
        // Bind Church A context and create announcement
        app()->instance('current_church_id', $this->churchA->id);
        $announcementA = Announcement::create([
            'title' => 'Pengumuman Church A',
            'content' => 'Konten Church A',
            'status' => 'published',
        ]);

        // Bind Church B context and create announcement
        app()->instance('current_church_id', $this->churchB->id);
        $announcementB = Announcement::create([
            'title' => 'Pengumuman Church B',
            'content' => 'Konten Church B',
            'status' => 'published',
        ]);

        // Under Church A context, only announcementA is visible
        app()->instance('current_church_id', $this->churchA->id);
        $itemsChurchA = Announcement::all();
        $this->assertTrue($itemsChurchA->contains('id', $announcementA->id));
        $this->assertFalse($itemsChurchA->contains('id', $announcementB->id));

        // Under Church B context, only announcementB is visible
        app()->instance('current_church_id', $this->churchB->id);
        $itemsChurchB = Announcement::all();
        $this->assertFalse($itemsChurchB->contains('id', $announcementA->id));
        $this->assertTrue($itemsChurchB->contains('id', $announcementB->id));
    }

    /**
     * Test 15: Domain model write isolation auto-assigns active church context via BelongsToChurch.
     */
    public function test_15_domain_model_write_isolation_auto_assigns_active_church_context(): void
    {
        app()->instance('current_church_id', $this->churchB->id);

        $announcement = Announcement::create([
            'title' => 'Auto Tenant Assignment',
            'content' => 'Checking BelongsToChurch write behavior',
            'status' => 'published',
        ]);

        $this->assertNotNull($announcement->church_id);
        $this->assertSame($this->churchB->id, $announcement->church_id);
    }

    /**
     * Test 16: Domain model withoutChurch() macro allows cross-tenant queries.
     */
    public function test_16_domain_model_without_church_macro_allows_cross_tenant_queries(): void
    {
        app()->instance('current_church_id', $this->churchA->id);
        $announcementA = Announcement::create([
            'title' => 'Church A Global',
            'content' => 'Cross-tenant query test A',
            'status' => 'published',
        ]);

        app()->instance('current_church_id', $this->churchB->id);
        $announcementB = Announcement::create([
            'title' => 'Church B Global',
            'content' => 'Cross-tenant query test B',
            'status' => 'published',
        ]);

        $allAnnouncements = Announcement::withoutChurch()->get();
        $this->assertTrue($allAnnouncements->contains('id', $announcementA->id));
        $this->assertTrue($allAnnouncements->contains('id', $announcementB->id));
    }

    /**
     * Test 17: Domain model query without tenant context fails loud with RuntimeException.
     */
    public function test_17_domain_model_query_without_tenant_context_fails_loud(): void
    {
        // Explicitly unbind tenant context
        app()->forgetInstance('current_church_id');
        app()->forgetInstance('current_church');

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage('Tenant context is missing — cannot query ['.Announcement::class.'] without an active church context. Use withoutChurch() for global queries.');

        Announcement::all();
    }

    protected function tearDown(): void
    {
        Mockery::close();
        parent::tearDown();
    }
}
