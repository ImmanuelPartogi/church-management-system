<?php

namespace Tests\Feature\Synod;

use App\Filament\Pages\SynodDashboard;
use App\Models\Church;
use App\Models\SynodReportSnapshot;
use App\Models\User;
use App\Services\Reporting\SynodReportExportService;
use Database\Seeders\ModuleSeeder;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Log;
use InvalidArgumentException;
use Livewire\Livewire;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Tests\TestCase;

class SynodReportExportTest extends TestCase
{
    use RefreshDatabase;

    protected User $superAdmin;

    protected User $churchAdmin;

    protected Church $church;

    protected SynodReportExportService $exportService;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(RolesAndPermissionsSeeder::class);
        $this->seed(ModuleSeeder::class);

        $this->church = Church::where('slug', 'default')->first();

        $this->superAdmin = User::create([
            'name' => 'Super Admin',
            'email' => 'superadmin@synod.org',
            'password' => bcrypt('password'),
            'is_super_admin' => true,
        ]);

        $this->churchAdmin = User::create([
            'name' => 'Church Admin',
            'email' => 'admin@church.org',
            'password' => bcrypt('password'),
            'is_super_admin' => false,
        ]);

        $this->exportService = app(SynodReportExportService::class);
    }

    /**
     * Helper to create a representative snapshot.
     */
    protected function createSampleSnapshot(): SynodReportSnapshot
    {
        return SynodReportSnapshot::create([
            'generated_by_user_id' => $this->superAdmin->id,
            'period_date' => now()->toDateString(),
            'total_churches' => 3,
            'active_churches' => 2,
            'suspended_churches' => 1,
            'total_active_members' => 450,
            'total_all_members' => 550,
            'total_active_donations' => 25000000.00,
            'total_all_donations' => 28000000.00,
            'total_active_sacraments' => 40,
            'total_all_sacraments' => 45,
            'church_comparisons' => [
                [
                    'id' => 1,
                    'name' => 'HKBP Sudirman Active',
                    'slug' => 'hkbp-sudirman-active',
                    'status' => 'active',
                    'member_count' => 300,
                    'active_modules_count' => 12,
                    'total_modules_provisioned' => 12,
                    'provisioning_status' => 'provisioned',
                    'total_donations' => 18000000.00,
                ],
                [
                    'id' => 2,
                    'name' => 'HKBP Bandung Active Unprovisioned',
                    'slug' => 'hkbp-bandung-active-unprov',
                    'status' => 'active',
                    'member_count' => 150,
                    'active_modules_count' => 0,
                    'total_modules_provisioned' => 0,
                    'provisioning_status' => 'unprovisioned',
                    'total_donations' => 7000000.00,
                ],
                [
                    'id' => 3,
                    'name' => 'HKBP Medan Suspended',
                    'slug' => 'hkbp-medan-suspended',
                    'status' => 'suspended',
                    'member_count' => 100,
                    'active_modules_count' => 6,
                    'total_modules_provisioned' => 12,
                    'provisioning_status' => 'provisioned',
                    'total_donations' => 3000000.00,
                ],
            ],
            'module_adoption' => [
                [
                    'key' => 'members',
                    'name' => 'Manajemen Jemaat',
                    'is_core' => true,
                    'active_count' => 2,
                    'total_active_churches' => 2,
                    'adoption_percentage' => 100.0,
                ],
                [
                    'key' => 'donations',
                    'name' => 'Persembahan',
                    'is_core' => true,
                    'active_count' => 1,
                    'total_active_churches' => 2,
                    'adoption_percentage' => 50.0,
                ],
            ],
        ]);
    }

    public function test_export_pdf_streams_binary_pdf_with_correct_headers_and_logs_audit(): void
    {
        $this->actingAs($this->superAdmin);
        $snapshot = $this->createSampleSnapshot();

        Log::shouldReceive('channel')
            ->with('single')
            ->once()
            ->andReturnSelf();

        Log::shouldReceive('info')
            ->once()
            ->with('SynodDashboard.exported', \Mockery::on(function (array $payload) use ($snapshot) {
                return $payload['format'] === 'pdf'
                    && $payload['snapshot_id'] === $snapshot->id
                    && $payload['user_id'] === $this->superAdmin->id
                    && $payload['user_email'] === $this->superAdmin->email;
            }));

        $preExportMemoryLimit = ini_get('memory_limit');
        $response = $this->exportService->exportPdf($snapshot);

        // Memory limit must be faithfully restored to its exact pre-execution state
        $this->assertSame($preExportMemoryLimit, ini_get('memory_limit'));

        $this->assertInstanceOf(StreamedResponse::class, $response);
        $this->assertSame('application/pdf', $response->headers->get('Content-Type'));
        $this->assertStringContainsString('laporan-konsolidasi-sinode-', $response->headers->get('Content-Disposition'));

        // Capture in-memory stream output
        ob_start();
        $response->sendContent();
        $content = ob_get_clean();

        // Must start with PDF magic bytes %PDF-
        $this->assertStringStartsWith('%PDF-', $content);
        $this->assertGreaterThan(5000, strlen($content));
    }

    public function test_export_pdf_restores_original_memory_limit_without_worker_context_leak(): void
    {
        $this->actingAs($this->superAdmin);
        $snapshot = $this->createSampleSnapshot();

        // Artificially simulate a tight PHP-FPM / CLI worker limit (below 256M, but above current usage)
        $previous = ini_get('memory_limit');
        $currentAllocatedMb = (int) ceil(memory_get_usage(true) / (1024 * 1024));
        $tightLimitMb = max(128, $currentAllocatedMb + 16);

        if ($tightLimitMb >= 256) {
            $this->markTestSkipped('Current memory allocation exceeds 240M; cannot simulate sub-256M worker limit in this process.');
        }

        $simulatedLimit = "{$tightLimitMb}M";
        ini_set('memory_limit', $simulatedLimit);

        try {
            $this->assertSame($simulatedLimit, ini_get('memory_limit'));

            $response = $this->exportService->exportPdf($snapshot);

            // Verified: Elevated during run, but reverted cleanly to original simulated limit in finally block
            $this->assertSame($simulatedLimit, ini_get('memory_limit'));
            $this->assertInstanceOf(StreamedResponse::class, $response);
        } finally {
            ini_set('memory_limit', $previous);
        }
    }

    public function test_export_csv_streams_utf8_bom_csv_with_complete_data_and_logs_audit(): void
    {
        $this->actingAs($this->superAdmin);
        $snapshot = $this->createSampleSnapshot();

        Log::shouldReceive('channel')
            ->with('single')
            ->once()
            ->andReturnSelf();

        Log::shouldReceive('info')
            ->once()
            ->with('SynodDashboard.exported', \Mockery::on(function (array $payload) use ($snapshot) {
                return $payload['format'] === 'csv'
                    && $payload['snapshot_id'] === $snapshot->id
                    && $payload['user_id'] === $this->superAdmin->id;
            }));

        $response = $this->exportService->exportCsv($snapshot);

        $this->assertInstanceOf(StreamedResponse::class, $response);
        $this->assertSame('text/csv; charset=UTF-8', $response->headers->get('Content-Type'));

        // Capture in-memory stream output
        ob_start();
        $response->sendContent();
        $content = ob_get_clean();

        // 1. Verify UTF-8 BOM prefix (\xEF\xBB\xBF)
        $this->assertSame('efbbbf', bin2hex(substr($content, 0, 3)));

        // 2. Verify Header Section
        $this->assertStringContainsString('KANTOR PUSAT SINODE HKBP - LAPORAN EKSEKUTIF KONSOLIDASI', $content);
        $this->assertStringContainsString('Tanggal Periode', $content);

        // 3. Verify Executive Summary
        $this->assertStringContainsString('RINGKASAN EKSEKUTIF SINODE', $content);
        $this->assertStringContainsString('1 ditangguhkan (3 total)', $content);
        $this->assertStringContainsString('Rp 25.000.000,00', $content);

        // 4. Verify Module Adoption Matrix
        $this->assertStringContainsString('MATRIKS ADOPSI MODUL GEREJA AKTIF', $content);
        $this->assertStringContainsString('Manajemen Jemaat', $content);
        $this->assertStringContainsString('100,0%', $content);

        // 5. Verify Church Comparisons Rows
        $this->assertStringContainsString('MATRIKS KOMPARASI KONSOLIDASI SELURUH GEREJA', $content);
        $this->assertStringContainsString('HKBP Sudirman Active', $content);
        $this->assertStringContainsString('12/12', $content);
        $this->assertStringContainsString('Terkonfigurasi', $content);

        // Unprovisioned church distinction
        $this->assertStringContainsString('HKBP Bandung Active Unprovisioned', $content);
        $this->assertStringContainsString('Belum Dikonfigurasi', $content);
        $this->assertStringContainsString('—', $content);
    }

    public function test_export_handles_empty_snapshot_gracefully_without_crashing(): void
    {
        SynodReportSnapshot::query()->delete();

        // 1. Verify export actions are disabled when no snapshot exists
        Livewire::actingAs($this->superAdmin)
            ->test(SynodDashboard::class)
            ->assertActionDisabled('exportPdf')
            ->assertActionDisabled('exportCsv');

        // 2. Verify export actions become enabled once a snapshot exists
        $this->createSampleSnapshot();

        Livewire::actingAs($this->superAdmin)
            ->test(SynodDashboard::class)
            ->assertActionEnabled('exportPdf')
            ->assertActionEnabled('exportCsv');

        // 3. Defensive check: Service rejects null snapshot cleanly without 500/crash
        try {
            $this->exportService->exportPdf(null);
            $this->fail('Expected InvalidArgumentException was not thrown for PDF export');
        } catch (InvalidArgumentException $e) {
            $this->assertSame('Snapshot laporan sinode tidak boleh kosong.', $e->getMessage());
        }

        try {
            $this->exportService->exportCsv(null);
            $this->fail('Expected InvalidArgumentException was not thrown for CSV export');
        } catch (InvalidArgumentException $e) {
            $this->assertSame('Snapshot laporan sinode tidak boleh kosong.', $e->getMessage());
        }
    }

    public function test_export_performance_benchmark_on_100_churches_completes_under_two_seconds(): void
    {
        $this->actingAs($this->superAdmin);

        // Construct 100 mock church comparisons
        $comparisons = [];
        for ($i = 1; $i <= 100; $i++) {
            $isUnprov = $i % 15 === 0;
            $comparisons[] = [
                'id' => $i,
                'name' => "HKBP Ressort Distrik Test {$i}",
                'slug' => "hkbp-ressort-distrik-test-{$i}",
                'status' => $i % 10 === 0 ? 'suspended' : 'active',
                'member_count' => rand(50, 1200),
                'active_modules_count' => $isUnprov ? 0 : rand(6, 12),
                'total_modules_provisioned' => $isUnprov ? 0 : 12,
                'provisioning_status' => $isUnprov ? 'unprovisioned' : 'provisioned',
                'total_donations' => (float) rand(5000000, 150000000),
            ];
        }

        // Construct 12 modules adoption
        $modules = [];
        for ($m = 1; $m <= 12; $m++) {
            $modules[] = [
                'key' => "module_{$m}",
                'name' => "Modul Pelayanan {$m}",
                'is_core' => $m <= 5,
                'active_count' => rand(70, 90),
                'total_active_churches' => 90,
                'adoption_percentage' => round(rand(700, 1000) / 10, 1),
            ];
        }

        $largeSnapshot = SynodReportSnapshot::create([
            'generated_by_user_id' => $this->superAdmin->id,
            'period_date' => now()->toDateString(),
            'total_churches' => 100,
            'active_churches' => 90,
            'suspended_churches' => 10,
            'total_active_members' => 45000,
            'total_all_members' => 50000,
            'total_active_donations' => 750000000.00,
            'total_all_donations' => 820000000.00,
            'total_active_sacraments' => 1200,
            'total_all_sacraments' => 1350,
            'church_comparisons' => $comparisons,
            'module_adoption' => $modules,
        ]);

        // Measure CSV generation
        $csvStart = microtime(true);
        $csvResponse = $this->exportService->exportCsv($largeSnapshot);
        ob_start();
        $csvResponse->sendContent();
        $csvContent = ob_get_clean();
        $csvDurationMs = (microtime(true) - $csvStart) * 1000;

        // Measure PDF generation
        $pdfStart = microtime(true);
        $pdfResponse = $this->exportService->exportPdf($largeSnapshot);
        ob_start();
        $pdfResponse->sendContent();
        $pdfContent = ob_get_clean();
        $pdfDurationMs = (microtime(true) - $pdfStart) * 1000;

        $totalDurationMs = $csvDurationMs + $pdfDurationMs;

        // Assert CSV is populated and benchmarked (<100ms)
        $this->assertNotEmpty($csvContent);
        $this->assertLessThan(100, $csvDurationMs, "CSV generation for 100 churches exceeded 100ms: {$csvDurationMs}ms");

        // Assert PDF is valid binary and renders within synchronous budget (<2000ms)
        $this->assertStringStartsWith('%PDF-', $pdfContent);
        $this->assertLessThan(2000, $pdfDurationMs, "PDF generation for 100 churches exceeded 2000ms: {$pdfDurationMs}ms");

        // Combined duration strictly under 2000ms
        $this->assertLessThan(2000, $totalDurationMs, "Total export benchmark exceeded 2000ms: {$totalDurationMs}ms");
    }

    public function test_non_super_admin_cannot_access_synod_export(): void
    {
        $this->actingAs($this->churchAdmin);

        $this->assertFalse(SynodDashboard::canAccess());
    }
}
