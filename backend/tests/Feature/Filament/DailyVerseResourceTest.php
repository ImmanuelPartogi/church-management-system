<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\DailyVerseResource;
use App\Models\DailyVerse;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class DailyVerseResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_admin_can_render_daily_verse_list(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $verse = DailyVerse::factory()->create();

        $this->actingAs($admin)
            ->get(DailyVerseResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($admin)
            ->test(DailyVerseResource\Pages\ListDailyVerses::class)
            ->assertCanSeeTableRecords([$verse]);
    }

    public function test_unauthorized_user_cannot_access_daily_verses(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(DailyVerseResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_admin_can_create_daily_verse(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        Livewire::actingAs($admin)
            ->test(DailyVerseResource\Pages\CreateDailyVerse::class)
            ->fillForm([
                'verse_reference' => 'Mazmur 23:1',
                'content' => 'TUHAN adalah gembalaku, takkan kekurangan aku.',
                'date' => '2026-12-31',
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('daily_verses', [
            'verse_reference' => 'Mazmur 23:1',
            'date' => '2026-12-31',
        ]);
    }
}
