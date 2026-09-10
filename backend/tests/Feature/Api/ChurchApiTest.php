<?php

namespace Tests\Feature\Api;

use App\Models\Church;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class ChurchApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test public client can fetch active churches list.
     */
    public function test_public_can_fetch_active_churches_list(): void
    {
        $churchA = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Bandung Resort',
            'slug' => 'hkbp-bandung',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'address' => 'Jl. Riau No. 10, Bandung',
            'phone' => '+6281234567890',
        ]);

        $churchB = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Medan Resort',
            'slug' => 'hkbp-medan',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'address' => 'Jl. Sudirman No. 5, Medan',
            'phone' => '+6281234567891',
        ]);

        $response = $this->getJson('/api/v1/churches');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Active churches retrieved successfully.',
            ])
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'uuid',
                        'name',
                        'slug',
                        'timezone',
                        'address',
                        'phone',
                        'logo_url',
                    ],
                ],
            ]);

        $names = collect($response->json('data'))->pluck('name');
        $this->assertTrue($names->contains('HKBP Bandung Resort'));
        $this->assertTrue($names->contains('HKBP Medan Resort'));
    }

    /**
     * Test suspended churches are strictly excluded from public list.
     */
    public function test_suspended_churches_are_strictly_excluded_from_public_list(): void
    {
        $activeChurch = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Aktif',
            'slug' => 'hkbp-aktif',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        $suspendedChurch = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Ditangguhkan',
            'slug' => 'hkbp-suspended',
            'status' => 'suspended',
            'timezone' => 'Asia/Jakarta',
        ]);

        $response = $this->getJson('/api/v1/churches');

        $response->assertStatus(200);

        $slugs = collect($response->json('data'))->pluck('slug');
        $this->assertTrue($slugs->contains('hkbp-aktif'));
        $this->assertFalse($slugs->contains('hkbp-suspended'));
    }

    /**
     * Test public endpoint works without tenant headers or authentication.
     */
    public function test_public_endpoint_works_without_tenant_headers_or_authentication(): void
    {
        $response = $this->getJson('/api/v1/churches');

        $response->assertStatus(200)
            ->assertJson(['success' => true]);
    }
}
