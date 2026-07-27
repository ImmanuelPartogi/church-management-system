<?php

namespace Tests\Feature\Api;

use App\Models\DailyVerse;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\TestCase;

class DailyVerseApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test retrieving today's daily verse.
     */
    public function test_can_retrieve_todays_daily_verse(): void
    {
        DailyVerse::create([
            'verse_reference' => 'Genesis 1:1',
            'content' => 'In the beginning, God created the heavens and the earth.',
            'date' => Carbon::today()->toDateString(),
        ]);

        $response = $this->getJson('/api/v1/daily-verse');

        $response->assertStatus(200)
            ->assertJson([
                'data' => [
                    'verse_reference' => 'Genesis 1:1',
                    'content' => 'In the beginning, God created the heavens and the earth.',
                    'date' => Carbon::today()->toDateString(),
                ],
            ]);
    }

    /**
     * Test falling back to the latest verse when today's is missing.
     */
    public function test_daily_verse_falls_back_to_latest_available_if_today_missing(): void
    {
        // Only seed yesterday's verse
        DailyVerse::create([
            'verse_reference' => 'Psalm 23:1',
            'content' => 'The Lord is my shepherd.',
            'date' => Carbon::today()->subDay()->toDateString(),
        ]);

        $response = $this->getJson('/api/v1/daily-verse');

        $response->assertStatus(200)
            ->assertJson([
                'data' => [
                    'verse_reference' => 'Psalm 23:1',
                    'date' => Carbon::today()->subDay()->toDateString(),
                ],
            ]);
    }
}
