<?php

namespace Tests\Feature\Member;

use App\Enums\DonationStatus;
use App\Models\ChartOfAccount;
use App\Models\Church;
use App\Models\ChurchUserMembership;
use App\Models\DonationConfirmation;
use App\Models\User;
use Database\Seeders\ModuleSeeder;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class MemberLevelDonationScopingTest extends TestCase
{
    use RefreshDatabase;

    protected Church $church;

    protected User $memberA;

    protected User $memberB;

    protected User $treasurer;

    protected DonationConfirmation $donationA1;

    protected DonationConfirmation $donationA2;

    protected DonationConfirmation $donationB1;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(RolesAndPermissionsSeeder::class);
        $this->seed(ModuleSeeder::class);

        $this->church = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Sudirman Medan',
            'slug' => 'hkbp-sudirman-medan',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        app()->instance('current_church_id', $this->church->id);
        app()->instance('current_church', $this->church);
        setPermissionsTeamId($this->church->id);

        $coa = ChartOfAccount::factory()->create([
            'church_id' => $this->church->id,
        ]);

        // Jemaat A
        $this->memberA = User::create([
            'name' => 'Jemaat Alpha',
            'email' => 'jemaat.a@hkbp.org',
            'password' => bcrypt('secret123'),
        ]);
        ChurchUserMembership::create([
            'church_id' => $this->church->id,
            'user_id' => $this->memberA->id,
            'role' => 'member',
            'status' => 'active',
        ]);

        // Jemaat B (di gereja yang sama)
        $this->memberB = User::create([
            'name' => 'Jemaat Beta',
            'email' => 'jemaat.b@hkbp.org',
            'password' => bcrypt('secret123'),
        ]);
        ChurchUserMembership::create([
            'church_id' => $this->church->id,
            'user_id' => $this->memberB->id,
            'role' => 'member',
            'status' => 'active',
        ]);

        // Bendahara Gereja
        Role::firstOrCreate([
            'name' => 'bendahara',
            'guard_name' => 'web',
            'church_id' => $this->church->id,
        ]);

        $this->treasurer = User::create([
            'name' => 'Bendahara Jemaat',
            'email' => 'bendahara@hkbp.org',
            'password' => bcrypt('secret123'),
        ]);
        ChurchUserMembership::create([
            'church_id' => $this->church->id,
            'user_id' => $this->treasurer->id,
            'role' => 'bendahara',
            'status' => 'active',
        ]);
        $this->treasurer->assignRole('bendahara');

        // Donasi milik Jemaat A
        $this->donationA1 = DonationConfirmation::create([
            'church_id' => $this->church->id,
            'user_id' => $this->memberA->id,
            'donation_number' => 'DON-A-001',
            'chart_of_account_id' => $coa->id,
            'amount' => 500000,
            'transfer_date' => now()->subDays(2),
            'sender_bank' => 'BCA',
            'status' => DonationStatus::Approved,
        ]);

        $this->donationA2 = DonationConfirmation::create([
            'church_id' => $this->church->id,
            'user_id' => $this->memberA->id,
            'donation_number' => 'DON-A-002',
            'chart_of_account_id' => $coa->id,
            'amount' => 250000,
            'transfer_date' => now()->subDay(),
            'sender_bank' => 'Mandiri',
            'status' => DonationStatus::Processing,
        ]);

        // Donasi milik Jemaat B
        $this->donationB1 = DonationConfirmation::create([
            'church_id' => $this->church->id,
            'user_id' => $this->memberB->id,
            'donation_number' => 'DON-B-001',
            'chart_of_account_id' => $coa->id,
            'amount' => 1000000,
            'transfer_date' => now(),
            'sender_bank' => 'BRI',
            'status' => DonationStatus::Processing,
        ]);
    }

    /**
     * Uji 1: Jemaat A dapat melihat daftar persembahannya sendiri via endpoint /me/donations.
     */
    public function test_member_can_view_own_donations_via_me_endpoint(): void
    {
        Sanctum::actingAs($this->memberA);

        $response = $this->getJson('/api/v1/me/donations', [
            'X-Church-Id' => (string) $this->church->id,
        ]);

        $response->assertSuccessful();
        $response->assertJsonCount(2, 'data');
        $response->assertJsonFragment(['donation_number' => 'DON-A-001']);
        $response->assertJsonFragment(['donation_number' => 'DON-A-002']);
        $response->assertJsonMissing(['donation_number' => 'DON-B-001']);
    }

    /**
     * Uji 2: Jemaat B dalam gereja yang sama TIDAK BISA melihat donasi Jemaat A (uji kritis intra-tenant privacy).
     */
    public function test_member_cannot_view_another_members_donations_within_same_church(): void
    {
        Sanctum::actingAs($this->memberB);

        // 1. Pada listing /me/donations, hanya donasi miliknya sendiri yang muncul
        $listResponse = $this->getJson('/api/v1/me/donations', [
            'X-Church-Id' => (string) $this->church->id,
        ]);

        $listResponse->assertSuccessful();
        $listResponse->assertJsonCount(1, 'data');
        $listResponse->assertJsonFragment(['donation_number' => 'DON-B-001']);
        $listResponse->assertJsonMissing(['donation_number' => 'DON-A-001']);
        $listResponse->assertJsonMissing(['donation_number' => 'DON-A-002']);

        // 2. Upaya akses langsung via ID milik Jemaat A ditolak dengan HTTP 403 Forbidden!
        $detailResponse = $this->getJson("/api/v1/donations/{$this->donationA1->id}", [
            'X-Church-Id' => (string) $this->church->id,
        ]);

        $detailResponse->assertStatus(403);
        $detailResponse->assertJsonFragment([
            'message' => 'You are not authorized to view this donation confirmation.',
        ]);
    }

    /**
     * Uji 3: Bendahara gereja memegang wewenang administratif penuh atas seluruh donasi di gerejanya.
     */
    public function test_treasurer_can_view_all_tenant_donations_administratively(): void
    {
        Sanctum::actingAs($this->treasurer);

        // Query administratif scoped ke gereja (tanpa filter user_id)
        $allTenantDonations = DonationConfirmation::where('church_id', $this->church->id)->get();

        $this->assertCount(3, $allTenantDonations);
        $this->assertTrue($allTenantDonations->contains('donation_number', 'DON-A-001'));
        $this->assertTrue($allTenantDonations->contains('donation_number', 'DON-A-002'));
        $this->assertTrue($allTenantDonations->contains('donation_number', 'DON-B-001'));

        // Trait helper isOwnedBy memvalidasi kepemilikan personal secara akurat
        $this->assertTrue($this->donationA1->isOwnedBy($this->memberA));
        $this->assertFalse($this->donationA1->isOwnedBy($this->memberB));
    }
}
