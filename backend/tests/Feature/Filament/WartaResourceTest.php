<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\WartaResource;
use App\Jobs\SendChurchWartaBroadcastJob;
use App\Models\Church;
use App\Models\User;
use App\Models\Warta;
use Database\Seeders\ModuleSeeder;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Queue;
use Livewire\Livewire;
use Tests\TestCase;

class WartaResourceTest extends TestCase
{
    use RefreshDatabase;

    protected Church $church;

    protected User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(RolesAndPermissionsSeeder::class);
        $this->seed(ModuleSeeder::class);

        $this->church = app('current_church');

        $this->admin = User::factory()->create();
        $this->admin->assignRole('church_admin');
    }

    public function test_admin_can_dispatch_warta_broadcast_notification(): void
    {
        Queue::fake();

        $warta = Warta::create([
            'church_id' => $this->church->id,
            'title' => 'Warta Minggu Trinitatis',
            'description' => 'Susunan acara ibadah dan keuangan mingguan',
            'file_path' => 'wartas/trinitatis.pdf',
            'is_published' => true,
            'published_at' => now(),
        ]);

        $this->actingAs($this->admin);

        Livewire::test(WartaResource\Pages\ListWartas::class)
            ->callTableAction('sendNotification', $warta, data: [
                'title' => 'Warta Jemaat: Warta Minggu Trinitatis',
                'body' => 'Susunan acara ibadah dan keuangan mingguan',
                'route' => '/wartas',
            ])
            ->assertHasNoTableActionErrors();

        Queue::assertPushed(SendChurchWartaBroadcastJob::class, function ($job) use ($warta) {
            return $job->wartaId === $warta->id
                && $job->title === 'Warta Jemaat: Warta Minggu Trinitatis'
                && $job->getChurchId() === $this->church->id;
        });
    }
}
