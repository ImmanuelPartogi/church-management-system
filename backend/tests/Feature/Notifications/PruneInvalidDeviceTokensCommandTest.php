<?php

namespace Tests\Feature\Notifications;

use App\Models\Church;
use App\Models\DeviceToken;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

class PruneInvalidDeviceTokensCommandTest extends TestCase
{
    use RefreshDatabase;

    public function test_prunes_stale_and_inactive_device_tokens_older_than_threshold(): void
    {
        $church = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Tarutung',
            'slug' => 'hkbp-tarutung',
            'status' => 'active',
        ]);

        $user = User::create([
            'name' => 'Jemaat Tarutung',
            'email' => 'jemaat@tarutung.org',
            'password' => bcrypt('secret'),
        ]);

        // 1. Fresh active token (active 5 days ago) - MUST KEEP
        $freshToken = DeviceToken::create([
            'user_id' => $user->id,
            'church_id' => $church->id,
            'token' => 'fcm_fresh_active_token',
            'platform' => 'android',
            'is_active' => true,
            'last_used_at' => now()->subDays(5),
        ]);

        // 2. Stale active token (inactive 65 days ago) - MUST PRUNE
        $staleToken = DeviceToken::create([
            'user_id' => $user->id,
            'church_id' => $church->id,
            'token' => 'fcm_stale_active_token',
            'platform' => 'android',
            'is_active' => true,
            'last_used_at' => now()->subDays(65),
        ]);

        // 3. Deactivated token (suspended 70 days ago) - MUST PRUNE
        $deactivatedOldToken = DeviceToken::create([
            'user_id' => $user->id,
            'church_id' => $church->id,
            'token' => 'fcm_deactivated_old_token',
            'platform' => 'ios',
            'is_active' => false,
        ]);
        DB::table('device_tokens')
            ->where('id', $deactivatedOldToken->id)
            ->update([
                'created_at' => now()->subDays(70),
                'updated_at' => now()->subDays(70),
            ]);

        // 4. Deactivated token recently (suspended 2 days ago) - MUST KEEP
        $deactivatedRecentToken = DeviceToken::create([
            'user_id' => $user->id,
            'church_id' => $church->id,
            'token' => 'fcm_deactivated_recent_token',
            'platform' => 'ios',
            'is_active' => false,
        ]);
        DB::table('device_tokens')
            ->where('id', $deactivatedRecentToken->id)
            ->update([
                'created_at' => now()->subDays(2),
                'updated_at' => now()->subDays(2),
            ]);

        // Run command with default 60 days
        $this->artisan('device-tokens:prune --days=60')
            ->expectsOutputToContain('Successfully pruned 2 stale device token(s).')
            ->assertExitCode(0);

        // Assert fresh token still exists
        $this->assertDatabaseHas('device_tokens', ['token' => 'fcm_fresh_active_token']);

        // Assert recently deactivated token still exists
        $this->assertDatabaseHas('device_tokens', ['token' => 'fcm_deactivated_recent_token']);

        // Assert old stale tokens are gone
        $this->assertDatabaseMissing('device_tokens', ['token' => 'fcm_stale_active_token']);
        $this->assertDatabaseMissing('device_tokens', ['token' => 'fcm_deactivated_old_token']);
    }

    public function test_rejects_invalid_days_argument(): void
    {
        $this->artisan('device-tokens:prune --days=0')
            ->expectsOutputToContain('The --days option must be at least 1.')
            ->assertExitCode(1);
    }
}
