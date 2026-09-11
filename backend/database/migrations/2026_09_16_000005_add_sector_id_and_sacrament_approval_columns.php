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
        Schema::table('church_members', function (Blueprint $table) {
            $table->foreignId('sector_id')->nullable()->after('address')->constrained('sectors')->nullOnDelete();
            $table->date('sidi_date')->nullable()->after('baptism_date');
        });

        Schema::table('service_form_applications', function (Blueprint $table) {
            $table->foreignId('sector_reviewed_by')->nullable()->after('reviewed_at')->constrained('users')->nullOnDelete();
            $table->timestamp('sector_reviewed_at')->nullable()->after('sector_reviewed_by');
            $table->foreignId('pastor_reviewed_by')->nullable()->after('sector_reviewed_at')->constrained('users')->nullOnDelete();
            $table->timestamp('pastor_reviewed_at')->nullable()->after('pastor_reviewed_by');
            $table->foreignId('scheduled_worship_id')->nullable()->after('pastor_reviewed_at')->constrained('worship_schedules')->nullOnDelete();
            $table->timestamp('sacrament_completed_at')->nullable()->after('scheduled_worship_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('service_form_applications', function (Blueprint $table) {
            $table->dropConstrainedForeignId('scheduled_worship_id');
            $table->dropConstrainedForeignId('pastor_reviewed_by');
            $table->dropConstrainedForeignId('sector_reviewed_by');
            $table->dropColumn([
                'sector_reviewed_at',
                'pastor_reviewed_at',
                'sacrament_completed_at',
            ]);
        });

        Schema::table('church_members', function (Blueprint $table) {
            $table->dropConstrainedForeignId('sector_id');
            $table->dropColumn('sidi_date');
        });
    }
};
