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
        Schema::create('synod_report_snapshots', function (Blueprint $table) {
            $table->id();
            $table->foreignId('generated_by_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->date('period_date')->index();

            // Church counts
            $table->unsignedInteger('total_churches')->default(0);
            $table->unsignedInteger('active_churches')->default(0);
            $table->unsignedInteger('suspended_churches')->default(0);

            // Member counts (Active churches vs All churches)
            $table->unsignedInteger('total_active_members')->default(0);
            $table->unsignedInteger('total_all_members')->default(0);

            // Verified donations (Active churches vs All churches)
            $table->decimal('total_active_donations', 15, 2)->default(0.00);
            $table->decimal('total_all_donations', 15, 2)->default(0.00);

            // Sacrament applications (Active churches vs All churches)
            $table->unsignedInteger('total_active_sacraments')->default(0);
            $table->unsignedInteger('total_all_sacraments')->default(0);

            // JSON breakdowns
            $table->json('church_comparisons')->nullable();
            $table->json('module_adoption')->nullable();

            $table->timestamps();
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('synod_report_snapshots');
    }
};
