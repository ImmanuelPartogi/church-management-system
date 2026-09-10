<?php

namespace Tests\Feature\Tenant;

use App\Models\Church;
use App\Models\User;
use Filament\Facades\Filament;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Kreait\Firebase\Contract\Auth as FirebaseAuth;
use Lcobucci\JWT\Token\DataSet;
use Lcobucci\JWT\UnencryptedToken;
use Mockery;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;
use Tests\TestCase;

class SpatieTeamsIntegrationTest extends TestCase
{
    use RefreshDatabase;

    private Church $churchA;

    private Church $churchB;

    protected function setUp(): void
    {
        parent::setUp();

        // Ensure Church A (default) exists
        $this->churchA = Church::firstOrCreate(
            ['slug' => (string) config('tenant.default_church_slug', 'default')],
            [
                'uuid' => (string) Str::uuid(),
                'name' => 'Church Alpha',
                'status' => 'active',
                'timezone' => 'Asia/Jakarta',
            ]
        );

        // Create secondary Church B for cross-tenant isolation testing
        $this->churchB = Church::firstOrCreate(
            ['slug' => 'church-beta'],
            [
                'uuid' => (string) Str::uuid(),
                'name' => 'Church Beta',
                'status' => 'active',
                'timezone' => 'Asia/Jakarta',
            ]
        );

        // Reset Spatie cache and set team context to churchA
        app(PermissionRegistrar::class)->forgetCachedPermissions();
        app(PermissionRegistrar::class)->setPermissionsTeamId($this->churchA->id);
    }

    /**
     * Test 1: Role assignment with team context.
     * assignRole('member') succeeds when setPermissionsTeamId() is set,
     * and model_has_roles records church_id matching active team context.
     */
    public function test_01_role_assignment_with_team_context(): void
    {
        app(PermissionRegistrar::class)->setPermissionsTeamId($this->churchA->id);

        $role = Role::firstOrCreate([
            'name' => 'member',
            'guard_name' => 'web',
            'church_id' => $this->churchA->id,
        ]);

        $user = User::factory()->create();
        $user->assignRole('member');

        $this->assertTrue($user->hasRole('member'));

        $mhr = DB::table('model_has_roles')
            ->where('model_id', $user->id)
            ->where('role_id', $role->id)
            ->first();

        $this->assertNotNull($mhr);
        $this->assertSame($this->churchA->id, (int) $mhr->church_id);
    }

    /**
     * Test 2: hasPermissionTo() returns true when team context matches.
     */
    public function test_02_has_permission_to_returns_true_when_team_context_matches(): void
    {
        app(PermissionRegistrar::class)->setPermissionsTeamId($this->churchA->id);

        $permission = Permission::firstOrCreate(['name' => 'view members', 'guard_name' => 'web']);
        $role = Role::firstOrCreate([
            'name' => 'pastor',
            'guard_name' => 'web',
            'church_id' => $this->churchA->id,
        ]);
        $role->givePermissionTo($permission);

        $user = User::factory()->create();
        $user->assignRole('pastor');

        $this->assertTrue($user->hasPermissionTo('view members'));
    }

    /**
     * Test 3: Cross-church isolation — hasPermissionTo() and hasRole()
     * return false when evaluated under a different church context.
     */
    public function test_03_cross_church_isolation_returns_false_in_different_context(): void
    {
        // Setup permissions and user in Church A
        app(PermissionRegistrar::class)->setPermissionsTeamId($this->churchA->id);

        $permission = Permission::firstOrCreate(['name' => 'manage finances', 'guard_name' => 'web']);
        $role = Role::firstOrCreate([
            'name' => 'church_admin',
            'guard_name' => 'web',
            'church_id' => $this->churchA->id,
        ]);
        $role->givePermissionTo($permission);

        $user = User::factory()->create();
        $user->assignRole('church_admin');

        $this->assertTrue($user->hasRole('church_admin'));
        $this->assertTrue($user->hasPermissionTo('manage finances'));

        // Switch to Church B context
        app(PermissionRegistrar::class)->setPermissionsTeamId($this->churchB->id);
        $user->unsetRelations();

        // User must NOT have church_admin or manage finances in Church B
        $this->assertFalse($user->hasRole('church_admin'));
        $this->assertFalse($user->hasPermissionTo('manage finances'));
    }

    /**
     * Test 4: hasAnyRole() works with team context for canAccessPanel().
     */
    public function test_04_has_any_role_works_with_team_context_for_can_access_panel(): void
    {
        $panel = Filament::getPanel('admin');

        // 4A: User with church_admin in Church A context can access panel
        app(PermissionRegistrar::class)->setPermissionsTeamId($this->churchA->id);
        $roleAdmin = Role::firstOrCreate([
            'name' => 'church_admin',
            'guard_name' => 'web',
            'church_id' => $this->churchA->id,
        ]);
        $admin = User::factory()->create();
        $admin->assignRole('church_admin');
        $this->assertTrue($admin->canAccessPanel($panel));

        // 4B: User with only 'member' role cannot access panel
        $roleMember = Role::firstOrCreate([
            'name' => 'member',
            'guard_name' => 'web',
            'church_id' => $this->churchA->id,
        ]);
        $member = User::factory()->create();
        $member->assignRole('member');
        $this->assertFalse($member->canAccessPanel($panel));

        // 4C: Church A admin evaluated under Church B context cannot access panel
        app(PermissionRegistrar::class)->setPermissionsTeamId($this->churchB->id);
        $admin->unsetRelations();
        $this->assertFalse($admin->canAccessPanel($panel));
    }

