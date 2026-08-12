<?php

namespace Tests\Feature\Api;

use App\Models\Warta;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class WartaApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_published_wartas(): void
    {
        $publishedWarta = Warta::factory()->create([
            'title' => 'Warta Published',
            'is_published' => true,
            'published_at' => now()->subDay(),
        ]);

        $unpublishedWarta = Warta::factory()->create([
            'title' => 'Warta Draft',
            'is_published' => false,
            'published_at' => null,
        ]);

        $response = $this->getJson('/api/v1/wartas');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonFragment(['title' => 'Warta Published'])
            ->assertJsonMissing(['title' => 'Warta Draft']);
    }

    public function test_can_view_published_warta_detail(): void
    {
        $warta = Warta::factory()->create([
            'title' => 'Warta Detail Test',
            'is_published' => true,
            'published_at' => now()->subHour(),
        ]);

        $response = $this->getJson('/api/v1/wartas/'.$warta->id);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $warta->id,
                    'title' => 'Warta Detail Test',
                ],
            ]);
    }

    public function test_cannot_view_unpublished_warta_detail(): void
    {
        $warta = Warta::factory()->create([
            'is_published' => false,
            'published_at' => null,
        ]);

        $response = $this->getJson('/api/v1/wartas/'.$warta->id);

        $response->assertStatus(404)
            ->assertJson([
                'success' => false,
                'message' => 'Warta not found.',
            ]);
    }

    public function test_can_download_published_warta_and_increment_counter(): void
    {
        Storage::fake('public');

        $file = UploadedFile::fake()->create('warta-minggu.pdf', 100, 'application/pdf');
        $filePath = Storage::disk('public')->putFile('wartas', $file);

        $warta = Warta::factory()->create([
            'is_published' => true,
            'published_at' => now()->subHour(),
            'file_path' => $filePath,
            'file_name' => 'warta-minggu.pdf',
            'download_count' => 5,
        ]);

        $response = $this->get('/api/v1/wartas/'.$warta->id.'/download');

        $response->assertStatus(200);

        $warta->refresh();
        $this->assertEquals(6, $warta->download_count);
    }

    public function test_download_missing_file_returns_404(): void
    {
        $warta = Warta::factory()->create([
            'is_published' => true,
            'published_at' => now()->subHour(),
            'file_path' => 'wartas/non-existent-file.pdf',
        ]);

        $response = $this->getJson('/api/v1/wartas/'.$warta->id.'/download');

        $response->assertStatus(404)
            ->assertJson([
                'success' => false,
                'message' => 'Warta file not found on server.',
            ]);
    }

    public function test_download_invalid_warta_id_returns_404(): void
    {
        $response = $this->getJson('/api/v1/wartas/99999/download');

        $response->assertStatus(404)
            ->assertJson([
                'success' => false,
                'message' => 'Warta not found.',
            ]);
    }
}
