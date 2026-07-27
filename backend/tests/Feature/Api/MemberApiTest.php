<?php

namespace Tests\Feature\Api;

use App\Models\ChurchMember;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MemberApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test members endpoint requires auth.
     */
    public function test_members_endpoint_requires_authentication(): void
    {
        $response = $this->getJson('/api/v1/members');
        $response->assertStatus(401);
    }

    /**
     * Test list of members can be retrieved by authenticated user.
     */
    public function test_authenticated_user_can_list_members(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        // Seed some members
        ChurchMember::create([
            'membership_number' => 'MEM-001',
            'full_name' => 'John Doe',
            'gender' => 'Male',
            'birth_date' => '1990-01-01',
            'phone' => '123456',
            'email' => 'john@example.com',
            'address' => 'Test Address',
            'status' => 'active',
        ]);

        ChurchMember::create([
            'membership_number' => 'MEM-002',
            'full_name' => 'Jane Smith',
            'gender' => 'Female',
            'birth_date' => '1995-02-02',
            'phone' => '654321',
            'email' => 'jane@example.com',
            'address' => 'Test Address 2',
            'status' => 'active',
        ]);

        $response = $this->getJson('/api/v1/members');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'membership_number',
                        'full_name',
                        'gender',
                        'birth_date',
                        'phone',
                        'email',
                        'address',
                        'status',
                        'has_app_account',
                    ],
                ],
                'links',
                'meta',
            ]);

        $this->assertCount(2, $response->json('data'));
    }

    /**
     * Test list filters and search.
     */
    public function test_members_list_can_be_searched_and_filtered(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        ChurchMember::create([
            'membership_number' => 'MEM-001',
            'full_name' => 'John Doe',
            'gender' => 'Male',
            'birth_date' => '1990-01-01',
            'phone' => '123456',
            'email' => 'john@example.com',
            'address' => 'Test Address',
            'status' => 'active',
        ]);

        ChurchMember::create([
            'membership_number' => 'MEM-002',
            'full_name' => 'Jane Smith',
            'gender' => 'Female',
            'birth_date' => '1995-02-02',
            'phone' => '654321',
            'email' => 'jane@example.com',
            'address' => 'Test Address 2',
            'status' => 'inactive',
        ]);

        // Search for 'Jane'
        $response = $this->getJson('/api/v1/members?search=Jane');
        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertEquals('Jane Smith', $response->json('data.0.full_name'));

        // Filter by status 'inactive'
        $response = $this->getJson('/api/v1/members?status=inactive');
        $response->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertEquals('Jane Smith', $response->json('data.0.full_name'));
    }

    /**
     * Test single member detail retrieval.
     */
    public function test_authenticated_user_can_view_single_member_details(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $member = ChurchMember::create([
            'membership_number' => 'MEM-001',
            'full_name' => 'John Doe',
            'gender' => 'Male',
            'birth_date' => '1990-01-01',
            'phone' => '123456',
            'email' => 'john@example.com',
            'address' => 'Test Address',
            'status' => 'active',
        ]);

        $response = $this->getJson('/api/v1/members/'.$member->id);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Member retrieved successfully.',
                'data' => [
                    'id' => $member->id,
                    'full_name' => 'John Doe',
                    'email' => 'john@example.com',
                ],
            ]);
    }

    /**
     * Test single member detail returns 404 if not found.
     */
    public function test_view_member_returns_404_if_not_found(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/members/999');
        $response->assertStatus(404)
            ->assertJson([
                'success' => false,
                'message' => 'Member not found.',
            ]);
    }
}
