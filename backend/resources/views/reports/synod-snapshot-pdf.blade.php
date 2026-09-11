<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Laporan Konsolidasi Sinode - {{ $snapshot->period_date ? $snapshot->period_date->format('d/m/Y') : '-' }}</title>
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

        .header-title {
            font-size: 14pt;
            font-weight: bold;
            color: #0f172a;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin: 0;
        }

        .header-subtitle {
            font-size: 9pt;
            color: #475569;
            margin: 2px 0 0 0;
            font-weight: normal;
        }

        .meta-table {
            width: 100%;
            margin-top: 6px;
            font-size: 8pt;
            color: #334155;
        }

        .meta-table td {
            padding: 1px 0;
        }

        .meta-label {
            font-weight: bold;
            color: #64748b;
            width: 15%;
        }

        .section-title {
            font-size: 9.5pt;
            font-weight: bold;
            color: #0f172a;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            border-bottom: 1px solid #cbd5e1;
            padding-bottom: 3px;
            margin-top: 14px;
            margin-bottom: 8px;
        }

        /* Metric Cards Grid */
        .metrics-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 6px;
            margin-bottom: 10px;
        }

        .metric-card {
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
            padding: 8px;
            vertical-align: top;
            width: 25%;
        }

        .metric-label {
            font-size: 7.5pt;
            font-weight: bold;
            color: #64748b;
            text-transform: uppercase;
            margin-bottom: 4px;
        }

        .metric-value {
            font-size: 13pt;
            font-weight: bold;
            color: #0f172a;
            line-height: 1.1;
        }

        .metric-sub {
            font-size: 7pt;
            color: #64748b;
            margin-top: 3px;
        }

        /* Data Tables */
        .data-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            border-top: 1px solid #cbd5e1;
            border-left: 1px solid #cbd5e1;
            font-size: 8pt;
            margin-bottom: 10px;
        }

        .data-table th {
            background-color: #f1f5f9;
            color: #1e293b;
            font-weight: bold;
            text-align: left;
            padding: 5px 6px;
            border-right: 1px solid #cbd5e1;
            border-bottom: 1px solid #cbd5e1;
            font-size: 7.5pt;
            text-transform: uppercase;
        }

        .data-table td {
            padding: 4px 6px;
            border-right: 1px solid #e2e8f0;
            border-bottom: 1px solid #e2e8f0;
            vertical-align: middle;
        }

        .data-table tr:nth-child(even) td {
            background-color: #f8fafc;
        }

        .text-center {
            text-align: center;
        }

        .text-right {
            text-align: right;
        }

        .badge {
            display: inline-block;
            padding: 1px 4px;
            font-size: 6.5pt;
            font-weight: bold;
            text-transform: uppercase;
        }

        .badge-active {
            background-color: #dcfce7;
            color: #166534;
        }

        .badge-suspended {
            background-color: #fee2e2;
            color: #991b1b;
        }

        .badge-provisioned {
            background-color: #e0f2fe;
            color: #0369a1;
        }

        .badge-unprovisioned {
            background-color: #fef3c7;
            color: #92400e;
        }

        .badge-core {
            background-color: #f1f5f9;
            color: #334155;
            border: 1px solid #cbd5e1;
        }


        .page-break {
            page-break-after: always;
        }

        .footer {
            position: fixed;
            bottom: -10mm;
            left: 0;
            right: 0;
            font-size: 7pt;
            color: #94a3b8;
            border-top: 1px solid #e2e8f0;
            padding-top: 4px;
            display: flex;
            justify-content: space-between;
        }
    </style>
