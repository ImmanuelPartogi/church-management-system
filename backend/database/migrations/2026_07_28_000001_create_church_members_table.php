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
        Schema::create('church_members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->index()->constrained('users')->nullOnDelete();
            $table->string('membership_number')->unique();
            $table->string('full_name');
            $table->string('gender'); // e.g. Male, Female
            $table->date('birth_date');
            $table->string('phone');
            $table->string('email');
            $table->text('address');
            $table->date('baptism_date')->nullable();
            $table->string('status')->default('active'); // e.g. active, inactive
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('church_members');
    }
};
