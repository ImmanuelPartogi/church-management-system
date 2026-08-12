<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\WartaResource;
use App\Models\User;
use App\Models\Warta;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Livewire\Livewire;
use Tests\TestCase;

class WartaResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_admin_can_render_warta_list(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $warta = Warta::factory()->create();

        $this->actingAs($admin)
            ->get(WartaResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($admin)
            ->test(WartaResource\Pages\ListWartas::class)
            ->assertCanSeeTableRecords([$warta]);
    }

    public function test_unauthorized_user_cannot_access_wartas(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(WartaResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_admin_can_create_warta(): void
    {
        Storage::fake('public');

        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $file = UploadedFile::fake()->create('warta-minggu.pdf', 100, 'application/pdf');

        Livewire::actingAs($admin)
            ->test(WartaResource\Pages\CreateWarta::class)
            ->fillForm([
                'title' => 'Warta Jemaat Minggu XIV',
                'description' => 'Warta jemaat edisi minggu ke 14',
                'file_path' => $file,
                'published_at' => now(),
                'is_published' => true,
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('wartas', [
            'title' => 'Warta Jemaat Minggu XIV',
            'is_published' => true,
        ]);
    }
}
