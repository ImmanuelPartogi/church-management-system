<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\SongResource;
use App\Models\Song;
use App\Models\Songbook;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class SongResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_pastor_can_render_song_list(): void
    {
        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        $song = Song::factory()->create();

        $this->actingAs($pastor)
            ->get(SongResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($pastor)
            ->test(SongResource\Pages\ListSongs::class)
            ->assertCanSeeTableRecords([$song]);
    }

    public function test_unauthorized_user_cannot_access_songs(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(SongResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_pastor_can_create_song(): void
    {
        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        $songbook = Songbook::factory()->create(['code' => 'BE']);

        Livewire::actingAs($pastor)
            ->test(SongResource\Pages\CreateSong::class)
            ->fillForm([
                'songbook_id' => $songbook->id,
                'number' => 1,
                'title' => 'Ringgas Ma Tondinghu',
                'lyrics' => 'Ringgas ma tondinghu mamuji Debata...',
                'active' => true,
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('songs', [
            'songbook_id' => $songbook->id,
            'number' => 1,
            'title' => 'Ringgas Ma Tondinghu',
        ]);
    }
}
