<?php

namespace Tests\Feature\Tenant;

use App\Models\Church;
use App\Models\ChurchModule;
use App\Models\Module;
use App\Services\Tenant\ChurchModuleService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

class ChurchModulesBackfillCommandTest extends TestCase
{
    use RefreshDatabase;

    protected ChurchModuleService $moduleService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->moduleService = app(ChurchModuleService::class);
    }

    public function test_backfill_command_provisions_modules_for_legacy_unprovisioned_church(): void
    {
        // 1. Simulate a legacy church created BEFORE Phase 4B exists (raw DB insert, bypassing booted hook)
        $legacyChurchId = DB::table('churches')->insertGetId([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Legacy Pre-4B Church',
            'slug' => 'hkbp-legacy-pre-4b',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'created_at' => now()->subMonths(6),
            'updated_at' => now()->subMonths(6),
        ]);

        // 2. EMPIRICAL PROOF OF BEFORE STATE:
        // Exactly 0 rows in church_modules for this legacy church
        $beforeCount = ChurchModule::where('church_id', $legacyChurchId)->count();
        $this->assertSame(0, $beforeCount, 'Legacy church should initially have zero church_modules rows.');

        // Verify fail-closed behavior: isModuleEnabled returns false for unprovisioned church
        $this->assertFalse(
            $this->moduleService->isModuleEnabled('announcements', $legacyChurchId),
            'Fail-closed check: Unprovisioned church must evaluate to false before backfill.'
        );
        $this->assertFalse(
            $this->moduleService->isModuleEnabled('finance', $legacyChurchId),
            'Fail-closed check: Unprovisioned church must evaluate to false before backfill.'
        );

        // 3. Test DRY-RUN mode: verifies output reports missing modules without modifying database
        $this->artisan('churches:backfill-modules --dry-run')
            ->expectsOutputToContain('Missing 12 modules')
            ->expectsOutputToContain('Dry-run complete')
            ->assertSuccessful();

        // Database must remain completely untouched after dry-run
        $this->assertSame(0, ChurchModule::where('church_id', $legacyChurchId)->count());

        // 4. Run REAL backfill command
        $this->artisan('churches:backfill-modules')
            ->expectsOutputToContain('Backfill complete!')
            ->assertSuccessful();

        // 5. EMPIRICAL PROOF OF AFTER STATE:
        // All 12 modules must now be provisioned and enabled
        $afterCount = ChurchModule::where('church_id', $legacyChurchId)->count();
        $this->assertSame(12, $afterCount, 'Legacy church must have all 12 modules provisioned after backfill.');

        $enabledCount = ChurchModule::where('church_id', $legacyChurchId)->where('is_enabled', true)->count();
        $this->assertSame(12, $enabledCount, 'All 12 provisioned modules must be enabled by default.');

        // Clear service cache and verify isModuleEnabled now returns true!
        $this->moduleService->clearCache($legacyChurchId);
        $this->assertTrue($this->moduleService->isModuleEnabled('announcements', $legacyChurchId));
        $this->assertTrue($this->moduleService->isModuleEnabled('finance', $legacyChurchId));
        $this->assertTrue($this->moduleService->isModuleEnabled('membership', $legacyChurchId));
        $this->assertTrue($this->moduleService->isModuleEnabled('warta', $legacyChurchId));
    }

    public function test_backfill_command_is_completely_idempotent(): void
    {
        // 1. Create a legacy church
        $legacyChurchId = DB::table('churches')->insertGetId([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Idempotent Test Church',
            'slug' => 'hkbp-idempotent-test',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // First run: provisions 12 modules
        $this->artisan('churches:backfill-modules')->assertSuccessful();
        $this->assertSame(12, ChurchModule::where('church_id', $legacyChurchId)->count());

        // Disable one module to simulate customization
        $church = Church::find($legacyChurchId);
        $this->moduleService->disableModule($church, 'warta');
        $this->assertFalse($this->moduleService->isModuleEnabled('warta', $legacyChurchId));

        // Second run: must detect all modules exist and NOT re-enable customized disabled modules
        $this->artisan('churches:backfill-modules')
            ->expectsOutputToContain('Complete (12/12)')
            ->assertSuccessful();

        $this->assertSame(12, ChurchModule::where('church_id', $legacyChurchId)->count());
        $this->assertFalse($this->moduleService->isModuleEnabled('warta', $legacyChurchId), 'Idempotency must not reset user customizations.');
    }

    public function test_backfill_command_supports_specific_church_filter(): void
    {
        $churchAId = DB::table('churches')->insertGetId([
            'uuid' => (string) Str::uuid(),
            'name' => 'Church Alpha',
            'slug' => 'church-alpha',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $churchBId = DB::table('churches')->insertGetId([
            'uuid' => (string) Str::uuid(),
            'name' => 'Church Beta',
            'slug' => 'church-beta',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Run backfill targeting ONLY Church Alpha
        $this->artisan('churches:backfill-modules --church=church-alpha')
            ->assertSuccessful();

        // Church Alpha is provisioned
        $this->assertSame(12, ChurchModule::where('church_id', $churchAId)->count());

        // Church Beta remains unprovisioned (0 rows)
        $this->assertSame(0, ChurchModule::where('church_id', $churchBId)->count());
    }
}
