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
        Schema::table('users', function (Blueprint $table) {
            // Additive column for Super Admin identification.
            // As mandated in Phase 1B: Super Admin does NOT use church_id = NULL in role tables
            // because in Spatie Permission 8.3 team_foreign_key is part of composite primary key.
            // Indexed for high-frequency permission and authorization checks.
            $table->boolean('is_super_admin')->default(false)->index()->after('address');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['is_super_admin']);
            $table->dropColumn('is_super_admin');
        });
    }
};
