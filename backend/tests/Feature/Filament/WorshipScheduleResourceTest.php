<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\WorshipScheduleResource;
use App\Models\User;
use App\Models\WorshipSchedule;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class WorshipScheduleResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_admin_can_render_worship_schedule_list(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $schedule = WorshipSchedule::factory()->create();

        $this->actingAs($admin)
            ->get(WorshipScheduleResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($admin)
            ->test(WorshipScheduleResource\Pages\ListWorshipSchedules::class)
            ->assertCanSeeTableRecords([$schedule]);
    }

    public function test_unauthorized_user_cannot_access_worship_schedules(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(WorshipScheduleResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_admin_can_create_worship_schedule(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        Livewire::actingAs($admin)
            ->test(WorshipScheduleResource\Pages\CreateWorshipSchedule::class)
            ->fillForm([
                'title' => 'Ibadah Minggu Subuh',
                'description' => 'Ibadah Minggu pukul 06.00 WIB',
                'day' => 'Sunday',
                'start_time' => '06:00',
                'end_time' => '08:00',
                'location' => 'Gedung Gereja Utama',
                'active' => true,
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('worship_schedules', [
            'title' => 'Ibadah Minggu Subuh',
            'day' => 'Sunday',
        ]);
    }
}
