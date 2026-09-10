<?php

namespace Tests\Feature\Filament;

use App\Filament\Widgets\StatsOverviewWidget;
use App\Models\Church;
use App\Models\ChurchMember;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Livewire\Livewire;
use Tests\TestCase;

class StatsOverviewWidgetTest extends TestCase
{
    use RefreshDatabase;

    protected Church $church;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);

        $this->church = Church::firstOrCreate(
            ['slug' => 'default'],
            [
                'uuid' => (string) Str::uuid(),
                'name' => 'Default Church',
                'status' => 'active',
                'timezone' => 'Asia/Jakarta',
            ]
        );
        app()->instance('current_church_id', $this->church->id);
        app()->instance('current_church', $this->church);
    }

    public function test_stats_overview_widget_renders_successfully_with_church_context(): void
    {
        $admin = User::factory()->create(['is_super_admin' => true]);

        ChurchMember::factory()->create([
            'church_id' => $this->church->id,
            'full_name' => 'John Member',
        ]);

        Livewire::actingAs($admin)
            ->test(StatsOverviewWidget::class)
            ->assertSuccessful()
            ->assertSee('Total Jemaat')
            ->assertSee('Pelayan Gereja');
    }
}
