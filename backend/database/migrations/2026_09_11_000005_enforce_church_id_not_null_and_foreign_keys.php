<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * The 16 domain tables where church_id must be strictly NOT NULL.
     */
    protected array $churchScopedTables = [
        'church_members',
        'worship_schedules',
        'announcements',
        'wartas',
        'service_form_types',
        'service_form_applications',
        'prayer_requests',
        'church_bank_accounts',
        'chart_of_accounts',
        'donation_confirmations',
        'financial_transactions',
        'resorts',
        'sectors',
        'fellowships',
        'church_servants',
        'sermons',
    ];

    /**
     * Run the migrations.
     *
     * Alters church_id on all 16 domain tables from nullable to NOT NULL.
     */
    public function up(): void
    {
        foreach ($this->churchScopedTables as $tableName) {
            Schema::table($tableName, function (Blueprint $table) {
                $table->foreignId('church_id')->nullable(false)->change();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        foreach (array_reverse($this->churchScopedTables) as $tableName) {
            Schema::table($tableName, function (Blueprint $table) {
                $table->foreignId('church_id')->nullable()->change();
            });
        }
    }
};
