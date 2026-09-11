<?php

namespace App\Services\Reporting;

use App\Enums\DonationStatus;
use App\Models\DonationConfirmation;
use App\Models\User;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\StreamedResponse;

class MemberDonationExportService
{
    /**
     * Export official Statement of Giving (Surat Rekapitulasi Persembahan) as PDF.
     *
     * Architectural Guarantee:
     * HARDCODED to DonationStatus::Approved. Unverified (pending) or rejected donations
     * are strictly excluded to preserve official tax and legal giving certificate integrity.
     */
    public function exportPdf(User $user, array $filters = []): StreamedResponse
    {
        $this->logExportAudit($user, 'pdf');

        // 1. Strict Query: forMember scoped + hardcoded Approved
        $query = DonationConfirmation::forMember($user)
            ->with(['chartOfAccount'])
            ->where('status', DonationStatus::Approved);

        if (! empty($filters['start_date'])) {
            $query->whereDate('transfer_date', '>=', $filters['start_date']);
        }
        if (! empty($filters['end_date'])) {
            $query->whereDate('transfer_date', '<=', $filters['end_date']);
        }
        if (! empty($filters['chart_of_account_id'])) {
            $query->where('chart_of_account_id', $filters['chart_of_account_id']);
        }

        $donations = $query->orderBy('transfer_date', 'asc')->orderBy('id', 'asc')->get();

        // 2. Aggregate category breakdown & grand total
        $categoryBreakdown = $donations->groupBy('chart_of_account_id')->map(function ($items) {
            return [
                'name' => $items->first()->chartOfAccount?->name ?? 'Persembahan Umum',
                'code' => $items->first()->chartOfAccount?->code ?? '-',
                'count' => $items->count(),
                'total' => (float) $items->sum('amount'),
            ];
        })->values();

        $totalAmount = (float) $donations->sum('amount');

        // 3. Resolve Church context & Member fallback
        $church = app()->bound('current_church') ? app('current_church') : null;
        $member = $user->member;
        $donorName = $member?->full_name ?: $user->name;
        $membershipNumber = $member?->membership_number ?: '-';
        $donorPhone = $member?->phone ?: ($user->phone ?: '-');
        $donorEmail = $user->email;
        $donorStatus = $member ? 'Anggota Jemaat' : 'Jemaat Simpatisan / Mandiri';

        // 4. Period Label
        $startDate = $filters['start_date'] ?? null;
        $endDate = $filters['end_date'] ?? null;
        if ($startDate && $endDate) {
            $periodLabel = Carbon::parse($startDate)->isoFormat('D MMMM Y').' s/d '.Carbon::parse($endDate)->isoFormat('D MMMM Y');
        } elseif ($startDate) {
            $periodLabel = 'Sejak '.Carbon::parse($startDate)->isoFormat('D MMMM Y');
        } elseif ($endDate) {
            $periodLabel = 'Sampai '.Carbon::parse($endDate)->isoFormat('D MMMM Y');
        } else {
            $periodLabel = 'Seluruh Riwayat (Semua Periode)';
        }

        $documentNumber = 'SOG-'.date('Ymd').'-'.strtoupper(Str::random(6));

        // 5. Memory Elevation Guard (Phase 8 pattern)
        $originalMemoryLimit = ini_get('memory_limit');
        $originalBytes = $this->parseIniSize($originalMemoryLimit);
        $needsElevation = $originalBytes !== -1 && $originalBytes < 268435456; // 256 MB in bytes

        if ($needsElevation) {
            @ini_set('memory_limit', '256M');
        }

        try {
            $pdf = Pdf::loadView('reports.member-statement-of-giving-pdf', [
                'church' => $church,
                'user' => $user,
                'member' => $member,
                'donorName' => $donorName,
                'membershipNumber' => $membershipNumber,
                'donorPhone' => $donorPhone,
                'donorEmail' => $donorEmail,
                'donorStatus' => $donorStatus,
                'periodLabel' => $periodLabel,
                'documentNumber' => $documentNumber,
                'donations' => $donations,
                'categoryBreakdown' => $categoryBreakdown,
                'totalAmount' => $totalAmount,
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

        $sanitizedName = Str::slug($donorName) ?: 'jemaat';
        $dateSlug = now()->format('Ymd');
        $fileName = "rekap-persembahan-{$sanitizedName}-{$dateSlug}.pdf";

        return response()->streamDownload(function () use ($pdfOutput): void {
            echo $pdfOutput;
        }, $fileName, [
            'Content-Type' => 'application/pdf',
            'Content-Disposition' => "attachment; filename=\"{$fileName}\"",
        ]);
    }

    /**
     * Export personal donation history as spreadsheet-compatible CSV via in-memory streaming.
     *
     * Zero disk footprint: Uses php://temp in-memory buffer with UTF-8 BOM for Microsoft Excel & Numbers compatibility.
     * Supports flexible status filtering for member's personal bookkeeping / reconciliation.
     */
    public function exportCsv(User $user, array $filters = []): StreamedResponse
    {
        $this->logExportAudit($user, 'csv');

        $query = DonationConfirmation::forMember($user)
            ->with(['chartOfAccount']);

        if (! empty($filters['status']) && $filters['status'] !== 'all') {
            $query->where('status', $filters['status']);
        }
        if (! empty($filters['start_date'])) {
            $query->whereDate('transfer_date', '>=', $filters['start_date']);
        }
        if (! empty($filters['end_date'])) {
            $query->whereDate('transfer_date', '<=', $filters['end_date']);
        }
        if (! empty($filters['chart_of_account_id'])) {
            $query->where('chart_of_account_id', $filters['chart_of_account_id']);
        }

        $donations = $query->orderBy('transfer_date', 'desc')->orderBy('id', 'desc')->get();

        $church = app()->bound('current_church') ? app('current_church') : null;
        $member = $user->member;
        $donorName = $member?->full_name ?: $user->name;
        $sanitizedName = Str::slug($donorName) ?: 'jemaat';
        $dateSlug = now()->format('Ymd');
        $fileName = "riwayat-persembahan-{$sanitizedName}-{$dateSlug}.csv";

        return response()->streamDownload(function () use ($donations, $church, $donorName): void {
            $stream = fopen('php://temp', 'r+');

            // UTF-8 BOM for automatic character encoding detection in Microsoft Excel & Numbers
            fwrite($stream, "\xEF\xBB\xBF");

            // Header Section: Metadata
            fputcsv($stream, ['BUKU PEMBANTU RIWAYAT PERSEMBAHAN JEMAAT'], escape: '\\');
            fputcsv($stream, ['Gereja', $church?->name ?? '-'], escape: '\\');
            fputcsv($stream, ['Nama Jemaat', $donorName], escape: '\\');
            fputcsv($stream, ['Tanggal Ekspor', now()->format('d/m/Y H:i:s')], escape: '\\');
            fputcsv($stream, [], escape: '\\');

            // Column Headers
            fputcsv($stream, [
                'No',
                'No. Donasi',
                'Tanggal Transfer',
                'Pos Persembahan',
                'Nominal (Rp)',
                'Bank Pengirim',
                'Status',
                'Catatan',
                'Alasan Penolakan',
            ], escape: '\\');

            foreach ($donations as $index => $item) {
                $statusLabel = match ($item->status) {
                    DonationStatus::Approved, 'approved' => 'Disetujui',
                    DonationStatus::Pending, 'pending' => 'Menunggu Verifikasi',
                    DonationStatus::Rejected, 'rejected' => 'Ditolak',
                    default => (string) $item->status,
                };

                fputcsv($stream, [
                    $index + 1,
                    $item->donation_number,
                    $item->transfer_date ? $item->transfer_date->format('d/m/Y') : '-',
                    $item->chartOfAccount?->name ?? 'Persembahan Umum',
                    number_format((float) $item->amount, 0, ',', '.'),
                    $item->sender_bank,
                    $statusLabel,
                    $item->notes ?? '',
                    $item->rejection_reason ?? '',
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
     * Record an audit log for an initiated personal donation export download.
     */
    protected function logExportAudit(User $user, string $format): void
    {
        Log::channel('single')->info('MemberDonation.exported', [
            'user_id' => $user->id,
            'user_email' => $user->email,
            'ip' => request()->ip(),
            'format' => $format,
            'church_id' => app()->bound('current_church_id') ? app('current_church_id') : null,
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
