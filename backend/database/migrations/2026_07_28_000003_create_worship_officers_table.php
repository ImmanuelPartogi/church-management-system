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
        Schema::create('worship_officers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('worship_schedule_id')->constrained('worship_schedules')->cascadeOnDelete();
            $table->foreignId('member_id')->constrained('church_members')->cascadeOnDelete();
            $table->string('role'); // e.g. Preacher, Liturgist, Musician, Singer
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('worship_officers');
    }
};
