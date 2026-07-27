<?php

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Kreait\Firebase\Contract\Auth as FirebaseAuth;
use Laravel\Sanctum\Sanctum;
use Lcobucci\JWT\Token\DataSet;
use Lcobucci\JWT\UnencryptedToken;
use Mockery;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        // Create default roles because assignRole('member') is called during firebase registration
        Role::firstOrCreate(['name' => 'member']);
        Role::firstOrCreate(['name' => 'admin']);
    }

    /**
     * Test successful Firebase token exchange.
     */
    public function test_successful_firebase_token_exchange_creates_user(): void
    {
        // Mock claims dataset directly
        $claims = new DataSet([
            'sub' => 'mock-firebase-uid-123',
            'email' => 'newuser@example.com',
            'name' => 'New Firebase User',
        ], 'encoded_claims_payload');

        // Mock token
        $tokenMock = Mockery::mock(UnencryptedToken::class);
        $tokenMock->shouldReceive('claims')->andReturn($claims);

        // Mock Firebase Auth contract
        $firebaseAuthMock = Mockery::mock(FirebaseAuth::class);
        $firebaseAuthMock->shouldReceive('verifyIdToken')
            ->once()
            ->with('valid-token-xyz')
            ->andReturn($tokenMock);

        $this->app->instance(FirebaseAuth::class, $firebaseAuthMock);

        // Make API request
        $response = $this->postJson('/api/v1/auth/firebase', [
            'firebase_id_token' => 'valid-token-xyz',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'token',
                'user' => [
                    'id',
                    'name',
                    'email',
                    'roles',
                ],
            ]);

        // Assert user was created in the database and linked to firebase_uid
        $this->assertDatabaseHas('users', [
            'email' => 'newuser@example.com',
            'firebase_uid' => 'mock-firebase-uid-123',
        ]);

        $user = User::where('email', 'newuser@example.com')->first();
        $this->assertTrue($user->hasRole('member'));
    }

    /**
     * Test Firebase token exchange failure with invalid token.
     */
    public function test_firebase_token_exchange_fails_with_invalid_token(): void
    {
        // Mock Firebase Auth to throw Exception
        $firebaseAuthMock = Mockery::mock(FirebaseAuth::class);
        $firebaseAuthMock->shouldReceive('verifyIdToken')
            ->once()
            ->with('invalid-token')
            ->andThrow(new \Exception('Token is invalid or expired.'));

        $this->app->instance(FirebaseAuth::class, $firebaseAuthMock);

        // Make API request
        $response = $this->postJson('/api/v1/auth/firebase', [
            'firebase_id_token' => 'invalid-token',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'message' => 'Unauthorized: Invalid Firebase token.',
            ]);
    }

    /**
     * Test current user endpoint '/auth/me'.
     */
    public function test_auth_me_returns_profile_for_authenticated_user(): void
    {
        $user = User::factory()->create([
            'name' => 'Authenticated User',
            'email' => 'auth.me@example.com',
        ]);
        $user->assignRole('member');

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/auth/me');

        $response->assertStatus(200)
            ->assertJson([
                'id' => $user->id,
                'name' => 'Authenticated User',
                'email' => 'auth.me@example.com',
                'roles' => ['member'],
            ]);
    }

    /**
     * Test accessing profile endpoint without authentication.
     */
    public function test_auth_me_returns_unauthorized_if_not_authenticated(): void
    {
        $response = $this->getJson('/api/v1/auth/me');

        $response->assertStatus(401);
    }

    /**
     * Test successful logout.
     */
    public function test_logout_revokes_token(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/auth/logout');

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Logged out successfully.',
            ]);
    }

    protected function tearDown(): void
    {
        Mockery::close();
        parent::tearDown();
    }
}
