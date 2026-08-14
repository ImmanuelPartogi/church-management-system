<?php

namespace Tests\Feature\Api;

use App\Models\Sermon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SermonApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_published_sermons(): void
    {
        Sermon::factory()->create([
            'title' => 'Khotbah Minggu Pemuda',
            'preacher_name' => 'Pdt. Stiven Hutapea',
            'is_published' => true,
            'published_at' => now()->subDay(),
        ]);

        Sermon::factory()->create([
            'title' => 'Draft Khotbah Unpublished',
            'is_published' => false,
            'published_at' => null,
        ]);

        $response = $this->getJson('/api/v1/sermons');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonFragment([
                'title' => 'Khotbah Minggu Pemuda',
                'preacher_name' => 'Pdt. Stiven Hutapea',
            ]);
    }

    public function test_can_filter_sermons_by_search_keyword(): void
    {
        Sermon::factory()->create([
            'title' => 'Kasih Allah yang Sempurna',
            'preacher_name' => 'Pdt. Stiven Hutapea',
            'is_published' => true,
            'published_at' => now()->subDay(),
        ]);

        Sermon::factory()->create([
            'title' => 'Pengharapan di Tengah Badai',
            'preacher_name' => 'St. Maria Simanjuntak',
            'is_published' => true,
            'published_at' => now()->subDays(2),
        ]);

        $response = $this->getJson('/api/v1/sermons?search=Kasih');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonFragment(['title' => 'Kasih Allah yang Sempurna']);
    }

    public function test_can_download_sermon_and_increment_counter(): void
    {
        $sermon = Sermon::factory()->create([
            'title' => 'Khotbah Minggu',
            'is_published' => true,
            'published_at' => now()->subDay(),
            'download_count' => 5,
        ]);

        $response = $this->getJson("/api/v1/sermons/{$sermon->id}/download");

        $response->assertStatus(200)
            ->assertJsonPath('data.download_count', 6);

        $this->assertDatabaseHas('sermons', [
            'id' => $sermon->id,
            'download_count' => 6,
        ]);
    }
}
