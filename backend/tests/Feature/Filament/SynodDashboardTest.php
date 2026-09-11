<?php

namespace Tests\Feature\Filament;

use App\Filament\Pages\SynodDashboard;
use App\Filament\Widgets\SynodChurchesComparisonWidget;
use App\Filament\Widgets\SynodOverviewStatsWidget;
use App\Jobs\GenerateSynodReportSnapshotJob;
use App\Models\Church;
use App\Models\ChurchMember;
use App\Models\DonationConfirmation;
use App\Models\SynodReportSnapshot;
use App\Models\User;
use Database\Seeders\ModuleSeeder;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Str;
use Livewire\Livewire;
use Tests\TestCase;

class SynodDashboardTest extends TestCase
{
    use RefreshDatabase;

    protected User $superAdmin;

    protected User $churchAdmin;

    protected Church $churchA;

    protected Church $churchB;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(RolesAndPermissionsSeeder::class);
        $this->seed(ModuleSeeder::class);

        $this->churchA = Church::where('slug', 'default')->first();
        $this->churchA->update(['name' => 'HKBP Sudirman Active']);

        $this->churchB = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Bandung Suspended',
            'slug' => 'hkbp-bandung-suspended',
            'status' => 'suspended',
            'timezone' => 'Asia/Jakarta',
        ]);

        $this->superAdmin = User::create([
            'name' => 'Super Admin',
            'email' => 'superadmin@synod.org',
            'password' => bcrypt('password'),
            'is_super_admin' => true,
        ]);

        $this->churchAdmin = User::create([
            'name' => 'Church Admin',
            'email' => 'admin@sudirman.org',
            'password' => bcrypt('password'),
            'is_super_admin' => false,
        ]);

        $this->churchA->memberships()->create([
            'user_id' => $this->churchAdmin->id,
            'role' => 'church_admin',
            'status' => 'active',
        ]);

        app()->instance('current_church_id', $this->churchA->id);
        app()->instance('current_church', $this->churchA);
    }

    public function test_can_access_returns_true_for_super_admin_and_false_for_regular_admin(): void
    {
        $this->actingAs($this->superAdmin);
        $this->assertTrue(SynodDashboard::canAccess());

        $this->actingAs($this->churchAdmin);
        $this->assertFalse(SynodDashboard::canAccess());

        auth()->logout();
        $this->assertFalse(SynodDashboard::canAccess());
    }

    public function test_synod_dashboard_page_mount_records_audit_log(): void
    {
        Log::shouldReceive('channel')
            ->with('single')
            ->once()
            ->andReturnSelf();

        Log::shouldReceive('info')
            ->once()
            ->with('SynodDashboard.accessed', \Mockery::on(function (array $payload) {
                return $payload['user_id'] === $this->superAdmin->id
                    && $payload['user_email'] === $this->superAdmin->email;
            }));

        Livewire::actingAs($this->superAdmin)
            ->test(SynodDashboard::class)
            ->assertSuccessful();
    }

    public function test_synod_dashboard_generate_snapshot_action_dispatches_job_and_logs_audit(): void
    {
        Queue::fake();

        Log::shouldReceive('channel')
            ->with('single')
            ->twice() // 1 for mount, 1 for action
            ->andReturnSelf();

        Log::shouldReceive('info')
            ->once()
            ->with('SynodDashboard.accessed', \Mockery::any());

        Log::shouldReceive('info')
            ->once()
            ->with('SynodDashboard.snapshot_triggered', \Mockery::on(function (array $payload) {
                return $payload['user_id'] === $this->superAdmin->id
                    && $payload['user_email'] === $this->superAdmin->email
                    && ! empty($payload['period_date']);
            }));

        Livewire::actingAs($this->superAdmin)
            ->test(SynodDashboard::class)
            ->callAction('generateSnapshot')
            ->assertNotified('Job laporan sinode berhasil di-dispatch ke antrean.');

        Queue::assertPushed(GenerateSynodReportSnapshotJob::class);
    }

    public function test_synod_overview_stats_widget_displays_empty_state_when_no_snapshot(): void
    {
        SynodReportSnapshot::query()->delete();

        Livewire::actingAs($this->superAdmin)
            ->test(SynodOverviewStatsWidget::class)
            ->assertSuccessful()
            ->assertSee('Belum Ada Data')
            ->assertSee('Klik "Generate Laporan Terbaru"');
    }

    public function test_synod_overview_stats_widget_displays_metrics_with_active_suspended_split(): void
    {
        // Arrange: Create members and donations
        $memberA = ChurchMember::factory()->create([
            'church_id' => $this->churchA->id,
            'status' => 'active',
        ]);
        $memberB = ChurchMember::factory()->create([
            'church_id' => $this->churchB->id,
            'status' => 'active',
        ]);

        DonationConfirmation::factory()->approved()->create([
            'church_id' => $this->churchA->id,
            'member_id' => $memberA->id,
            'user_id' => $memberA->user_id,
            'amount' => 1500000.00,
        ]);
        DonationConfirmation::factory()->approved()->create([
            'church_id' => $this->churchB->id,
            'member_id' => $memberB->id,
            'user_id' => $memberB->user_id,
            'amount' => 500000.00,
        ]);

        // Act: Generate snapshot
        GenerateSynodReportSnapshotJob::dispatchSync();

        // Assert: Overview stats widget reflects split
        Livewire::actingAs($this->superAdmin)
            ->test(SynodOverviewStatsWidget::class)
            ->assertSuccessful()
            ->assertSee('Total Gereja')
            ->assertSee('1 aktif · 1 ditangguhkan')
            ->assertSee('Jemaat (Gereja Aktif)')
            ->assertSee('Rp 1.500.000')
            ->assertSee('Rp 2.000.000 total seluruh gereja')
            ->assertSee('Semua gereja sudah terprovisioning');
    }

    public function test_synod_overview_stats_widget_flags_unprovisioned_churches(): void
    {
        // Create an unprovisioned legacy church via DB insert (bypassing booted hook)
        DB::table('churches')->insert([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Legacy Unprovisioned',
            'slug' => 'hkbp-legacy-unprov',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        GenerateSynodReportSnapshotJob::dispatchSync();

        Livewire::actingAs($this->superAdmin)
            ->test(SynodOverviewStatsWidget::class)
            ->assertSuccessful()
            ->assertSee('Gereja Belum Terkonfigurasi')
            ->assertSee('Perlu backfill: php artisan churches:backfill-modules');
    }

    public function test_synod_churches_comparison_widget_renders_visual_distinctions_for_provisioning_status(): void
    {
        // Insert legacy unprovisioned church
        $legacyId = DB::table('churches')->insertGetId([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Legacy Alpha',
            'slug' => 'hkbp-legacy-alpha',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        GenerateSynodReportSnapshotJob::dispatchSync();

        Livewire::actingAs($this->superAdmin)
            ->test(SynodChurchesComparisonWidget::class)
            ->assertSuccessful()
            // Headers
            ->assertSee('Nama Gereja')
            ->assertSee('Konfigurasi Modul')
            ->assertSee('Modul Aktif')
            // Provisioned church badges
            ->assertSee('HKBP Sudirman Active')
            ->assertSee('Terkonfigurasi')
            // Unprovisioned church badges
            ->assertSee('HKBP Legacy Alpha')
            ->assertSee('Belum Terkonfigurasi')
            // In the active modules column, unprovisioned shows em-dash
            ->assertSee('—');
    }
}
