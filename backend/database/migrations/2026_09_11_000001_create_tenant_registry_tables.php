<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. churches
        // Tenant root entity. Uses UUID for secure public exposure and slug for church subdomain/path routing.
        // Status allows instant tenant suspension without deleting records.
        // Soft deletes ensure data can be recovered and foreign keys stay intact during deactivation.
        Schema::create('churches', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->string('name');
            $table->string('slug')->unique();
            $table->string('status')->default('active'); // active, suspended
            $table->string('timezone')->default('Asia/Jakarta');
            $table->text('address')->nullable();
            $table->string('phone')->nullable();
            $table->string('logo_path')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });

        // 2. modules
        // Global catalog of available platform modules (e.g., finance, donations, warta).
        // depends_on allows self-referencing hierarchy where a feature module depends on a base module.
        Schema::create('modules', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();
            $table->string('name');
            $table->text('description')->nullable();
            $table->boolean('is_core')->default(false);
            $table->foreignId('depends_on')->nullable()->constrained('modules')->nullOnDelete();
            $table->timestamps();
        });

        // 3. church_modules
        // Feature flag & tenant module configuration pivot.
        // Cascade delete on both church and module ensures clean cascade if a test tenant is pruned.
        Schema::create('church_modules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('church_id')->constrained('churches')->cascadeOnDelete();
            $table->foreignId('module_id')->constrained('modules')->cascadeOnDelete();
            $table->boolean('is_enabled')->default(false);
            $table->json('settings')->nullable();
            $table->timestamp('enabled_at')->nullable();
            $table->timestamp('disabled_at')->nullable();
            $table->timestamps();

            $table->unique(['church_id', 'module_id']);
        });

        // 4. church_user_memberships
        // Direct link associating global users with specific churches.
        // church_member_id links to congregation/jemaat profile if applicable (nullOnDelete to preserve membership).
        // Cascade on user & church deletion ensures integrity.
        // role is a temporary string column for Phase 1C, prior to Spatie Teams integration in Phase 2.
        Schema::create('church_user_memberships', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('church_id')->constrained('churches')->cascadeOnDelete();
            $table->foreignId('church_member_id')->nullable()->constrained('church_members')->nullOnDelete();
            $table->string('role')->default('member'); // temporary single-role string for Phase 1
            $table->string('status')->default('active'); // active, inactive, pending, removed
            $table->timestamp('joined_at')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'church_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('church_user_memberships');
        Schema::dropIfExists('church_modules');
        Schema::dropIfExists('modules');
        Schema::dropIfExists('churches');
    }
};
