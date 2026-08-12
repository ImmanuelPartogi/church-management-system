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
        Schema::create('church_servants', function (Blueprint $table) {
            $table->id();
            $table->foreignId('member_id')->nullable()->index()->constrained('church_members')->nullOnDelete();
            $table->string('name');
            $table->string('role')->index();
            $table->string('phone')->nullable();
            $table->string('email')->nullable();
            $table->foreignId('resort_id')->nullable()->index()->constrained('resorts')->nullOnDelete();
            $table->foreignId('sector_id')->nullable()->index()->constrained('sectors')->nullOnDelete();
            $table->foreignId('fellowship_id')->nullable()->index()->constrained('fellowships')->nullOnDelete();
            $table->text('description')->nullable();
            $table->boolean('active')->default(true)->index();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('church_servants');
    }
};
