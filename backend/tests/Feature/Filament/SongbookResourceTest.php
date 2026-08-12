<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\SongbookResource;
use App\Models\Songbook;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class SongbookResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_pastor_can_render_songbook_list(): void
    {
        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        $songbook = Songbook::factory()->create();

        $this->actingAs($pastor)
            ->get(SongbookResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($pastor)
            ->test(SongbookResource\Pages\ListSongbooks::class)
            ->assertCanSeeTableRecords([$songbook]);
    }

    public function test_unauthorized_user_cannot_access_songbooks(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(SongbookResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_pastor_can_create_songbook(): void
    {
        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        Livewire::actingAs($pastor)
            ->test(SongbookResource\Pages\CreateSongbook::class)
            ->fillForm([
                'name' => 'Buku Ende HKBP',
                'code' => 'BE',
                'description' => 'Buku Ende HKBP resmi',
                'active' => true,
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('songbooks', [
            'name' => 'Buku Ende HKBP',
            'code' => 'BE',
        ]);
    }
}
