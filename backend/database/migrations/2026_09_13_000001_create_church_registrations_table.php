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
        Schema::create('church_registrations', function (Blueprint $table) {
            $table->id();
            $table->string('church_name');
            $table->string('slug')->unique();
            $table->string('city')->nullable();
            $table->text('address')->nullable();
            $table->string('phone')->nullable();
            $table->string('timezone')->default('Asia/Jakarta');

            // Applicant details
            $table->string('applicant_name');
            $table->string('applicant_email')->index();
            $table->string('applicant_phone')->nullable();
            $table->string('applicant_password_hash');

            // Early existing user link (detected at submit-time)
            $table->foreignId('existing_user_id')->nullable()->constrained('users')->nullOnDelete();

            // Status & Verification (Authoritative Signed Route, no redundant token column)
            $table->string('status')->default('pending_email_verification')->index();
            $table->timestamp('verified_at')->nullable();

            // Approval / Rejection resolution
            $table->foreignId('church_id')->nullable()->constrained('churches')->nullOnDelete();
            $table->foreignId('approved_by_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('approved_at')->nullable();
            $table->text('rejection_reason')->nullable();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('church_registrations');
    }
};
