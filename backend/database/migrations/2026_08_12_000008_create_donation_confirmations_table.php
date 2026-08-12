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
        Schema::create('donation_confirmations', function (Blueprint $table) {
            $table->id();
            $table->string('donation_number')->unique();
            $table->foreignId('user_id')->nullable()->index()->constrained('users')->nullOnDelete();
            $table->foreignId('member_id')->nullable()->index()->constrained('church_members')->nullOnDelete();
            $table->foreignId('chart_of_account_id')->index()->constrained('chart_of_accounts')->restrictOnDelete();
            $table->decimal('amount', 15, 2);
            $table->date('transfer_date');
            $table->string('sender_bank');
            $table->string('depositor_phone')->nullable();
            $table->string('proof_file_path')->nullable();
            $table->string('status')->default('pending')->index();
            $table->text('notes')->nullable();
            $table->text('rejection_reason')->nullable();
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
        Schema::dropIfExists('donation_confirmations');
    }
};
