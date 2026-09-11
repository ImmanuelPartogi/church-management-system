<?php

namespace Tests\Feature\PushNotification;

use App\Models\Church;
use App\Models\ChurchUserMembership;
use App\Models\User;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Tests\TestCase;

class DeviceTokenMigrationTest extends TestCase
{
    protected string $migrationPath = 'database/migrations/2026_09_15_000001_add_church_id_to_device_tokens_table.php';

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate');
    }

    /**
     * Clean-up guard: guarantee that if migration was executed during test,
     * it rolls back or cleans up so no side-effects leak into the test database.
     */
    protected function tearDown(): void
    {
        DB::table('device_tokens')->delete();
        DB::table('church_user_memberships')->delete();
        DB::table('churches')->delete();
        DB::table('users')->delete();

        if (Schema::hasColumn('device_tokens', 'church_id')) {
            Artisan::call('migrate:rollback', ['--path' => $this->migrationPath]);
        }

        parent::tearDown();
    }

    /**
     * Comprehensive test verifying:
     * 1. Pre-migration PRAGMA foreign keys and index baseline
     * 2. Legacy data reconciliation for single and multi-membership users
     * 3. Post-migration PRAGMA foreign keys and indexes preservation
     * 4. Clean migrate -> rollback -> migrate cycle without index or constraint loss
     */
    public function test_device_tokens_migration_reconciliation_and_pragma_integrity(): void
    {
        // Rollback Phase 10 migration first to set up pre-migration baseline
        Artisan::call('migrate:rollback', [
            '--path' => $this->migrationPath,
        ]);
        // -------------------------------------------------------------
        // Step 1: Verify Pre-Migration Baseline (PRAGMA inspection)
        // -------------------------------------------------------------
        $this->assertFalse(Schema::hasColumn('device_tokens', 'church_id'));
        $this->assertFalse(Schema::hasColumn('device_tokens', 'is_active'));

        $preFks = collect(DB::select('PRAGMA foreign_key_list("device_tokens")'));
        $preIndexes = collect(DB::select('PRAGMA index_list("device_tokens")'));

        // Pre-migration must have foreign key to users
        $userFk = $preFks->firstWhere('table', 'users');
        $this->assertNotNull($userFk, 'Pre-migration must have foreign key to users');
        $this->assertSame('user_id', $userFk->from);
        $this->assertSame('id', $userFk->to);
        $this->assertSame('CASCADE', strtoupper($userFk->on_delete));

        // Pre-migration must have unique index on token
        $this->assertTrue($preIndexes->contains('name', 'device_tokens_token_unique'));
        $this->assertTrue($preIndexes->contains('name', 'device_tokens_user_id_platform_index'));

        // -------------------------------------------------------------
        // Step 2: Seed Churches, Multi-Membership User, and Legacy Token
        // -------------------------------------------------------------
        $churchA = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Tarutung Kota',
            'slug' => 'hkbp-tarutung-kota',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        $churchB = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Ressort Sipoholon',
            'slug' => 'hkbp-ressort-sipoholon',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        // Pastor user with active memberships in BOTH church A and church B
        $pastor = User::create([
            'name' => 'Pendeta Lintas Ressort',
            'email' => 'pastor.lintas@hkbp.org',
            'password' => bcrypt('secret123'),
        ]);

        ChurchUserMembership::create([
            'church_id' => $churchA->id,
            'user_id' => $pastor->id,
            'role' => 'pastor',
            'status' => 'active',
        ]);

        ChurchUserMembership::create([
            'church_id' => $churchB->id,
            'user_id' => $pastor->id,
            'role' => 'pastor',
            'status' => 'active',
        ]);

        // Insert legacy device token without church_id (simulating legacy data)
        $legacyTokenString = 'fcm_legacy_device_token_xyz123';
        $legacyTokenId = DB::table('device_tokens')->insertGetId([
            'user_id' => $pastor->id,
            'token' => $legacyTokenString,
            'platform' => 'android',
            'device_name' => 'Samsung Galaxy S24 (Legacy)',
            'created_at' => now()->subMonths(3),
            'updated_at' => now()->subMonths(3),
        ]);

        $this->assertGreaterThan(0, $legacyTokenId);

        // -------------------------------------------------------------
        // Step 3: Run Phase 10 Migration
        // -------------------------------------------------------------
        $exitCode = Artisan::call('migrate', [
            '--path' => $this->migrationPath,
        ]);
        $this->assertSame(0, $exitCode);

        // -------------------------------------------------------------
        // Step 4: Verify Post-Migration Schema & PRAGMA Integrity
        // -------------------------------------------------------------
        $this->assertTrue(Schema::hasColumn('device_tokens', 'church_id'));
        $this->assertTrue(Schema::hasColumn('device_tokens', 'is_active'));

        $postFks = collect(DB::select('PRAGMA foreign_key_list("device_tokens")'));
        $postIndexes = collect(DB::select('PRAGMA index_list("device_tokens")'));

        // Both foreign keys must exist and have CASCADE on delete
        $postUserFk = $postFks->firstWhere('table', 'users');
        $this->assertNotNull($postUserFk, 'Post-migration foreign key to users must be preserved');
        $this->assertSame('user_id', $postUserFk->from);
        $this->assertSame('CASCADE', strtoupper($postUserFk->on_delete));

        $postChurchFk = $postFks->firstWhere('table', 'churches');
        $this->assertNotNull($postChurchFk, 'Post-migration foreign key to churches must exist');
        $this->assertSame('church_id', $postChurchFk->from);
        $this->assertSame('CASCADE', strtoupper($postChurchFk->on_delete));

        // Indexes verification:
        // - old device_tokens_token_unique dropped
        // - composite unique on (token, church_id) created
        // - composite performance index on (church_id, is_active) created
        // - index on (user_id, platform) preserved
        $this->assertFalse($postIndexes->contains('name', 'device_tokens_token_unique'));
        $this->assertTrue($postIndexes->contains('name', 'device_tokens_token_church_unique'));
        $this->assertTrue($postIndexes->contains('name', 'device_tokens_church_id_is_active_index'));
        $this->assertTrue($postIndexes->contains('name', 'device_tokens_user_id_platform_index'));

        // -------------------------------------------------------------
        // Step 5: Verify Legacy Data Reconciliation
        // -------------------------------------------------------------
        // The legacy row must have been reconciled to Church A
        $reconciledLegacyRow = DB::table('device_tokens')->where('id', $legacyTokenId)->first();
        $this->assertNotNull($reconciledLegacyRow);
        $this->assertSame($churchA->id, (int) $reconciledLegacyRow->church_id);
        $this->assertTrue((bool) $reconciledLegacyRow->is_active);

        // A second row must have been automatically spawned for Church B (pastor's second active membership)
        $spawnedRow = DB::table('device_tokens')
            ->where('user_id', $pastor->id)
            ->where('church_id', $churchB->id)
            ->where('token', $legacyTokenString)
            ->first();

        $this->assertNotNull($spawnedRow, 'Reconciliation must spawn row for second active church membership');
        $this->assertTrue((bool) $spawnedRow->is_active);
        $this->assertSame('Samsung Galaxy S24 (Legacy)', $spawnedRow->device_name);

        // Total rows for this device token should now be 2 (one for each church membership)
        $totalRowsForToken = DB::table('device_tokens')->where('token', $legacyTokenString)->count();
        $this->assertSame(2, $totalRowsForToken);

        // -------------------------------------------------------------
        // Step 6: Test Rollback and Schema Restoration
        // -------------------------------------------------------------
        // down() automatically deduplicates multi-church tokens and deletes guest tokens before restoring single unique & NOT NULL
        $rollbackExitCode = Artisan::call('migrate:rollback', [
            '--path' => $this->migrationPath,
        ]);
        $this->assertSame(0, $rollbackExitCode);

        $this->assertFalse(Schema::hasColumn('device_tokens', 'church_id'));
        $this->assertFalse(Schema::hasColumn('device_tokens', 'is_active'));

        $rollbackFks = collect(DB::select('PRAGMA foreign_key_list("device_tokens")'));
        $rollbackIndexes = collect(DB::select('PRAGMA index_list("device_tokens")'));

        // Foreign key to users must still be intact after rollback
        $rollbackUserFk = $rollbackFks->firstWhere('table', 'users');
        $this->assertNotNull($rollbackUserFk);
        $this->assertSame('user_id', $rollbackUserFk->from);

        // Unique index on token must be restored
        $this->assertTrue($rollbackIndexes->contains('name', 'device_tokens_token_unique'));
        $this->assertFalse($rollbackIndexes->contains('name', 'device_tokens_token_church_unique'));

        // -------------------------------------------------------------
        // Step 7: Re-migrate to Prove Clean Re-execution
        // -------------------------------------------------------------
        $reMigrateExitCode = Artisan::call('migrate', [
            '--path' => $this->migrationPath,
        ]);
        $this->assertSame(0, $reMigrateExitCode);

        $this->assertTrue(Schema::hasColumn('device_tokens', 'church_id'));
        $this->assertTrue(Schema::hasColumn('device_tokens', 'is_active'));
    }
}
