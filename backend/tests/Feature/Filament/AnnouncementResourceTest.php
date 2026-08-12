<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\AnnouncementResource;
use App\Models\Announcement;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class AnnouncementResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_admin_can_render_announcement_list(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $announcement = Announcement::factory()->create();

        $this->actingAs($admin)
            ->get(AnnouncementResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($admin)
            ->test(AnnouncementResource\Pages\ListAnnouncements::class)
            ->assertCanSeeTableRecords([$announcement]);
    }

    public function test_unauthorized_user_cannot_access_announcements(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(AnnouncementResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_admin_can_create_announcement(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        Livewire::actingAs($admin)
            ->test(AnnouncementResource\Pages\CreateAnnouncement::class)
            ->fillForm([
                'title' => 'Pengumuman Gotong Royong',
                'content' => 'Akan dilaksanakan kebersihan lingkungan gereja hari Sabtu.',
                'status' => 'published',
                'published_at' => now(),
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('announcements', [
            'title' => 'Pengumuman Gotong Royong',
            'status' => 'published',
        ]);
    }
}