    /**
     * Test 5: getRoleNames() returns roles scoped to the active team context.
     */
    public function test_05_get_role_names_scoped_to_current_team_context(): void
    {
        $user = User::factory()->create();

        // Assign 'church_admin' in Church A
        app(PermissionRegistrar::class)->setPermissionsTeamId($this->churchA->id);
        Role::firstOrCreate([
            'name' => 'church_admin',
            'guard_name' => 'web',
            'church_id' => $this->churchA->id,
        ]);
        $user->assignRole('church_admin');

        // Assign 'member' in Church B
        app(PermissionRegistrar::class)->setPermissionsTeamId($this->churchB->id);
        $user->unsetRelations();
        Role::firstOrCreate([
            'name' => 'member',
            'guard_name' => 'web',
            'church_id' => $this->churchB->id,
        ]);
        $user->assignRole('member');

        // Context Church A
        app(PermissionRegistrar::class)->setPermissionsTeamId($this->churchA->id);
        $user->unsetRelations();
        $rolesA = $user->getRoleNames();
        $this->assertTrue($rolesA->contains('church_admin'));
        $this->assertFalse($rolesA->contains('member'));

        // Context Church B
        app(PermissionRegistrar::class)->setPermissionsTeamId($this->churchB->id);
        $user->unsetRelations();
        $rolesB = $user->getRoleNames();
        $this->assertTrue($rolesB->contains('member'));
        $this->assertFalse($rolesB->contains('church_admin'));
    }

    /**
     * Test 6: Super admin bypasses policy regardless of team context.
     */
    public function test_06_super_admin_bypasses_policy_regardless_of_team_context(): void
    {
        $panel = Filament::getPanel('admin');
        $superAdmin = User::factory()->create(['is_super_admin' => true]);

        // In Church A where super admin has NO roles assigned
        app(PermissionRegistrar::class)->setPermissionsTeamId($this->churchA->id);
        $this->assertTrue(Gate::forUser($superAdmin)->allows('manage announcements'));
        $this->assertTrue($superAdmin->can('view members'));
        $this->assertTrue($superAdmin->canAccessPanel($panel));

        // In Church B context
        app(PermissionRegistrar::class)->setPermissionsTeamId($this->churchB->id);
        $this->assertTrue(Gate::forUser($superAdmin)->allows('manage finances'));
        $this->assertTrue($superAdmin->can('manage members'));
        $this->assertTrue($superAdmin->canAccessPanel($panel));
    }

    /**
     * Test 7: Migration reversibility (rollback + re-migrate cycle for migrations 6 & 7).
     *
     * Validates the complete operational re-deploy procedure:
     * 1. Rollback 000007 (PK rebuild).
     * 2. Rollback 000006 (church_id column dropped).
     * 3. Re-migrate 000006 only (church_id restored as nullable, with NULL values).
     * 4. Pre-flight guard assertion: migrating 000007 directly fails loudly with RuntimeException.
     * 5. Run operational backfill command: `php artisan spatie:backfill-church-id`.
     * 6. Re-migrate 000007 succeeds, restoring NOT NULL and composite primary keys.
     */
    public function test_07_spatie_teams_migrations_reversibility(): void
    {
        // Initial state: church_id column exists
        $this->assertTrue(Schema::hasColumn('roles', 'church_id'));
        $this->assertTrue(Schema::hasColumn('model_has_roles', 'church_id'));

        // 1. Rollback migration 000007 (PK rebuild)
        $code = Artisan::call('migrate:rollback', [
            '--path' => 'database/migrations/2026_09_11_000007_rebuild_spatie_primary_keys_for_teams.php',
        ]);
        $this->assertSame(0, $code);
        $this->assertTrue(Schema::hasColumn('roles', 'church_id'));

        // 2. Rollback migration 000006 (additive column)
        $code = Artisan::call('migrate:rollback', [
            '--path' => 'database/migrations/2026_09_11_000006_add_church_id_to_spatie_permission_tables.php',
        ]);
        $this->assertSame(0, $code);
        $this->assertFalse(Schema::hasColumn('roles', 'church_id'));
        $this->assertFalse(Schema::hasColumn('model_has_roles', 'church_id'));

        // 3. Re-migrate migration 000006 only
        $code = Artisan::call('migrate', [
            '--path' => 'database/migrations/2026_09_11_000006_add_church_id_to_spatie_permission_tables.php',
        ]);
        $this->assertSame(0, $code);
        $this->assertTrue(Schema::hasColumn('roles', 'church_id'));

        // 4. Pre-flight guard assertion:
        // If existing roles have church_id = NULL, attempting to run migration 000007 directly
        // must throw a loud RuntimeException rather than silently creating composite PKs with NULLs.
        $nullCount = DB::table('roles')->whereNull('church_id')->count();
        if ($nullCount > 0) {
            try {
                Artisan::call('migrate', [
                    '--path' => 'database/migrations/2026_09_11_000007_rebuild_spatie_primary_keys_for_teams.php',
                ]);
                $this->fail('Expected pre-flight RuntimeException was not thrown on migration 000007');
            } catch (\RuntimeException $e) {
                $this->assertStringContainsString('Pre-flight check failed', $e->getMessage());
            }
        }

        // 5. Run the actual operational backfill command (spatie:backfill-church-id)
        $code = Artisan::call('spatie:backfill-church-id');
        $this->assertSame(0, $code);

        // Verify zero NULLs remain after running the backfill command
        $this->assertSame(0, DB::table('roles')->whereNull('church_id')->count());
        $this->assertSame(0, DB::table('model_has_roles')->whereNull('church_id')->count());

        // 6. Now migration 000007 succeeds cleanly
        $code = Artisan::call('migrate', [
            '--path' => 'database/migrations/2026_09_11_000007_rebuild_spatie_primary_keys_for_teams.php',
        ]);
        $this->assertSame(0, $code);

        // Final state: verified and intact
        $this->assertTrue(Schema::hasColumn('roles', 'church_id'));
        $this->assertTrue(Schema::hasColumn('model_has_roles', 'church_id'));
    }

