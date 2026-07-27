<?php

namespace Tests\Feature\Api;

use App\Models\Announcement;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\TestCase;

class AnnouncementApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test retrieval of published announcements.
     */
    public function test_can_retrieve_published_announcements(): void
    {
        // 1. Published announcement in past
        Announcement::create([
            'title' => 'Published Past Announcement',
            'content' => 'Content here',
            'published_at' => Carbon::now()->subDays(2),
            'status' => 'published',
        ]);

        // 2. Draft announcement
        Announcement::create([
            'title' => 'Draft Announcement',
            'content' => 'Content here',
            'published_at' => Carbon::now()->subDays(2),
            'status' => 'draft',
        ]);

        // 3. Published announcement in future (scheduled)
        Announcement::create([
            'title' => 'Future Announcement',
            'content' => 'Content here',
            'published_at' => Carbon::now()->addDays(2),
            'status' => 'published',
        ]);

        $response = $this->getJson('/api/v1/announcements');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'title',
                        'content',
                        'image',
                        'published_at',
                        'status',
                    ],
                ],
                'links',
                'meta',
            ]);

        // Should only return the past published announcement (1 out of 3)
        $this->assertCount(1, $response->json('data'));
        $this->assertEquals('Published Past Announcement', $response->json('data.0.title'));
    }
}
