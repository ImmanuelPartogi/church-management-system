<?php

namespace Tests\Feature\Member;

use App\Enums\DonationStatus;
use App\Models\ChartOfAccount;
use App\Models\Church;
use App\Models\ChurchMember;
use App\Models\ChurchUserMembership;
use App\Models\DonationConfirmation;
use App\Models\User;
use Database\Seeders\ModuleSeeder;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MemberDonationExportTest extends TestCase
{
    use RefreshDatabase;

    protected Church $churchA;

    protected Church $churchC;

    protected User $userDual;

    protected User $memberOther;

    protected ChartOfAccount $coaA;

    protected ChartOfAccount $coaC;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(RolesAndPermissionsSeeder::class);
        $this->seed(ModuleSeeder::class);

        // Gereja A
        $this->churchA = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Sudirman Medan',
            'slug' => 'hkbp-sudirman-medan',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'address' => 'Jl. Jend. Sudirman No. 10, Medan',
            'phone' => '061-123456',
            'email' => 'sudirman@hkbp.org',
        ]);

        // Gereja C (Untuk Uji Isolasi Dual-Membership ADR 7.4)
        $this->churchC = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Ressort Balige',
            'slug' => 'hkbp-ressort-balige',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'address' => 'Jl. Gereja No. 1, Balige',
            'phone' => '0632-654321',
            'email' => 'balige@hkbp.org',
        ]);

        app()->instance('current_church_id', $this->churchA->id);
        app()->instance('current_church', $this->churchA);
        setPermissionsTeamId($this->churchA->id);

        $this->coaA = ChartOfAccount::factory()->create([
            'church_id' => $this->churchA->id,
            'name' => 'Persembahan Ibadah Minggu',
            'code' => '4.1.1',
        ]);

        $this->coaC = ChartOfAccount::factory()->create([
            'church_id' => $this->churchC->id,
            'name' => 'Pembangunan Balige',
            'code' => '4.2.1',
        ]);

        // User Dual-Membership (Anggota di Gereja A dan Gereja C)
        $this->userDual = User::create([
            'name' => 'St. Binsar Simanjuntak',
            'email' => 'binsar.simanjuntak@hkbp.org',
            'password' => bcrypt('secret123'),
        ]);

        ChurchUserMembership::create([
            'church_id' => $this->churchA->id,
            'user_id' => $this->userDual->id,
            'role' => 'member',
            'status' => 'active',
        ]);

        ChurchUserMembership::create([
            'church_id' => $this->churchC->id,
            'user_id' => $this->userDual->id,
            'role' => 'member',
            'status' => 'active',
        ]);

        // Member Profil Resmi di Gereja A
        ChurchMember::factory()->create([
            'church_id' => $this->churchA->id,
            'user_id' => $this->userDual->id,
            'membership_number' => 'HKBP-SDR-2026-0042',
            'full_name' => 'St. Binsar Simanjuntak',
            'gender' => 'Male',
            'birth_date' => '1975-06-15',
            'phone' => '081234567890',
            'email' => 'binsar.simanjuntak@hkbp.org',
            'address' => 'Jl. Sudirman No. 42, Medan',
            'status' => 'active',
        ]);

        // Jemaat Lain di Gereja A
        $this->memberOther = User::create([
            'name' => 'Jemaat Lain',
            'email' => 'lain@hkbp.org',
            'password' => bcrypt('secret123'),
        ]);

        ChurchUserMembership::create([
            'church_id' => $this->churchA->id,
            'user_id' => $this->memberOther->id,
            'role' => 'member',
            'status' => 'active',
        ]);
    }

    /**
     * Test 1: myDonations filter berdasarkan rentang tanggal, kategori COA, dan status.
     */
    public function test_my_donations_filters_by_date_range_category_and_status(): void
    {
        Sanctum::actingAs($this->userDual);

        // Donasi 1: Approved, 2026-01-10
        DonationConfirmation::create([
            'church_id' => $this->churchA->id,
            'donation_number' => 'DON-20260110-APP',
            'user_id' => $this->userDual->id,
            'chart_of_account_id' => $this->coaA->id,
            'amount' => 100000,
            'transfer_date' => '2026-01-10',
            'sender_bank' => 'BCA',
            'status' => DonationStatus::Approved,
        ]);

        // Donasi 2: Pending, 2026-02-15
        DonationConfirmation::create([
            'church_id' => $this->churchA->id,
            'donation_number' => 'DON-20260215-PND',
            'user_id' => $this->userDual->id,
            'chart_of_account_id' => $this->coaA->id,
            'amount' => 200000,
            'transfer_date' => '2026-02-15',
            'sender_bank' => 'Mandiri',
            'status' => DonationStatus::Pending,
        ]);

        // Donasi 3: Rejected, 2026-03-01
        DonationConfirmation::create([
            'church_id' => $this->churchA->id,
            'donation_number' => 'DON-20260301-REJ',
            'user_id' => $this->userDual->id,
            'chart_of_account_id' => $this->coaA->id,
            'amount' => 300000,
            'transfer_date' => '2026-03-01',
            'sender_bank' => 'BRI',
            'status' => DonationStatus::Rejected,
            'rejection_reason' => 'Bukti mutasi tidak terbaca',
        ]);

        // Filter status=approved
        $responseApproved = $this->withHeaders(['X-Church-Id' => (string) $this->churchA->id])
            ->getJson('/api/v1/me/donations?status=approved');

        $responseApproved->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.donation_number', 'DON-20260110-APP');

        // Filter rentang tanggal Februari
        $responseFeb = $this->withHeaders(['X-Church-Id' => (string) $this->churchA->id])
            ->getJson('/api/v1/me/donations?start_date=2026-02-01&end_date=2026-02-28');

        $responseFeb->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.donation_number', 'DON-20260215-PND');

        // Filter status=all
        $responseAll = $this->withHeaders(['X-Church-Id' => (string) $this->churchA->id])
            ->getJson('/api/v1/me/donations?status=all');

        $responseAll->assertOk()
            ->assertJsonCount(3, 'data');
    }

    /**
     * Test 2: Ekspor PDF resmi (Statement of Giving) wajib mem-filter status approved secara hardcoded.
     * Transaksi pending dan rejected tidak boleh muncul sekalipun query mengirim parameter ?status=pending.
     */
    public function test_official_pdf_export_strictly_excludes_pending_and_rejected_donations_even_when_requested(): void
    {
        Sanctum::actingAs($this->userDual);

        // Donasi Approved
        DonationConfirmation::create([
            'church_id' => $this->churchA->id,
            'donation_number' => 'DON-OFFICIAL-VALID-999',
            'user_id' => $this->userDual->id,
            'chart_of_account_id' => $this->coaA->id,
            'amount' => 750000,
            'transfer_date' => '2026-05-10',
            'sender_bank' => 'BCA',
            'status' => DonationStatus::Approved,
        ]);

        // Donasi Pending
        DonationConfirmation::create([
            'church_id' => $this->churchA->id,
            'donation_number' => 'DON-ILLEGAL-PENDING-111',
            'user_id' => $this->userDual->id,
            'chart_of_account_id' => $this->coaA->id,
            'amount' => 9999999,
            'transfer_date' => '2026-05-11',
            'sender_bank' => 'BCA',
            'status' => DonationStatus::Pending,
        ]);

        // Donasi Rejected
        DonationConfirmation::create([
            'church_id' => $this->churchA->id,
            'donation_number' => 'DON-ILLEGAL-REJECTED-222',
            'user_id' => $this->userDual->id,
            'chart_of_account_id' => $this->coaA->id,
            'amount' => 8888888,
            'transfer_date' => '2026-05-12',
            'sender_bank' => 'BCA',
            'status' => DonationStatus::Rejected,
            'rejection_reason' => 'Nominal palsu',
        ]);

        // Request ekspor PDF dengan parameter ?status=pending (mencoba menipu filter)
        $response = $this->withHeaders(['X-Church-Id' => (string) $this->churchA->id])
            ->get('/api/v1/me/donations/export?format=pdf&status=pending');

        $response->assertOk();
        $response->assertHeader('Content-Type', 'application/pdf');

        $content = $this->extractPdfText($response->streamedContent());

        // PDF memuat nomor donasi yang approved
        $this->assertStringContainsString('DON-OFFICIAL-VALID-999', $content);
        // PDF TIDAK memuat donasi pending maupun rejected
        $this->assertStringNotContainsString('DON-ILLEGAL-PENDING-111', $content);
        $this->assertStringNotContainsString('DON-ILLEGAL-REJECTED-222', $content);
        $this->assertStringNotContainsString('9999999', $content);
        $this->assertStringNotContainsString('8888888', $content);
    }

    /**
     * Test 3: Ekspor PDF resmi tetap render dengan elegan jika user belum memiliki profil ChurchMember (akun mandiri).
     */
    public function test_official_pdf_export_renders_gracefully_when_user_has_no_church_member_profile(): void
    {
        // User Mandiri tanpa record ChurchMember
        $selfUser = User::create([
            'name' => 'Jemaat Mandiri Baru',
            'email' => 'mandiri@gmail.com',
            'password' => bcrypt('secret123'),
        ]);

        ChurchUserMembership::create([
            'church_id' => $this->churchA->id,
            'user_id' => $selfUser->id,
            'role' => 'member',
            'status' => 'active',
        ]);

        DonationConfirmation::create([
            'church_id' => $this->churchA->id,
            'donation_number' => 'DON-MANDIRI-555',
            'user_id' => $selfUser->id,
            'chart_of_account_id' => $this->coaA->id,
            'amount' => 50000,
            'transfer_date' => '2026-06-01',
            'sender_bank' => 'BCA',
            'status' => DonationStatus::Approved,
        ]);

        Sanctum::actingAs($selfUser);

        $response = $this->withHeaders(['X-Church-Id' => (string) $this->churchA->id])
            ->get('/api/v1/me/donations/export?format=pdf');

        $response->assertOk();
        $response->assertHeader('Content-Type', 'application/pdf');

        $content = $this->extractPdfText($response->streamedContent());
        $this->assertStringContainsString('Jemaat Mandiri Baru', $content);
        $this->assertStringContainsString('DON-MANDIRI-555', $content);
    }

    /**
     * Test 4: Ekspor PDF resmi pada periode tanpa donasi approved (zero-record state)
     * merender pesan informatif tanpa melempar error 500.
     */
    public function test_official_pdf_export_renders_gracefully_with_zero_approved_donations_in_period(): void
    {
        Sanctum::actingAs($this->userDual);

        // Hanya donasi di tahun 2026
        DonationConfirmation::create([
            'church_id' => $this->churchA->id,
            'donation_number' => 'DON-2026-HISTORIS',
            'user_id' => $this->userDual->id,
            'chart_of_account_id' => $this->coaA->id,
            'amount' => 100000,
            'transfer_date' => '2026-01-01',
            'sender_bank' => 'BCA',
            'status' => DonationStatus::Approved,
        ]);

        // Minta periode tahun 2024 (pasti kosong)
        $response = $this->withHeaders(['X-Church-Id' => (string) $this->churchA->id])
            ->get('/api/v1/me/donations/export?format=pdf&start_date=2024-01-01&end_date=2024-12-31');

        $response->assertOk();
        $response->assertHeader('Content-Type', 'application/pdf');

        $content = $this->extractPdfText($response->streamedContent());
        // Memuat pesan fallback empty state
        $this->assertStringContainsString('Tidak ada persembahan tercatat pada periode ini', $content);
    }

    /**
     * Test 5: Ekspor CSV informal memuat seluruh status dan menyertakan kolom alasan penolakan.
     */
    public function test_csv_export_includes_all_statuses_with_rejection_reasons_for_personal_audit(): void
    {
        Sanctum::actingAs($this->userDual);

        DonationConfirmation::create([
            'church_id' => $this->churchA->id,
            'donation_number' => 'DON-CSV-APP-1',
            'user_id' => $this->userDual->id,
            'chart_of_account_id' => $this->coaA->id,
            'amount' => 150000,
            'transfer_date' => '2026-07-01',
            'sender_bank' => 'BCA',
            'status' => DonationStatus::Approved,
        ]);

        DonationConfirmation::create([
            'church_id' => $this->churchA->id,
            'donation_number' => 'DON-CSV-REJ-2',
            'user_id' => $this->userDual->id,
            'chart_of_account_id' => $this->coaA->id,
            'amount' => 250000,
            'transfer_date' => '2026-07-02',
            'sender_bank' => 'Mandiri',
            'status' => DonationStatus::Rejected,
            'rejection_reason' => 'Nominal transfer tidak sesuai mutasi bank',
        ]);

        $response = $this->withHeaders(['X-Church-Id' => (string) $this->churchA->id])
            ->get('/api/v1/me/donations/export?format=csv&status=all');

        $response->assertOk();
        $this->assertStringContainsString('text/csv', (string) $response->headers->get('Content-Type'));

        $content = $response->streamedContent();

        // Verifikasi UTF-8 BOM
        $this->assertStringStartsWith("\xEF\xBB\xBF", $content);

        // Verifikasi header dan baris data
        $this->assertStringContainsString('BUKU PEMBANTU RIWAYAT PERSEMBAHAN JEMAAT', $content);
        $this->assertStringContainsString('DON-CSV-APP-1', $content);
        $this->assertStringContainsString('Disetujui', $content);
        $this->assertStringContainsString('DON-CSV-REJ-2', $content);
        $this->assertStringContainsString('Ditolak', $content);
        $this->assertStringContainsString('Nominal transfer tidak sesuai mutasi bank', $content);
    }

    /**
     * Test 6: Strict Double-Scoping (ChurchScope + BelongsToMember).
     * Membuktikan isolasi total pada akun dual-membership:
     * Donasi User X di Gereja A tidak pernah bocor saat User X mengekspor di Gereja C.
     * Serta donasi User Y di Gereja C tidak pernah bocor ke User X.
     */
    public function test_export_respects_cross_tenant_and_cross_member_isolation_strictly(): void
    {
        // Donasi milik UserDual di Gereja A (dibuat di context Gereja A)
        app()->instance('current_church_id', $this->churchA->id);
        app()->instance('current_church', $this->churchA);
        setPermissionsTeamId($this->churchA->id);

        $donA = new DonationConfirmation([
            'donation_number' => 'DON-CHURCH-A-DUAL-777',
            'user_id' => $this->userDual->id,
            'chart_of_account_id' => $this->coaA->id,
            'amount' => 500000,
            'transfer_date' => '2026-08-01',
            'sender_bank' => 'BCA',
            'status' => DonationStatus::Approved,
        ]);
        $donA->church_id = $this->churchA->id;
        $donA->save();

        // Donasi milik UserDual di Gereja C (dibuat di context Gereja C)
        app()->instance('current_church_id', $this->churchC->id);
        app()->instance('current_church', $this->churchC);
        setPermissionsTeamId($this->churchC->id);

        $donC1 = new DonationConfirmation([
            'donation_number' => 'DON-CHURCH-C-DUAL-888',
            'user_id' => $this->userDual->id,
            'chart_of_account_id' => $this->coaC->id,
            'amount' => 750000,
            'transfer_date' => '2026-08-02',
            'sender_bank' => 'BNI',
            'status' => DonationStatus::Approved,
        ]);
        $donC1->church_id = $this->churchC->id;
        $donC1->save();

        // Donasi milik Jemaat Lain di Gereja C
        $donC2 = new DonationConfirmation([
            'donation_number' => 'DON-CHURCH-C-OTHER-999',
            'user_id' => $this->memberOther->id,
            'chart_of_account_id' => $this->coaC->id,
            'amount' => 1000000,
            'transfer_date' => '2026-08-03',
            'sender_bank' => 'BRI',
            'status' => DonationStatus::Approved,
        ]);
        $donC2->church_id = $this->churchC->id;
        $donC2->save();

        Sanctum::actingAs($this->userDual);

        // UserDual mengakses di konteks Gereja C (Balige)
        $responseCsv = $this->withHeaders(['X-Church-Id' => (string) $this->churchC->id])
            ->get('/api/v1/me/donations/export?format=csv');

        $responseCsv->assertOk();
        $csvContent = $responseCsv->streamedContent();

        // 1. Memuat donasi miliknya sendiri di Gereja C
        $this->assertStringContainsString('DON-CHURCH-C-DUAL-888', $csvContent);

        // 2. TIDAK memuat donasi miliknya sendiri di Gereja A (Anti Cross-Tenant Leakage)
        $this->assertStringNotContainsString('DON-CHURCH-A-DUAL-777', $csvContent);

        // 3. TIDAK memuat donasi jemaat lain di Gereja C (Anti Cross-Member Leakage)
        $this->assertStringNotContainsString('DON-CHURCH-C-OTHER-999', $csvContent);

        // Lakukan verifikasi identik pada ekspor PDF resmi di konteks Gereja C
        $responsePdf = $this->withHeaders(['X-Church-Id' => (string) $this->churchC->id])
            ->get('/api/v1/me/donations/export?format=pdf');

        $responsePdf->assertOk();
        $pdfContent = $this->extractPdfText($responsePdf->streamedContent());

        $this->assertStringContainsString('DON-CHURCH-C-DUAL-888', $pdfContent);
        $this->assertStringNotContainsString('DON-CHURCH-A-DUAL-777', $pdfContent);
        $this->assertStringNotContainsString('DON-CHURCH-C-OTHER-999', $pdfContent);
    }

    /**
     * Helper to extract and uncompress all FlateDecode streams in a raw PDF binary.
     */
    protected function extractPdfText(string $pdfBinary): string
    {
        $text = $pdfBinary;
        if (preg_match_all('#stream[\r\n]+(.*?)[\r\n]+endstream#s', $pdfBinary, $matches)) {
            foreach ($matches[1] as $stream) {
                $uncompressed = @gzuncompress($stream);
                if ($uncompressed !== false) {
                    $text .= ' '.$uncompressed;
                }
            }
        }

        return $text;
    }
}
