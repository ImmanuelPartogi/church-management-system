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
        Schema::create('prayer_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->index()->constrained('users')->nullOnDelete();
            $table->foreignId('member_id')->nullable()->index()->constrained('church_members')->nullOnDelete();
            $table->string('title')->nullable();
            $table->text('content');
            $table->string('category')->nullable()->index();
            $table->boolean('is_private')->default(true)->index();
            $table->string('status')->default('submitted')->index();
            $table->text('follow_up_notes')->nullable();
            $table->foreignId('followed_up_by')->nullable()->index()->constrained('users')->nullOnDelete();
            $table->timestamp('followed_up_at')->nullable();
            $table->timestamps();

            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('prayer_requests');
    }
};
