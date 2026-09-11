<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Surat Rekapitulasi Persembahan - {{ $donorName }}</title>
    <style>
        @page {
            margin: 15mm 12mm 18mm 12mm;
            size: a4 portrait;
        }

        * {
            box-sizing: border-box;
        }

        body {
            font-family: Helvetica, Arial, sans-serif;
            font-size: 8.5pt;
            color: #1e293b;
            line-height: 1.35;
            margin: 0;
            padding: 0;
        }

        .header-container {
            border-bottom: 2px solid #0f172a;
            padding-bottom: 8px;
            margin-bottom: 12px;
        }

        .church-title {
            font-size: 13pt;
            font-weight: bold;
            color: #0f172a;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin: 0;
        }

        .church-meta {
            font-size: 8pt;
            color: #475569;
            margin: 2px 0 0 0;
        }

        .doc-title-container {
            text-align: center;
            margin: 10px 0 14px 0;
        }

        .doc-title {
            font-size: 11pt;
            font-weight: bold;
            color: #0f172a;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin: 0;
        }

        .doc-subtitle {
            font-size: 8pt;
            color: #64748b;
            margin: 2px 0 0 0;
            font-style: italic;
        }

        .doc-number {
            font-size: 8pt;
            color: #334155;
            margin-top: 3px;
            font-weight: bold;
        }

        .info-card {
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 4px;
            padding: 8px 10px;
            margin-bottom: 12px;
        }

        .info-table {
            width: 100%;
            font-size: 8pt;
        }

        .info-table td {
            padding: 2px 4px;
            vertical-align: top;
        }

        .info-label {
            width: 22%;
            font-weight: bold;
            color: #475569;
        }

        .info-val {
            color: #0f172a;
        }

        .section-title {
            font-size: 9pt;
            font-weight: bold;
            color: #0f172a;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            border-bottom: 1px solid #cbd5e1;
            padding-bottom: 3px;
            margin: 12px 0 6px 0;
        }

        table.data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 8pt;
            margin-bottom: 10px;
        }

        table.data-table th {
            background-color: #f1f5f9;
            color: #0f172a;
            font-weight: bold;
            text-align: left;
            padding: 5px 6px;
            border-top: 1px solid #cbd5e1;
            border-bottom: 1.5px solid #0f172a;
        }

        table.data-table td {
            padding: 4px 6px;
            border-bottom: 1px solid #e2e8f0;
            color: #1e293b;
        }

        table.data-table tr.even {
            background-color: #f8fafc;
        }

        .text-right {
            text-align: right;
        }

        .text-center {
            text-align: center;
        }

        .empty-callout {
            background-color: #fffbeb;
            border: 1px solid #fef3c7;
            border-left: 4px solid #f59e0b;
            padding: 10px 12px;
            color: #92400e;
            margin: 10px 0;
            border-radius: 3px;
            font-size: 8.5pt;
        }

        .summary-box {
            background-color: #f8fafc;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            padding: 8px 12px;
            margin-top: 10px;
        }

        .total-row {
            font-size: 9.5pt;
            font-weight: bold;
            color: #0f172a;
        }

        .footer-notice {
            font-size: 7.5pt;
            color: #64748b;
            margin-top: 14px;
            padding-top: 6px;
            border-top: 1px dashed #cbd5e1;
            line-height: 1.3;
        }

        .signature-table {
            width: 100%;
            margin-top: 20px;
            font-size: 8pt;
        }

        .signature-table td {
            width: 50%;
            text-align: center;
            vertical-align: top;
        }

        .signature-space {
            height: 45px;
        }

        .signature-name {
            font-weight: bold;
            color: #0f172a;
            text-decoration: underline;
        }

        .signature-role {
            color: #475569;
            font-size: 7.5pt;
        }
    </style>
