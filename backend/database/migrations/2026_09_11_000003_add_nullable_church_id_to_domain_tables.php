<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * The 16 domain tables validated as CHURCH-SCOPED.
     *
     * Mapped with their respective onDelete behaviors for Phase 1C:
     * - 'restrict': Applied to financial audit trails, legal documents, and chart of accounts.
     *   Accidental hard deletion of a church MUST NOT cascade delete financial audit books or legally binding applications.
     * - 'cascade': Applied to operational, informational, and organizational entities.
     *
     * CRITICAL: All church_id columns are strictly NULLABLE in this phase.
     * No backfill is performed here (reserved for Phase 1D).
     * Final constraint hardening (NOT NULL) and review of cascade behavior will take place in Phase 1E.
     */
    protected array $churchScopedTables = [
        'church_members' => 'cascade',
        'worship_schedules' => 'cascade',
        'announcements' => 'cascade',
        'wartas' => 'cascade',
        'service_form_types' => 'cascade',
        'service_form_applications' => 'restrict',
        'prayer_requests' => 'cascade',
        'church_bank_accounts' => 'restrict',
        'chart_of_accounts' => 'restrict',
        'donation_confirmations' => 'restrict',
        'financial_transactions' => 'restrict',
        'resorts' => 'cascade',
        'sectors' => 'cascade',
        'fellowships' => 'cascade',
        'church_servants' => 'cascade',
        'sermons' => 'cascade',
    ];

    /**
     * Run the migrations.
     */
    public function up(): void
    {
        foreach ($this->churchScopedTables as $tableName => $onDelete) {
            Schema::table($tableName, function (Blueprint $table) use ($onDelete) {
                $column = $table->foreignId('church_id')
                    ->nullable()
                    ->index()
                    ->after('id');

                if ($onDelete === 'restrict') {
                    $column->constrained('churches')->restrictOnDelete();
                } else {
                    $column->constrained('churches')->cascadeOnDelete();
                }
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        foreach (array_reverse(array_keys($this->churchScopedTables)) as $tableName) {
            Schema::table($tableName, function (Blueprint $table) {
                $table->dropForeign(['church_id']);
                $table->dropIndex(['church_id']);
                $table->dropColumn('church_id');
            });
        }
    }
};
