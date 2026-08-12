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
        Schema::create('financial_transactions', function (Blueprint $table) {
            $table->id();
            $table->string('transaction_number')->unique();
            $table->date('transaction_date')->index();
            $table->foreignId('chart_of_account_id')->index()->constrained('chart_of_accounts')->restrictOnDelete();
            $table->string('type')->index(); // 'income' or 'expense'
            $table->decimal('amount', 15, 2);
            $table->text('description')->nullable();
            $table->string('reference')->nullable();
            $table->foreignId('donation_confirmation_id')->nullable()->index()->constrained('donation_confirmations')->nullOnDelete();
            $table->foreignId('created_by')->nullable()->index()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('financial_transactions');
    }
};
