<?php

namespace Tests\Feature\Api;

use App\Models\Announcement;
use App\Models\ChurchMember;
use App\Models\ChurchServant;
use App\Models\Sermon;
use App\Models\Song;
use App\Models\User;
use App\Models\Warta;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SearchApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_search_fails_validation_when_query_is_missing_or_too_short(): void
    {
        $response = $this->getJson('/api/v1/search');
        $response->assertStatus(422);

        $responseShort = $this->getJson('/api/v1/search?q=a');
        $responseShort->assertStatus(422);
    }

    public function test_global_search_returns_aggregated_results_for_public_modules(): void
    {
        Announcement::factory()->create([
            'title' => 'Pengumuman Kasih Kristus',
            'status' => 'published',
            'published_at' => now()->subDay(),
        ]);

        Sermon::factory()->create([
            'title' => 'Khotbah tentang Kasih',
            'is_published' => true,
            'published_at' => now()->subDay(),
        ]);

        Song::factory()->create([
            'title' => 'Kasih Allah',
            'active' => true,
        ]);

        Warta::factory()->create([
            'title' => 'Warta Jemaat Kasih',
            'is_published' => true,
            'published_at' => now()->subDay(),
        ]);

        ChurchServant::factory()->create([
            'name' => 'St. Kasih',
            'active' => true,
        ]);

        $response = $this->getJson('/api/v1/search?q=kasih');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.query', 'kasih')
            ->assertJsonPath('data.meta.total', 5)
            ->assertJsonPath('data.meta.counts.announcements', 1)
            ->assertJsonPath('data.meta.counts.sermons', 1)
            ->assertJsonPath('data.meta.counts.hymns', 1)
            ->assertJsonPath('data.meta.counts.wartas', 1)
            ->assertJsonPath('data.meta.counts.servants', 1);
    }

    public function test_unauthenticated_search_excludes_member_results_for_privacy(): void
    {
        ChurchMember::factory()->create([
            'full_name' => 'Budi Kasih',
            'status' => 'active',
        ]);

        $response = $this->getJson('/api/v1/search?q=kasih');

        $response->assertStatus(200)
            ->assertJsonPath('data.meta.counts.members', 0);
    }

    public function test_authenticated_search_includes_masked_member_results(): void
    {
        $user = User::factory()->create();
        ChurchMember::factory()->create([
            'full_name' => 'Budi Kasih',
            'status' => 'active',
            'phone' => '081234567890',
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/search?q=kasih');

        $response->assertStatus(200)
            ->assertJsonPath('data.meta.counts.members', 1)
            ->assertJsonPath('data.results.members.0.full_name', 'Budi Kasih')
            ->assertJsonPath('data.results.members.0.masked_phone', '0812****890');
    }
}