</head>
<body>
    {{-- Kop Surat Gereja Lokal --}}
    <div class="header-container">
        <div class="church-title">{{ $church?->name ?? 'GEREJA' }}</div>
        <div class="church-meta">
            @if($church?->address)
                {{ $church->address }} |
            @endif
            @if($church?->phone)
                Telp: {{ $church->phone }} |
            @endif
            @if($church?->email)
                Email: {{ $church->email }}
            @endif
        </div>
    </div>

    {{-- Judul Dokumen Resmi --}}
    <div class="doc-title-container">
        <div class="doc-title">Surat Rekapitulasi Persembahan Jemaat</div>
        <div class="doc-subtitle">Official Statement of Giving &bull; Tanda Terima Sah Persembahan</div>
        <div class="doc-number">No. Dokumen: {{ $documentNumber }}</div>
    </div>

    {{-- Kartu Identitas Jemaat & Parameter Rekapitulasi --}}
    <div class="info-card">
        <table class="info-table">
            <tr>
                <td class="info-label">Nama Jemaat:</td>
                <td class="info-val"><strong>{{ $donorName }}</strong></td>
                <td class="info-label">Periode Rekap:</td>
                <td class="info-val">{{ $periodLabel }}</td>
            </tr>
            <tr>
                <td class="info-label">No. Induk Jemaat:</td>
                <td class="info-val">{{ $membershipNumber }}</td>
                <td class="info-label">Tanggal Cetak:</td>
                <td class="info-val">{{ \Carbon\Carbon::now()->isoFormat('D MMMM Y, HH:mm') }} WIB</td>
            </tr>
            <tr>
                <td class="info-label">Status Keanggotaan:</td>
                <td class="info-val">{{ $donorStatus }}</td>
                <td class="info-label">Gereja Terafiliasi:</td>
                <td class="info-val">{{ $church?->name ?? '-' }}</td>
            </tr>
            <tr>
                <td class="info-label">Kontak / Email:</td>
                <td class="info-val">{{ $donorPhone }} / {{ $donorEmail }}</td>
                <td class="info-label">Status Verifikasi:</td>
                <td class="info-val" style="color: #166534; font-weight: bold;">Telah Diverifikasi (Approved Only)</td>
            </tr>
        </table>
    </div>

    {{-- Rincian Transaksi Persembahan --}}
    <div class="section-title">1. Rincian Persembahan Terverifikasi</div>

    @if($donations->isEmpty())
        <div class="empty-callout">
            <strong>Pemberitahuan:</strong> Tidak ada persembahan tercatat pada periode ini.
        </div>
    @else
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width: 5%;" class="text-center">No</th>
                    <th style="width: 22%;">No. Referensi</th>
                    <th style="width: 14%;">Tanggal</th>
                    <th style="width: 25%;">Pos Persembahan</th>
                    <th style="width: 14%;">Bank Pengirim</th>
                    <th style="width: 20%;" class="text-right">Nominal (Rp)</th>
                </tr>
            </thead>
            <tbody>
                @foreach($donations as $index => $item)
                    <tr class="{{ $index % 2 === 1 ? 'even' : '' }}">
                        <td class="text-center">{{ $index + 1 }}</td>
                        <td style="font-family: monospace; font-size: 7.5pt;">{{ $item->donation_number }}</td>
                        <td>{{ $item->transfer_date ? $item->transfer_date->format('d/m/Y') : '-' }}</td>
                        <td>{{ $item->chartOfAccount?->name ?? 'Persembahan Umum' }}</td>
                        <td>{{ $item->sender_bank }}</td>
                        <td class="text-right">{{ number_format((float) $item->amount, 0, ',', '.') }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    @endif

    {{-- Ringkasan per Pos Rekening COA --}}
    <div class="section-title">2. Rekapitulasi per Pos Persembahan</div>
    <table class="data-table">
        <thead>
            <tr>
                <th style="width: 8%;" class="text-center">No</th>
                <th style="width: 52%;">Nama Pos Rekening / Kategori</th>
                <th style="width: 15%;" class="text-center">Frekuensi</th>
                <th style="width: 25%;" class="text-right">Jumlah Total (Rp)</th>
            </tr>
        </thead>
        <tbody>
            @forelse($categoryBreakdown as $cIdx => $cat)
                <tr class="{{ $cIdx % 2 === 1 ? 'even' : '' }}">
                    <td class="text-center">{{ $cIdx + 1 }}</td>
                    <td>{{ $cat['name'] }} @if(!empty($cat['code']) && $cat['code'] !== '-') ({{ $cat['code'] }}) @endif</td>
                    <td class="text-center">{{ $cat['count'] }} kali</td>
                    <td class="text-right">{{ number_format($cat['total'], 0, ',', '.') }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="4" class="text-center" style="color: #64748b; font-style: italic; padding: 6px;">
                        Tidak ada data pos persembahan.
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>

    {{-- Grand Total Box --}}
    <div class="summary-box">
        <table style="width: 100%;">
            <tr class="total-row">
                <td style="width: 60%;">TOTAL PERSEMBAHAN TERVERIFIKASI:</td>
                <td style="width: 40%; text-align: right; color: #166534; font-size: 11pt;">
                    Rp {{ number_format($totalAmount, 0, ',', '.') }}
                </td>
            </tr>
        </table>
    </div>

    {{-- Klausul Legal & Tanda Tangan --}}
    <div class="footer-notice">
        <strong>Pernyataan Hukum:</strong> Dokumen ini merupakan tanda terima sah persembahan jemaat yang tercatat dan terverifikasi secara resmi dalam Sistem Administrasi & Manajemen Keuangan Gereja {{ $church?->name ?? '' }}. Diterbitkan secara elektronik dan sah tanpa memerlukan cap basah, sesuai dengan catatan pembukuan perbendaharaan gereja.
    </div>

    <table class="signature-table">
        <tr>
            <td>
                Mengetahui,<br>
                <strong>Perbendaharaan / Majelis Keuangan</strong>
                <div class="signature-space"></div>
                <div class="signature-name">( Bendahara Gereja )</div>
                <div class="signature-role">{{ $church?->name ?? 'Gereja' }}</div>
            </td>
            <td>
                Diverifikasi di {{ $church?->name ?? 'Gereja' }},<br>
                <strong>Pimpinan Jemaat</strong>
                <div class="signature-space"></div>
                <div class="signature-name">( Pendeta Jemaat )</div>
                <div class="signature-role">Konteks Wilayah Pelayanan</div>
            </td>
        </tr>
    </table>
</body>
</html>
