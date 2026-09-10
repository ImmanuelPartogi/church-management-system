<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Phase 2 Task 3: Add church_id (nullable) to Spatie Permission tables.
     * This is ADDITIVE only — no FK constraints, no PK changes, no index changes.
     * Those are deferred to Task 6 (2026_09_11_000007).
     */
    public function up(): void
    {
        Schema::table('roles', function (Blueprint $table) {
            $table->unsignedBigInteger('church_id')->nullable()->after('id');
        });

        Schema::table('model_has_roles', function (Blueprint $table) {
            $table->unsignedBigInteger('church_id')->nullable();
        });

        Schema::table('model_has_permissions', function (Blueprint $table) {
            $table->unsignedBigInteger('church_id')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('roles', function (Blueprint $table) {
            $table->dropColumn('church_id');
        });

        Schema::table('model_has_roles', function (Blueprint $table) {
            $table->dropColumn('church_id');
        });

        Schema::table('model_has_permissions', function (Blueprint $table) {
            $table->dropColumn('church_id');
        });
    }
};
