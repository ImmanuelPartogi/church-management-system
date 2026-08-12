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
        Schema::create('service_form_applications', function (Blueprint $table) {
            $table->id();
            $table->string('application_number')->unique();
            $table->foreignId('user_id')->nullable()->index()->constrained('users')->nullOnDelete();
            $table->foreignId('member_id')->nullable()->index()->constrained('church_members')->nullOnDelete();
            $table->foreignId('service_form_type_id')->index()->constrained('service_form_types')->cascadeOnDelete();
            $table->string('status')->default('pending')->index();
            $table->text('applicant_notes')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->string('payment_status')->default('unpaid')->index();
            $table->text('payment_notes')->nullable();
            $table->foreignId('reviewed_by')->nullable()->index()->constrained('users')->nullOnDelete();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamps();

            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('service_form_applications');
    }
};
