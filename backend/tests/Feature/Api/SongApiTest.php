<?php

namespace Tests\Feature\Api;

use App\Models\Song;
use App\Models\Songbook;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SongApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_public_user_can_list_active_songbooks(): void
    {
        $activeSongbook = Songbook::factory()->create(['name' => 'Buku Ende', 'code' => 'BE', 'active' => true]);
        Songbook::factory()->create(['name' => 'Draft Book', 'code' => 'DB', 'active' => false]);

        Song::factory()->create(['songbook_id' => $activeSongbook->id, 'active' => true]);
        Song::factory()->create(['songbook_id' => $activeSongbook->id, 'active' => false]);

        $response = $this->getJson('/api/v1/songbooks');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Songbooks retrieved successfully.',
            ])
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $activeSongbook->id)
            ->assertJsonPath('data.0.name', 'Buku Ende')
            ->assertJsonPath('data.0.code', 'BE')
            ->assertJsonPath('data.0.song_count', 1);
    }

    public function test_public_user_can_list_active_songs_with_pagination(): void
    {
        $songbook = Songbook::factory()->create(['code' => 'BE', 'active' => true]);
        Song::factory()->count(20)->create(['songbook_id' => $songbook->id, 'active' => true]);

        // Inactive song should be excluded
        Song::factory()->create(['songbook_id' => $songbook->id, 'active' => false]);

        $response = $this->getJson('/api/v1/songs');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Songs retrieved successfully.',
            ])
            ->assertJsonCount(15, 'data')
            ->assertJsonPath('meta.total', 20)
            ->assertJsonPath('meta.current_page', 1);
    }

    public function test_public_user_can_search_songs_by_title_lyrics_or_number(): void
    {
        $songbook = Songbook::factory()->create(['code' => 'BE', 'active' => true]);

        $song1 = Song::factory()->create([
            'songbook_id' => $songbook->id,
            'number' => 123,
            'title' => 'Haleluya Puji Tuhan',
            'lyrics' => 'Bait 1: Nyanyikanlah nyanyian baru.',
            'active' => true,
        ]);

        $song2 = Song::factory()->create([
            'songbook_id' => $songbook->id,
            'number' => 456,
            'title' => 'Mulia Bagi Allah',
            'lyrics' => 'Bait 1: Haleluya terpujilah Tuhan.',
            'active' => true,
        ]);

        // Search by title
        $responseTitle = $this->getJson('/api/v1/songs?search=Mulia');
        $responseTitle->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $song2->id);

        // Search by lyrics
        $responseLyrics = $this->getJson('/api/v1/songs?search=nyanyian baru');
        $responseLyrics->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $song1->id);

        // Search by number
        $responseNumber = $this->getJson('/api/v1/songs?search=123');
        $responseNumber->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $song1->id);
    }

    public function test_public_user_can_filter_songs_by_songbook(): void
    {
        $be = Songbook::factory()->create(['code' => 'BE', 'active' => true]);
        $bn = Songbook::factory()->create(['code' => 'BN', 'active' => true]);

        $songBE = Song::factory()->create(['songbook_id' => $be->id, 'number' => 1, 'active' => true]);
        $songBN = Song::factory()->create(['songbook_id' => $bn->id, 'number' => 1, 'active' => true]);

        $response = $this->getJson('/api/v1/songs?songbook_id='.$be->id);

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $songBE->id)
            ->assertJsonPath('data.0.songbook_code', 'BE');
    }

    public function test_public_user_can_view_active_song_details(): void
    {
        $songbook = Songbook::factory()->create(['name' => 'Buku Ende', 'code' => 'BE', 'active' => true]);
        $song = Song::factory()->create([
            'songbook_id' => $songbook->id,
            'number' => 1,
            'title' => 'O Debata Trinunggal',
            'lyrics' => "Bait 1:\nO Debata Trinunggal i.\n\nBait 2:\nPasupasu hami.",
            'active' => true,
        ]);

        $response = $this->getJson('/api/v1/songs/'.$song->id);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Song details retrieved successfully.',
                'data' => [
                    'id' => $song->id,
                    'songbook_id' => $songbook->id,
                    'songbook_name' => 'Buku Ende',
                    'songbook_code' => 'BE',
                    'number' => 1,
                    'title' => 'O Debata Trinunggal',
                    'lyrics' => "Bait 1:\nO Debata Trinunggal i.\n\nBait 2:\nPasupasu hami.",
                ],
            ]);
    }

    public function test_viewing_inactive_or_nonexistent_song_returns_404(): void
    {
        $songbook = Songbook::factory()->create(['code' => 'BE', 'active' => true]);
        $inactiveSong = Song::factory()->create(['songbook_id' => $songbook->id, 'active' => false]);

        $responseInactive = $this->getJson('/api/v1/songs/'.$inactiveSong->id);
        $responseInactive->assertStatus(404)
            ->assertJson([
                'success' => false,
                'message' => 'Song not found.',
            ]);

        $responseNotFound = $this->getJson('/api/v1/songs/99999');
        $responseNotFound->assertStatus(404)
            ->assertJson([
                'success' => false,
                'message' => 'Song not found.',
            ]);
    }
}
