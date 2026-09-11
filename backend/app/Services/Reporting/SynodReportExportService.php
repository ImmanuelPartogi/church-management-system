<?php

namespace App\Services\Reporting;

use App\Models\SynodReportSnapshot;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Support\Facades\Log;
use InvalidArgumentException;
use Symfony\Component\HttpFoundation\StreamedResponse;

class SynodReportExportService
{
    /**
     * Export the synod report snapshot as an official PDF document via in-memory streaming.
     *
     * Zero disk footprint: The PDF binary is rendered entirely in RAM and streamed directly to the client.
     */
    public function exportPdf(?SynodReportSnapshot $snapshot): StreamedResponse
    {
        if (! $snapshot) {
            throw new InvalidArgumentException('Snapshot laporan sinode tidak boleh kosong.');
        }

        $this->logExportAudit($snapshot, 'pdf');

        $originalMemoryLimit = ini_get('memory_limit');
        $originalBytes = $this->parseIniSize($originalMemoryLimit);
        $needsElevation = $originalBytes !== -1 && $originalBytes < 268435456; // 256 MB in bytes

        if ($needsElevation) {
            @ini_set('memory_limit', '256M');
        }

        try {
            $pdf = Pdf::loadView('reports.synod-snapshot-pdf', [
                'snapshot' => $snapshot,
            ])
                ->setPaper('a4', 'portrait')
                ->setOptions([
                    'isHtml5ParserEnabled' => false,
                    'enable_font_subsetting' => false,
                    'isRemoteEnabled' => false,
                    'defaultFont' => 'Helvetica',
                ]);

            $pdfOutput = $pdf->output();
        } finally {
            if ($needsElevation) {
                @ini_set('memory_limit', $originalMemoryLimit);
            }
        }
        $dateSlug = $snapshot->period_date ? $snapshot->period_date->format('Y-m-d') : now()->format('Y-m-d');
        $fileName = "laporan-konsolidasi-sinode-{$dateSlug}.pdf";

        return response()->streamDownload(function () use ($pdfOutput): void {
            echo $pdfOutput;
        }, $fileName, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => "attachment; filename=\"{$fileName}\"",
        ]);
    }

    /**
     * Export the synod report snapshot as a spreadsheet-compatible CSV via in-memory streaming.
     *
     * Zero disk footprint: Uses php://temp in-memory buffer with UTF-8 BOM for Microsoft Excel compatibility.
     */
    public function exportCsv(?SynodReportSnapshot $snapshot): StreamedResponse
    {
        if (! $snapshot) {
            throw new InvalidArgumentException('Snapshot laporan sinode tidak boleh kosong.');
        }

        $this->logExportAudit($snapshot, 'csv');

        $dateSlug = $snapshot->period_date ? $snapshot->period_date->format('Y-m-d') : now()->format('Y-m-d');
        $fileName = "laporan-konsolidasi-sinode-{$dateSlug}.csv";

        return response()->streamDownload(function () use ($snapshot): void {
            $stream = fopen('php://temp', 'r+');

            // UTF-8 BOM for automatic character encoding detection in Microsoft Excel & Numbers
            fwrite($stream, "\xEF\xBB\xBF");

            // Header Section: Metadata
            fputcsv($stream, ['KANTOR PUSAT SINODE HKBP - LAPORAN EKSEKUTIF KONSOLIDASI'], escape: '\\');
            fputcsv($stream, ['Tanggal Periode', $snapshot->period_date ? $snapshot->period_date->format('d/m/Y') : '-'], escape: '\\');
            fputcsv($stream, ['Tanggal Unduh', now()->format('d/m/Y H:i:s')], escape: '\\');
            fputcsv($stream, ['Digenerate Oleh', $snapshot->generatedBy?->name ?? 'System (Scheduler)'], escape: '\\');
            fputcsv($stream, [], escape: '\\');

            // Section 1: Ringkasan Eksekutif Sinode
            fputcsv($stream, ['RINGKASAN EKSEKUTIF SINODE'], escape: '\\');
            fputcsv($stream, ['Indikator', 'Gereja Aktif', 'Gereja Ditangguhkan / Total', 'Catatan Definisi'], escape: '\\');
            fputcsv($stream, [
                'Total Gereja Terdaftar',
                $snapshot->active_churches,
                $snapshot->suspended_churches.' ditangguhkan ('.$snapshot->total_churches.' total)',
                'Hanya gereja berstatus aktif yang melayani jemaat aktif',
            ], escape: '\\');
            fputcsv($stream, [
                'Total Anggota Jemaat',
                number_format($snapshot->total_active_members),
                number_format($snapshot->total_all_members).' total jemaat',
                'Hanya jemaat pada gereja aktif dihitung pada kolom operasional',
            ], escape: '\\');
            fputcsv($stream, [
                'Total Persembahan (Approved)',
                'Rp '.number_format((float) $snapshot->total_active_donations, 2, ',', '.'),
                'Rp '.number_format((float) $snapshot->total_all_donations, 2, ',', '.').' total',
                'Akumulasi donasi konfirmasi dengan status approved',
            ], escape: '\\');
            fputcsv($stream, [
                'Total Pelayanan Sakramen',
                number_format($snapshot->total_active_sacraments),
                number_format($snapshot->total_all_sacraments).' total pendaftaran',
                'Pendaftaran sakramen & administrasi gereja aktif',
            ], escape: '\\');
            fputcsv($stream, [], escape: '\\');

            // Section 2: Matriks Adopsi Modul
            fputcsv($stream, ['MATRIKS ADOPSI MODUL GEREJA AKTIF'], escape: '\\');
            fputcsv($stream, ['Key Modul', 'Nama Modul', 'Klasifikasi', 'Gereja Mengaktifkan', 'Total Gereja Aktif', 'Tingkat Adopsi (%)'], escape: '\\');
            foreach ($snapshot->module_adoption ?? [] as $module) {
                fputcsv($stream, [
                    $module['key'] ?? '',
                    $module['name'] ?? '',
                    ($module['is_core'] ?? false) ? 'Core' : 'Optional',
                    $module['active_count'] ?? 0,
                    $module['total_active_churches'] ?? 0,
                    number_format((float) ($module['adoption_percentage'] ?? 0), 1, ',', '.').'%',
                ], escape: '\\');
            }
            fputcsv($stream, [], escape: '\\');

            // Section 3: Matriks Komparasi Antar Gereja
            fputcsv($stream, ['MATRIKS KOMPARASI KONSOLIDASI SELURUH GEREJA'], escape: '\\');
            fputcsv($stream, ['No', 'Nama Gereja', 'Status Akun', 'Status Konfigurasi', 'Modul Aktif', 'Total Jemaat', 'Total Persembahan (Rp)'], escape: '\\');
            foreach ($snapshot->church_comparisons ?? [] as $idx => $church) {
                $modulesRatio = ($church['provisioning_status'] ?? '') === 'unprovisioned'
                    ? '—'
                    : ($church['active_modules_count'] ?? 0).'/'.($church['total_modules_provisioned'] ?? 12);

                $provisioningLabel = ($church['provisioning_status'] ?? '') === 'unprovisioned'
                    ? 'Belum Dikonfigurasi'
                    : 'Terkonfigurasi';

                fputcsv($stream, [
                    $idx + 1,
                    $church['name'] ?? '',
                    strtoupper($church['status'] ?? ''),
                    $provisioningLabel,
                    $modulesRatio,
                    $church['member_count'] ?? 0,
                    number_format((float) ($church['total_donations'] ?? 0), 2, ',', '.'),
                ], escape: '\\');
            }

            rewind($stream);
            fpassthru($stream);
            fclose($stream);
        }, $fileName, [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => "attachment; filename=\"{$fileName}\"",
        ]);
    }

    /**
     * Record an access audit log for an initiated synod report snapshot export download.
     *
     * Semantics: Records the authorization and initiation of data extraction by the Super Admin.
     * Note: This audit entry confirms that export generation and stream dispatch were authorized
     * and initiated; it does not guarantee client-side file persistence if the connection terminates mid-transfer.
     */
    protected function logExportAudit(SynodReportSnapshot $snapshot, string $format): void
    {
        Log::channel('single')->info('SynodDashboard.exported', [
            'user_id' => auth()->id(),
            'user_email' => auth()->user()?->email,
            'ip' => request()->ip(),
            'format' => $format,
            'snapshot_id' => $snapshot->id,
            'period_date' => $snapshot->period_date?->toDateString(),
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    /**
     * Parse a PHP ini memory string (e.g., '128M', '1G', '-1') into bytes.
     */
    protected function parseIniSize(string $value): int
    {
        $value = trim($value);
        if ($value === '-1') {
            return -1;
        }

        $last = strtolower($value[strlen($value) - 1]);
        $val = (int) $value;

        return match ($last) {
            'g' => $val * 1024 * 1024 * 1024,
            'm' => $val * 1024 * 1024,
            'k' => $val * 1024,
            default => $val,
        };
    }
}
