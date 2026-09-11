<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('service_form_types', function (Blueprint $table) {
            $table->boolean('is_sacrament')->default(false)->after('active')->index();
        });

        // Backfill sacrament form types based on standard liturgical sacrament slugs
        DB::table('service_form_types')
            ->whereIn('slug', ['baptis', 'sidi', 'nikah'])
            ->update(['is_sacrament' => true]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('service_form_types', function (Blueprint $table) {
            $table->dropIndex(['is_sacrament']);
            $table->dropColumn('is_sacrament');
        });
    }
};
