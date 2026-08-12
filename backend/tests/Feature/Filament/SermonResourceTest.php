<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\SermonResource;
use App\Models\ChurchServant;
use App\Models\Sermon;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Livewire\Livewire;
use Tests\TestCase;

class SermonResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_pastor_can_render_sermon_list(): void
    {
        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        $sermon = Sermon::factory()->create();

        $this->actingAs($pastor)
            ->get(SermonResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($pastor)
            ->test(SermonResource\Pages\ListSermons::class)
            ->assertCanSeeTableRecords([$sermon]);
    }

    public function test_unauthorized_user_cannot_access_sermons(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(SermonResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_pastor_can_create_sermon_with_audio_upload(): void
    {
        Storage::fake('public');

        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        $servant = ChurchServant::factory()->create();

        $file = UploadedFile::fake()->create('khotbah-minggu.mp3', 1000, 'audio/mpeg');

        Livewire::actingAs($pastor)
            ->test(SermonResource\Pages\CreateSermon::class)
            ->fillForm([
                'title' => 'Khotbah Minggu XIV: Hidup Dalam Kasih',
                'preacher_name' => 'Pdt. B. Simanjuntak, S.Th',
                'servant_id' => $servant->id,
                'file_path' => $file,
                'published_at' => now(),
                'is_published' => true,
                'description' => 'Bahan perenungan Minggu XIV Setelah Trinitatis',
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('sermons', [
            'title' => 'Khotbah Minggu XIV: Hidup Dalam Kasih',
            'preacher_name' => 'Pdt. B. Simanjuntak, S.Th',
            'is_published' => true,
        ]);
    }
}
