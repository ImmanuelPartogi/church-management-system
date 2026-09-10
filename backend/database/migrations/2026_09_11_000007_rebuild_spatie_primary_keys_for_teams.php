<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Phase 2 Task 6:
     * 1. Pre-flight assertion: verify zero NULL church_id in roles, model_has_roles, model_has_permissions.
     * 2. Enforce NOT NULL at column level: church_id -> nullable(false).
     * 3. Rebuild Primary Keys / Unique constraints:
     *    - model_has_roles: PK (church_id, role_id, model_id, model_type) + index(church_id)
     *    - model_has_permissions: PK (church_id, permission_id, model_id, model_type) + index(church_id)
     *    - roles: unique (church_id, name, guard_name) + index(church_id)
     */
    public function up(): void
    {
        // NOTE: Rollback penuh 000006+000007 lalu re-migrate akan gagal di pre-flight guard ini
        // kecuali church_id di-backfill ulang (jalankan 'php artisan spatie:backfill-church-id' lagi).
        // Ini disengaja (fail loudly) untuk mencegah composite PK terbentuk dengan nilai NULL di SQLite.
        // Safety guard: pre-flight check inside migration
        $spatieTables = ['roles', 'model_has_roles', 'model_has_permissions'];
        foreach ($spatieTables as $table) {
            $nullCount = DB::table($table)->whereNull('church_id')->count();
            if ($nullCount > 0) {
                throw new RuntimeException(
                    "Pre-flight check failed: table '{$table}' has {$nullCount} rows with church_id = NULL. ".
                    'All rows must be backfilled before rebuilding primary keys and enforcing NOT NULL.'
                );
            }
        }

        // 1. model_has_permissions
        Schema::table('model_has_permissions', function (Blueprint $table) {
            $table->unsignedBigInteger('church_id')->nullable(false)->change();
            $table->dropPrimary();
            $table->primary(
                ['church_id', 'permission_id', 'model_id', 'model_type'],
                'model_has_permissions_permission_model_type_primary'
            );
            $table->index('church_id', 'model_has_permissions_church_id_index');
        });

        // 2. model_has_roles
        Schema::table('model_has_roles', function (Blueprint $table) {
            $table->unsignedBigInteger('church_id')->nullable(false)->change();
            $table->dropPrimary();
            $table->primary(
                ['church_id', 'role_id', 'model_id', 'model_type'],
                'model_has_roles_role_model_type_primary'
            );
            $table->index('church_id', 'model_has_roles_church_id_index');
        });

        // 3. roles
        Schema::table('roles', function (Blueprint $table) {
            $table->unsignedBigInteger('church_id')->nullable(false)->change();
            $table->dropUnique(['name', 'guard_name']);
            $table->unique(['church_id', 'name', 'guard_name']);
            $table->index('church_id', 'roles_church_id_index');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // 1. roles
        Schema::table('roles', function (Blueprint $table) {
            $table->dropIndex('roles_church_id_index');
            $table->dropUnique(['church_id', 'name', 'guard_name']);
            $table->unique(['name', 'guard_name']);
            $table->unsignedBigInteger('church_id')->nullable()->change();
        });

        // 2. model_has_roles
        Schema::table('model_has_roles', function (Blueprint $table) {
            $table->dropIndex('model_has_roles_church_id_index');
            $table->dropPrimary();
            $table->primary(
                ['role_id', 'model_id', 'model_type'],
                'model_has_roles_role_model_type_primary'
            );
            $table->unsignedBigInteger('church_id')->nullable()->change();
        });

        // 3. model_has_permissions
        Schema::table('model_has_permissions', function (Blueprint $table) {
            $table->dropIndex('model_has_permissions_church_id_index');
            $table->dropPrimary();
            $table->primary(
                ['permission_id', 'model_id', 'model_type'],
                'model_has_permissions_permission_model_type_primary'
            );
            $table->unsignedBigInteger('church_id')->nullable()->change();
        });
    }
};
