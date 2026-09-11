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
        Schema::table('churches', function (Blueprint $table) {
            $table->string('theme_primary_color', 7)->default('#1B4B66')->after('logo_path');
            $table->string('theme_secondary_color', 7)->default('#F5A623')->after('theme_primary_color');
            $table->unsignedInteger('theme_version')->default(1)->after('theme_secondary_color');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('churches', function (Blueprint $table) {
            $table->dropColumn(['theme_primary_color', 'theme_secondary_color', 'theme_version']);
        });
    }
};