</head>
<body>
    <div class="footer">
        <span>KANTOR PUSAT SINODE HKBP &bull; DOKUMEN INTERNAL RAHASIA</span>
        <span style="float: right;">Snapshot ID: #{{ $snapshot->id }} &bull; Dicetak: {{ now()->format('d/m/Y H:i') }} WIB</span>
    </div>

    <!-- Header Section -->
    <div class="header-container">
        <h1 class="header-title">Kantor Pusat Sinode HKBP</h1>
        <h2 class="header-subtitle">Laporan Eksekutif Konsolidasi Sinode &amp; Status Adopsi Sistem</h2>
        <table class="meta-table">
            <tr>
                <td class="meta-label">Periode Laporan:</td>
                <td>{{ $snapshot->period_date ? $snapshot->period_date->translatedFormat('d F Y') : '-' }}</td>
                <td class="meta-label">Digenerate Oleh:</td>
                <td>{{ $snapshot->generatedBy?->name ?? 'System (Scheduler)' }}</td>
            </tr>
            <tr>
                <td class="meta-label">Waktu Snapshot:</td>
                <td>{{ $snapshot->created_at ? $snapshot->created_at->format('d/m/Y H:i:s') : '-' }} WIB</td>
                <td class="meta-label">Status Dokumen:</td>
                <td><strong>RESMI / TERTUTUP</strong></td>
            </tr>
        </table>
    </div>

    <!-- Section 1: Executive Summary Metrics -->
    <div class="section-title">1. Ringkasan Eksekutif Sinode</div>
    <table class="metrics-table">
        <tr>
            <td class="metric-card">
                <div class="metric-label">Gereja Terdaftar</div>
                <div class="metric-value">{{ $snapshot->active_churches }} <span style="font-size: 8pt; font-weight: normal; color: #166534;">Aktif</span></div>
                <div class="metric-sub">{{ $snapshot->suspended_churches }} suspended &bull; {{ $snapshot->total_churches }} total</div>
            </td>
            <td class="metric-card">
                <div class="metric-label">Total Anggota Jemaat</div>
                <div class="metric-value">{{ number_format($snapshot->total_active_members) }}</div>
                <div class="metric-sub">{{ number_format($snapshot->total_all_members) }} total (termasuk non-aktif)</div>
            </td>
            <td class="metric-card">
                <div class="metric-label">Persembahan (Approved)</div>
                <div class="metric-value" style="font-size: 11pt;">Rp {{ number_format((float) $snapshot->total_active_donations, 0, ',', '.') }}</div>
                <div class="metric-sub">Total: Rp {{ number_format((float) $snapshot->total_all_donations, 0, ',', '.') }}</div>
            </td>
            <td class="metric-card">
                <div class="metric-label">Pelayanan Sakramen</div>
                <div class="metric-value">{{ number_format($snapshot->total_active_sacraments) }}</div>
                <div class="metric-sub">{{ number_format($snapshot->total_all_sacraments) }} total pendaftaran</div>
            </td>
        </tr>
    </table>

    <!-- Section 2: Module Adoption Matrix -->
    <div class="section-title">2. Matriks Adopsi Modul Gereja Aktif ({{ $snapshot->active_churches }} Gereja Aktif)</div>
    <table class="data-table">
        <thead>
            <tr>
                <th style="width: 5%;" class="text-center">No</th>
                <th style="width: 30%;">Nama Modul</th>
                <th style="width: 15%;">Key Modul</th>
                <th style="width: 12%;" class="text-center">Kategori</th>
                <th style="width: 18%;" class="text-center">Gereja Mengaktifkan</th>
                <th style="width: 20%;" class="text-right">Tingkat Adopsi</th>
            </tr>
        </thead>
        <tbody>
            @forelse($snapshot->module_adoption ?? [] as $index => $module)
                @php
                    $pct = (float) ($module['adoption_percentage'] ?? 0);
                @endphp
                <tr>
                    <td class="text-center">{{ $index + 1 }}</td>
                    <td><strong>{{ $module['name'] ?? '-' }}</strong></td>
                    <td><code>{{ $module['key'] ?? '-' }}</code></td>
                    <td class="text-center">
                        <span class="badge badge-core">{{ ($module['is_core'] ?? false) ? 'Core' : 'Optional' }}</span>
                    </td>
                    <td class="text-center">
                        {{ $module['active_count'] ?? 0 }} / {{ $module['total_active_churches'] ?? 0 }}
                    </td>
                    <td class="text-right">
                        <strong>{{ number_format($pct, 1, ',', '.') }}%</strong>
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="6" class="text-center" style="color: #64748b; padding: 10px;">Tidak ada data adopsi modul.</td>
                </tr>
            @endforelse
        </tbody>
    </table>

    <!-- Section 3: Church Comparisons -->
    <div class="section-title">3. Matriks Komparasi Konsolidasi Seluruh Gereja ({{ count($snapshot->church_comparisons ?? []) }} Terdaftar)</div>
    <table class="data-table">
        <thead>
            <tr>
                <th style="width: 4%;" class="text-center">No</th>
                <th style="width: 32%;">Nama Gereja</th>
                <th style="width: 10%;" class="text-center">Status</th>
                <th style="width: 18%;" class="text-center">Konfigurasi Modul</th>
                <th style="width: 10%;" class="text-center">Modul Aktif</th>
                <th style="width: 10%;" class="text-right">Jemaat</th>
                <th style="width: 16%;" class="text-right">Persembahan (Rp)</th>
            </tr>
        </thead>
        <tbody>
            @forelse($snapshot->church_comparisons ?? [] as $index => $church)
                @php
                    $isUnprov = ($church['provisioning_status'] ?? '') === 'unprovisioned';
                @endphp
                <tr>
                    <td class="text-center">{{ $index + 1 }}</td>
                    <td>
                        <strong>{{ $church['name'] ?? '-' }}</strong>
                    </td>
                    <td class="text-center">
                        @if(($church['status'] ?? '') === 'active')
                            <span class="badge badge-active">Aktif</span>
                        @else
                            <span class="badge badge-suspended">Suspended</span>
                        @endif
                    </td>
                    <td class="text-center">
                        @if($isUnprov)
                            <span class="badge badge-unprovisioned">Belum Dikonfigurasi</span>
                        @else
                            <span class="badge badge-provisioned">Terkonfigurasi</span>
                        @endif
                    </td>
                    <td class="text-center">
                        @if($isUnprov)
                            <span style="color: #94a3b8; font-weight: bold;">&mdash;</span>
                        @else
                            {{ $church['active_modules_count'] ?? 0 }}/{{ $church['total_modules_provisioned'] ?? 12 }}
                        @endif
                    </td>
                    <td class="text-right">{{ number_format($church['member_count'] ?? 0) }}</td>
                    <td class="text-right">{{ number_format((float) ($church['total_donations'] ?? 0), 0, ',', '.') }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="7" class="text-center" style="color: #64748b; padding: 10px;">Tidak ada data gereja tercatat.</td>
                </tr>
            @endforelse
        </tbody>
    </table>
</body>
</html>
