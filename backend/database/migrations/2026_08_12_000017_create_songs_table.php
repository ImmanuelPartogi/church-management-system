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
        Schema::create('songs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('songbook_id')->index()->constrained('songbooks')->cascadeOnDelete();
            $table->unsignedInteger('number');
            $table->string('title')->index();
            $table->text('lyrics');
            $table->boolean('active')->default(true)->index();
            $table->timestamps();

            $table->unique(['songbook_id', 'number']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('songs');
    }
};
