<?php

namespace Tests\Feature\Theme;

use App\Models\Church;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Tests\TestCase;

class ChurchThemeMigrationTest extends TestCase
{
    protected string $migrationPath = 'database/migrations/2026_09_14_000001_add_theme_columns_to_churches_table.php';

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate');
    }

    /**
     * Clean-up guard: Guarantee schema restoration and data cleanup so that subsequent test suites
     * in the same PHPUnit runner process are never exposed to an unmigrated schema or dirty rows.
     */
    protected function tearDown(): void
    {
        if (! Schema::hasColumn('churches', 'theme_primary_color')) {
            Artisan::call('migrate', ['--path' => $this->migrationPath]);
        }

        DB::table('churches')->delete();

        parent::tearDown();
    }

    /**
     * Test that executing the Phase 9 migration on an existing database with non-empty legacy
     * church records seamlessly assigns database-level defaults without NULLs, errors, or data loss.
     */
    public function test_legacy_churches_receive_default_theme_colors_when_migration_runs_on_non_empty_database(): void
    {
        try {
            // Step 1: Rollback the Phase 9 migration to simulate pre-Phase 9 schema
            Artisan::call('migrate:rollback', [
                '--path' => $this->migrationPath,
            ]);

            // Verify pre-migration state: theme columns do not exist
            $this->assertFalse(Schema::hasColumn('churches', 'theme_primary_color'));
            $this->assertFalse(Schema::hasColumn('churches', 'theme_secondary_color'));
            $this->assertFalse(Schema::hasColumn('churches', 'theme_version'));

            // Step 2: Insert a pre-existing legacy church directly into the table (bypassing model events)
            $legacyChurchId = DB::table('churches')->insertGetId([
                'uuid' => (string) Str::uuid(),
                'name' => 'HKBP Balige Kota (Legacy)',
                'slug' => 'hkbp-balige-kota-legacy',
                'status' => 'active',
                'timezone' => 'Asia/Jakarta',
                'address' => 'Jl. Gereja No. 1, Balige',
                'phone' => '08123456789',
                'logo_path' => 'logos/hkbp-balige.png',
                'created_at' => now()->subMonths(6),
                'updated_at' => now()->subMonths(6),
            ]);

            $this->assertGreaterThan(0, $legacyChurchId);

            // Step 3: Run the migration on top of non-empty data
            $exitCode = Artisan::call('migrate', [
                '--path' => $this->migrationPath,
            ]);

            $this->assertSame(0, $exitCode);

            // Step 4: Verify post-migration state: theme columns now exist
            $this->assertTrue(Schema::hasColumn('churches', 'theme_primary_color'));
            $this->assertTrue(Schema::hasColumn('churches', 'theme_secondary_color'));
            $this->assertTrue(Schema::hasColumn('churches', 'theme_version'));

            // Step 5: Verify the legacy church row faithfully inherited database defaults (NOT null, NOT error)
            $legacyRecord = DB::table('churches')->where('id', $legacyChurchId)->first();

            $this->assertNotNull($legacyRecord);
            $this->assertSame('#1B4B66', $legacyRecord->theme_primary_color);
            $this->assertSame('#F5A623', $legacyRecord->theme_secondary_color);
            $this->assertSame(1, (int) $legacyRecord->theme_version);
            $this->assertSame('hkbp-balige-kota-legacy', $legacyRecord->slug);
            $this->assertSame('logos/hkbp-balige.png', $legacyRecord->logo_path);
        } finally {
            if (! Schema::hasColumn('churches', 'theme_primary_color')) {
                Artisan::call('migrate', ['--path' => $this->migrationPath]);
            }
        }
    }

    /**
     * Test that model updating event increments theme_version ONLY when theme attributes change.
     */
    public function test_theme_version_increments_only_when_theme_attributes_are_dirty(): void
    {
        $church = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Tarutung',
            'slug' => 'hkbp-tarutung',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        $this->assertSame(1, $church->theme_version);
        $this->assertSame('#1B4B66', $church->theme_primary_color);
        $this->assertSame('#F5A623', $church->theme_secondary_color);

        // Updating an unrelated attribute (e.g. name or address) MUST NOT increment theme_version
        $church->update(['name' => 'HKBP Tarutung Pusat']);
        $church->refresh();
        $this->assertSame(1, $church->theme_version);

        // Updating theme_primary_color MUST increment theme_version to 2
        $church->update(['theme_primary_color' => '#0F2C3F']);
        $church->refresh();
        $this->assertSame(2, $church->theme_version);
        $this->assertSame('#0F2C3F', $church->theme_primary_color);

        // Updating theme_secondary_color MUST increment theme_version to 3
        $church->update(['theme_secondary_color' => '#E58A1F']);
        $church->refresh();
        $this->assertSame(3, $church->theme_version);

        // Updating logo_path MUST increment theme_version to 4
        $church->update(['logo_path' => 'logos/tarutung-new.png']);
        $church->refresh();
        $this->assertSame(4, $church->theme_version);
    }
}
