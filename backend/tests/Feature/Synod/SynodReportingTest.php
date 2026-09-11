<?php

namespace Tests\Feature\Synod;

use App\Enums\DonationStatus;
use App\Exceptions\Queue\UnauthorizedCrossTenantDispatchException;
use App\Jobs\GenerateSynodReportSnapshotJob;
use App\Models\Church;
use App\Models\ChurchMember;
use App\Models\ChurchModule;
use App\Models\DonationConfirmation;
use App\Models\ServiceFormApplication;
use App\Models\SynodReportSnapshot;
use App\Models\User;
use Database\Seeders\ModuleSeeder;
use Illuminate\Bus\UniqueLock;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

class SynodReportingTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(ModuleSeeder::class);
    }

    public function test_generate_synod_report_snapshot_calculates_and_separates_active_vs_suspended_churches(): void
    {
        // 1. Arrange: Church A (active default church) and Church B (suspended)
        $churchActive = Church::first();
        $churchActive->update([
            'name' => 'HKBP Sudirman (Active)',
            'status' => 'active',
        ]);

        $churchSuspended = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Bandung (Suspended)',
            'slug' => 'hkbp-bandung-suspended',
            'status' => 'suspended',
        ]);

        // 2. Members: 3 in active, 2 in suspended
        $membersActive = ChurchMember::factory()->count(3)->create([
            'church_id' => $churchActive->id,
            'status' => 'active',
        ]);

        $membersSuspended = ChurchMember::factory()->count(2)->create([
            'church_id' => $churchSuspended->id,
            'status' => 'active',
        ]);

        // 3. Donations: Rp 100,000 in active, Rp 50,000 in suspended
        DonationConfirmation::factory()->approved()->create([
            'church_id' => $churchActive->id,
            'member_id' => $membersActive->first()->id,
            'user_id' => $membersActive->first()->user_id,
            'amount' => 100000.00,
        ]);

        DonationConfirmation::factory()->approved()->create([
            'church_id' => $churchSuspended->id,
            'member_id' => $membersSuspended->first()->id,
            'user_id' => $membersSuspended->first()->user_id,
            'amount' => 50000.00,
        ]);

        // Also add a pending donation to active church (should be excluded from total approved)
        DonationConfirmation::factory()->create([
            'church_id' => $churchActive->id,
            'member_id' => $membersActive->first()->id,
            'user_id' => $membersActive->first()->user_id,
            'amount' => 20000.00,
            'status' => DonationStatus::Pending,
        ]);

        // 4. Sacraments
        ServiceFormApplication::factory()->create([
            'church_id' => $churchActive->id,
            'member_id' => $membersActive->first()->id,
            'user_id' => $membersActive->first()->user_id,
        ]);

        ServiceFormApplication::factory()->create([
            'church_id' => $churchSuspended->id,
            'member_id' => $membersSuspended->first()->id,
            'user_id' => $membersSuspended->first()->user_id,
        ]);

        // 5. Act: Execute job synchronously in system console mode
        GenerateSynodReportSnapshotJob::dispatchSync('2026-09-10');

        // 6. Assert: Verify snapshot record exists and matches exact symmetric definitions
        $snapshot = SynodReportSnapshot::latestSnapshot();
        $this->assertNotNull($snapshot);
        $this->assertEquals('2026-09-10', $snapshot->period_date->toDateString());

        // Churches
        $this->assertSame(2, $snapshot->total_churches);
        $this->assertSame(1, $snapshot->active_churches);
        $this->assertSame(1, $snapshot->suspended_churches);

        // Members
        $this->assertSame(3, $snapshot->total_active_members);
        $this->assertSame(5, $snapshot->total_all_members);

        // Donations (only verified)
        $this->assertEquals(100000.00, (float) $snapshot->total_active_donations);
        $this->assertEquals(150000.00, (float) $snapshot->total_all_donations);

        // Sacraments
        $this->assertSame(1, $snapshot->total_active_sacraments);
        $this->assertSame(2, $snapshot->total_all_sacraments);

        // Church comparisons JSON breakdown
        $this->assertIsArray($snapshot->church_comparisons);
        $this->assertCount(2, $snapshot->church_comparisons);

        $statuses = array_column($snapshot->church_comparisons, 'status');
        $this->assertContains('active', $statuses);
        $this->assertContains('suspended', $statuses);

        // Provisioning status: both churches should be provisioned (via booted() hook and ModuleSeeder)
        foreach ($snapshot->church_comparisons as $comparison) {
            $this->assertArrayHasKey('provisioning_status', $comparison);
            $this->assertArrayHasKey('total_modules_provisioned', $comparison);
            $this->assertSame('provisioned', $comparison['provisioning_status']);
            $this->assertGreaterThan(0, $comparison['total_modules_provisioned']);
        }

        // Module adoption JSON breakdown
        $this->assertIsArray($snapshot->module_adoption);
        $this->assertNotEmpty($snapshot->module_adoption);
        foreach ($snapshot->module_adoption as $adoptionRow) {
            $this->assertArrayHasKey('key', $adoptionRow);
            $this->assertArrayHasKey('adoption_percentage', $adoptionRow);
            $this->assertSame(1, $adoptionRow['total_active_churches']);
        }
    }

    public function test_church_comparisons_distinguishes_unprovisioned_from_all_modules_disabled(): void
    {
        // Arrange: Church A is the default provisioned church, Church B has no modules at all (unprovisioned)
        $churchProvisioned = Church::first();

        // Create Church B WITHOUT triggering booted() auto-provisioning:
        // We bypass the model event by inserting directly via query builder.
        $churchUnprovisionedId = DB::table('churches')->insertGetId([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Legacy (Unprovisioned)',
            'slug' => 'hkbp-legacy-unprovisioned',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Verify: Church B truly has 0 rows in church_modules
        $this->assertSame(0, ChurchModule::where('church_id', $churchUnprovisionedId)->count());

        // Act
        GenerateSynodReportSnapshotJob::dispatchSync();

        // Assert
        $snapshot = SynodReportSnapshot::latestSnapshot();
        $this->assertNotNull($snapshot);

        $comparisons = collect($snapshot->church_comparisons);
        $this->assertCount(2, $comparisons);

        // Provisioned church
        $provisioned = $comparisons->firstWhere('id', $churchProvisioned->id);
        $this->assertSame('provisioned', $provisioned['provisioning_status']);
        $this->assertGreaterThan(0, $provisioned['total_modules_provisioned']);

        // Unprovisioned legacy church
        $unprovisioned = $comparisons->firstWhere('id', $churchUnprovisionedId);
        $this->assertSame('unprovisioned', $unprovisioned['provisioning_status']);
        $this->assertSame(0, $unprovisioned['total_modules_provisioned']);
        $this->assertSame(0, $unprovisioned['active_modules_count']);
    }

    public function test_cross_tenant_dispatcher_guard_allows_super_admin_and_records_user_id(): void
    {
        $superAdmin = User::factory()->create([
            'is_super_admin' => true,
        ]);

        $this->actingAs($superAdmin);

        GenerateSynodReportSnapshotJob::dispatchSync();

        $snapshot = SynodReportSnapshot::latestSnapshot();
        $this->assertNotNull($snapshot);
        $this->assertSame($superAdmin->id, $snapshot->generated_by_user_id);
    }

    public function test_cross_tenant_dispatcher_guard_blocks_non_super_admin_outside_console(): void
    {
        $regularUser = User::factory()->create([
            'is_super_admin' => false,
        ]);

        $this->actingAs($regularUser);

        $this->expectException(UnauthorizedCrossTenantDispatchException::class);
        $this->expectExceptionMessage('Only Super Administrators are authorized to dispatch cross-tenant background jobs.');

        new GenerateSynodReportSnapshotJob;
    }

    public function test_should_be_unique_prevents_concurrent_runs_on_production_database_cache_driver(): void
    {
        // Explicitly switch cache store to 'database' (which uses cache_locks table in production)
        config(['cache.default' => 'database']);

        $job = new GenerateSynodReportSnapshotJob;
        $this->assertSame('database', config('cache.default'));

        $uniqueLock = new UniqueLock($job->uniqueVia());

        // 1. Acquire initial lock
        $acquiredFirst = $uniqueLock->acquire($job);
        $this->assertTrue($acquiredFirst, 'Initial unique lock on database cache store must succeed.');

        // 2. Attempt concurrent acquire with identical unique key
        $acquiredSecond = $uniqueLock->acquire($job);
        $this->assertFalse($acquiredSecond, 'Concurrent unique lock on database cache store must be rejected.');

        // 3. Release lock
        $uniqueLock->release($job);

        // 4. Acquire again after release
        $acquiredThird = $uniqueLock->acquire($job);
        $this->assertTrue($acquiredThird, 'Unique lock must become acquirable again after previous release.');

        $uniqueLock->release($job);
    }

    public function test_cli_command_generates_snapshot_in_system_mode(): void
    {
        $code = Artisan::call('synod:generate-report', ['--sync' => true]);

        $this->assertSame(0, $code);

        $snapshot = SynodReportSnapshot::latestSnapshot();
        $this->assertNotNull($snapshot);
        $this->assertNull($snapshot->generated_by_user_id);
    }

    public function test_deterministic_latest_snapshot_resolution_orders_by_created_at_desc_and_id_desc(): void
    {
        $older = SynodReportSnapshot::create([
            'period_date' => '2026-09-01',
            'total_churches' => 5,
            'created_at' => now()->subHours(2),
        ]);

        $newer = SynodReportSnapshot::create([
            'period_date' => '2026-09-01',
            'total_churches' => 6,
            'created_at' => now()->subHour(1),
        ]);

        $latest = SynodReportSnapshot::latestSnapshot();

        $this->assertNotNull($latest);
        $this->assertSame($newer->id, $latest->id);
        $this->assertSame(6, $latest->total_churches);
    }
}
