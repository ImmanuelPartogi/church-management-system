<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('device_tokens', function (Blueprint $table) {
            // 1. Convert user_id to nullable for guest browsing devices
            $table->foreignId('user_id')->nullable()->change();

            // 2. Add church_id foreign key constrained to churches table
            $table->foreignId('church_id')
                ->nullable()
                ->after('user_id')
                ->constrained('churches')
                ->cascadeOnDelete();

            // 3. Add is_active flag for soft revocation & hygiene
            $table->boolean('is_active')
                ->default(true)
                ->after('device_name');

            // 4. Drop old single-token unique index to allow multi-tenant registration
            $table->dropUnique(['token']);

            // 5. Add composite unique constraint per (token, church_id)
            $table->unique(['token', 'church_id'], 'device_tokens_token_church_unique');

            // 6. Performance composite index for tenant-scoped broadcast blasts
            $table->index(['church_id', 'is_active'], 'device_tokens_church_id_is_active_index');
        });

        // Automated Data Reconciliation for Legacy Rows (if any exist)
        $this->reconcileLegacyTokens();
    }

    /**
     * Reconcile legacy device tokens that lack church_id.
     */
    protected function reconcileLegacyTokens(): void
    {
        $legacyTokens = DB::table('device_tokens')
            ->whereNull('church_id')
            ->whereNotNull('user_id')
            ->get();

        foreach ($legacyTokens as $tokenRow) {
            $memberships = DB::table('church_user_memberships')
                ->where('user_id', $tokenRow->user_id)
                ->where('status', 'active')
                ->pluck('church_id');

            if ($memberships->isNotEmpty()) {
                // Assign first active church to current row
                DB::table('device_tokens')
                    ->where('id', $tokenRow->id)
                    ->update([
                        'church_id' => $memberships->first(),
                        'is_active' => true,
                    ]);

                // For multi-membership users (e.g. pastor serving 2 churches),
                // spawn additional rows for the remaining active memberships so they don't lose push!
                foreach ($memberships->skip(1) as $otherChurchId) {
                    DB::table('device_tokens')->insert([
                        'user_id' => $tokenRow->user_id,
                        'church_id' => $otherChurchId,
                        'token' => $tokenRow->token,
                        'platform' => $tokenRow->platform,
                        'device_name' => $tokenRow->device_name,
                        'is_active' => true,
                        'last_used_at' => $tokenRow->last_used_at,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // 1. Clean up rows with NULL user_id before re-enforcing NOT NULL
        DB::table('device_tokens')->whereNull('user_id')->delete();

        // 2. Deduplicate tokens before re-applying single unique constraint
        $duplicateTokenKeepIds = DB::table('device_tokens')
            ->select('token', DB::raw('MIN(id) as keep_id'))
            ->groupBy('token')
            ->havingRaw('COUNT(*) > 1')
            ->pluck('keep_id');

        if ($duplicateTokenKeepIds->isNotEmpty()) {
            DB::table('device_tokens')
                ->whereIn('token', function ($query) {
                    $query->select('token')
                        ->from('device_tokens')
                        ->groupBy('token')
                        ->havingRaw('COUNT(*) > 1');
                })
                ->whereNotIn('id', $duplicateTokenKeepIds)
                ->delete();
        }

        Schema::table('device_tokens', function (Blueprint $table) {
            $table->dropUnique('device_tokens_token_church_unique');
            $table->dropIndex('device_tokens_church_id_is_active_index');
            $table->dropConstrainedForeignId('church_id');
            $table->dropColumn('is_active');
            $table->unique('token');
            $table->foreignId('user_id')->nullable(false)->change();
        });
    }
};
