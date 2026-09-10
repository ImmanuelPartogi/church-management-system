<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Converts single-column unique constraints into composite unique constraints
     * scoped to (church_id, column) across all 9 validated multi-tenant domain tables.
     */
    public function up(): void
    {
        // 1. church_members: (church_id, membership_number)
        Schema::table('church_members', function (Blueprint $table) {
            $table->dropUnique('church_members_membership_number_unique');
            $table->unique(['church_id', 'membership_number']);
        });

        // 2. service_form_types: (church_id, slug)
        Schema::table('service_form_types', function (Blueprint $table) {
            $table->dropUnique('service_form_types_slug_unique');
            $table->unique(['church_id', 'slug']);
        });

        // 3. service_form_applications: (church_id, application_number)
        Schema::table('service_form_applications', function (Blueprint $table) {
            $table->dropUnique('service_form_applications_application_number_unique');
            $table->unique(['church_id', 'application_number']);
        });

        // 4. chart_of_accounts: (church_id, code)
        Schema::table('chart_of_accounts', function (Blueprint $table) {
            $table->dropUnique('chart_of_accounts_code_unique');
            $table->unique(['church_id', 'code']);
        });

        // 5. donation_confirmations: (church_id, donation_number)
        Schema::table('donation_confirmations', function (Blueprint $table) {
            $table->dropUnique('donation_confirmations_donation_number_unique');
            $table->unique(['church_id', 'donation_number']);
        });

        // 6. financial_transactions: (church_id, transaction_number)
        Schema::table('financial_transactions', function (Blueprint $table) {
            $table->dropUnique('financial_transactions_transaction_number_unique');
            $table->unique(['church_id', 'transaction_number']);
        });

        // 7. resorts: (church_id, name) & (church_id, code)
        Schema::table('resorts', function (Blueprint $table) {
            $table->dropUnique('resorts_name_unique');
            $table->dropUnique('resorts_code_unique');
            $table->unique(['church_id', 'name']);
            $table->unique(['church_id', 'code']);
        });

        // 8. fellowships: (church_id, name) & (church_id, code)
        Schema::table('fellowships', function (Blueprint $table) {
            $table->dropUnique('fellowships_name_unique');
            $table->dropUnique('fellowships_code_unique');
            $table->unique(['church_id', 'name']);
            $table->unique(['church_id', 'code']);
        });

        // 9. sectors: (church_id, resort_id, name)
        Schema::table('sectors', function (Blueprint $table) {
            $table->dropUnique('sectors_resort_id_name_unique');
            $table->unique(['church_id', 'resort_id', 'name']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // 9. sectors
        Schema::table('sectors', function (Blueprint $table) {
            $table->dropUnique(['church_id', 'resort_id', 'name']);
            $table->unique(['resort_id', 'name']);
        });

        // 8. fellowships
        Schema::table('fellowships', function (Blueprint $table) {
            $table->dropUnique(['church_id', 'name']);
            $table->dropUnique(['church_id', 'code']);
            $table->unique('name');
            $table->unique('code');
        });

        // 7. resorts
        Schema::table('resorts', function (Blueprint $table) {
            $table->dropUnique(['church_id', 'name']);
            $table->dropUnique(['church_id', 'code']);
            $table->unique('name');
            $table->unique('code');
        });

        // 6. financial_transactions
        Schema::table('financial_transactions', function (Blueprint $table) {
            $table->dropUnique(['church_id', 'transaction_number']);
            $table->unique('transaction_number');
        });

        // 5. donation_confirmations
        Schema::table('donation_confirmations', function (Blueprint $table) {
            $table->dropUnique(['church_id', 'donation_number']);
            $table->unique('donation_number');
        });

        // 4. chart_of_accounts
        Schema::table('chart_of_accounts', function (Blueprint $table) {
            $table->dropUnique(['church_id', 'code']);
            $table->unique('code');
        });

        // 3. service_form_applications
        Schema::table('service_form_applications', function (Blueprint $table) {
            $table->dropUnique(['church_id', 'application_number']);
            $table->unique('application_number');
        });

        // 2. service_form_types
        Schema::table('service_form_types', function (Blueprint $table) {
            $table->dropUnique(['church_id', 'slug']);
            $table->unique('slug');
        });

        // 1. church_members
        Schema::table('church_members', function (Blueprint $table) {
            $table->dropUnique(['church_id', 'membership_number']);
            $table->unique('membership_number');
        });
    }
};
