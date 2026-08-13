<?php

namespace Tests\Feature\Api;

use App\Models\ChurchMember;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MemberDirectorySearchApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_guest_cannot_search_member_directory(): void
    {
        $response = $this->getJson('/api/v1/members/search?q=John');

        $response->assertStatus(401);
    }

    public function test_authenticated_user_can_search_members_by_name(): void
    {
        $user = User::factory()->create();

        $memberA = ChurchMember::factory()->create([
            'full_name' => 'Stiven Hutapea',
            'membership_number' => 'MB-001',
            'phone' => '081234567890',
        ]);

        $memberB = ChurchMember::factory()->create([
            'full_name' => 'Budi Santoso',
            'membership_number' => 'MB-002',
            'phone' => '089876543210',
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/members/search?q=Stiven');

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonFragment(['full_name' => 'Stiven Hutapea'])
            ->assertJsonMissing(['full_name' => 'Budi Santoso']);
    }

    public function test_authenticated_user_can_search_members_by_membership_number(): void
    {
        $user = User::factory()->create();

        $member = ChurchMember::factory()->create([
            'full_name' => 'Maria Simanjuntak',
            'membership_number' => 'MB-999',
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/members/search?q=MB-999');

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonFragment(['full_name' => 'Maria Simanjuntak', 'membership_number' => 'MB-999']);
    }

    public function test_member_directory_search_masks_phone_and_withholds_full_address(): void
    {
        $user = User::factory()->create();

        $member = ChurchMember::factory()->create([
            'full_name' => 'Poltak Sitorus',
            'phone' => '081234567890',
            'address' => 'Jl. Balige No. 45 Tarutung Private Address',
        ]);

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/members/search?q=Poltak');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    [
                        'full_name' => 'Poltak Sitorus',
                        'masked_phone' => '0812****890',
                    ],
                ],
            ]);

        $json = $response->getContent();
        $this->assertStringNotContainsString('Tarutung Private Address', (string) $json);
        $this->assertStringNotContainsString('081234567890', (string) $json);
    }
}