    /**
     * Test 8: Firebase registration flow — user created, assigned 'member' role,
     * and model_has_roles receives active default church context.
     */
    public function test_08_firebase_registration_assigns_role_with_active_church_bridge(): void
    {
        // Ensure default church context is set
        app(PermissionRegistrar::class)->setPermissionsTeamId($this->churchA->id);

        // Ensure 'member' role exists for churchA
        Role::firstOrCreate([
            'name' => 'member',
            'guard_name' => 'web',
            'church_id' => $this->churchA->id,
        ]);

        // Mock Firebase Auth
        $claims = new DataSet([
            'sub' => 'mock-firebase-uid-integration',
            'email' => 'integration@church.org',
            'name' => 'Integration User',
        ], 'encoded_claims_payload');

        $tokenMock = Mockery::mock(UnencryptedToken::class);
        $tokenMock->shouldReceive('claims')->andReturn($claims);

        $firebaseAuthMock = Mockery::mock(FirebaseAuth::class);
        $firebaseAuthMock->shouldReceive('verifyIdToken')
            ->once()
            ->with('valid-integration-token')
            ->andReturn($tokenMock);

        $this->app->instance(FirebaseAuth::class, $firebaseAuthMock);

        // Post token exchange request
        $response = $this->postJson('/api/v1/auth/firebase', [
            'firebase_id_token' => 'valid-integration-token',
        ]);

        $response->assertStatus(200);

        $user = User::where('email', 'integration@church.org')->first();
        $this->assertNotNull($user);

        // Verify role assigned with proper church_id
        $mhr = DB::table('model_has_roles')->where('model_id', $user->id)->first();
        $this->assertNotNull($mhr);
        $this->assertSame($this->churchA->id, (int) $mhr->church_id);
    }

    /**
     * Test 9: PK-NULL-rejection — direct database inserts with church_id = NULL
     * are strictly rejected by SQLite NOT NULL constraint across all 3 Spatie tables.
     */
    public function test_09_database_strictly_rejects_null_church_id_on_all_spatie_tables(): void
    {
        $role = Role::firstOrCreate([
            'name' => 'test_pk_role',
            'guard_name' => 'web',
            'church_id' => $this->churchA->id,
        ]);
        $permission = Permission::firstOrCreate(['name' => 'test_pk_perm', 'guard_name' => 'web']);
        $user = User::factory()->create();

        // 9A: model_has_roles
        try {
            DB::table('model_has_roles')->insert([
                'role_id' => $role->id,
                'model_type' => User::class,
                'model_id' => $user->id,
                'church_id' => null,
            ]);
            $this->fail('Expected QueryException was not thrown on model_has_roles with church_id = NULL');
        } catch (QueryException $e) {
            $this->assertStringContainsString('NOT NULL constraint failed: model_has_roles.church_id', $e->getMessage());
        }

        // 9B: roles
        try {
            DB::table('roles')->insert([
                'name' => 'test_role_null_rejection',
                'guard_name' => 'web',
                'church_id' => null,
            ]);
            $this->fail('Expected QueryException was not thrown on roles with church_id = NULL');
        } catch (QueryException $e) {
            $this->assertStringContainsString('NOT NULL constraint failed: roles.church_id', $e->getMessage());
        }

        // 9C: model_has_permissions
        try {
            DB::table('model_has_permissions')->insert([
                'permission_id' => $permission->id,
                'model_type' => User::class,
                'model_id' => $user->id,
                'church_id' => null,
            ]);
            $this->fail('Expected QueryException was not thrown on model_has_permissions with church_id = NULL');
        } catch (QueryException $e) {
            $this->assertStringContainsString('NOT NULL constraint failed: model_has_permissions.church_id', $e->getMessage());
        }
    }
}
