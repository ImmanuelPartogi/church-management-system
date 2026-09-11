<?php

namespace App\Filament\Widgets;

use App\Models\SynodReportSnapshot;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Enums\PaginationMode;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;
use Illuminate\Contracts\Support\Htmlable;
use Illuminate\Support\HtmlString;

class SynodChurchesComparisonWidget extends TableWidget
{
    protected static ?int $sort = 2;

    protected int|string|array $columnSpan = 'full';

    /**
     * This widget should only appear on the SynodDashboard page,
     * not on the default Dashboard.
     */
    protected static bool $isDiscovered = false;

    protected function getTableHeading(): string|Htmlable|null
    {
        return new HtmlString('Perbandingan Antar Gereja <span style="font-weight: 400; font-size: 0.85em; color: #6b7280;">(Sumber: Snapshot Terbaru)</span>');
    }

    /**
     * Build the table from JSON snapshot data using Filament native array data source.
     *
     * KNOWN LIMITATION (In-Memory Array Sorting & Search):
     * Sorting and filtering are performed in PHP memory on the decoded JSON collection
     * rather than SQL WHERE / ORDER BY clauses. At current scale (<50 churches) this
     * is instantaneous and avoids database hits entirely. When the synod scales to
     * hundreds of churches, consider refactoring in tandem with the batch aggregation
     * refactor (ADR 9) to indexed database queries or persistent materialized views.
     */
    public function table(Table $table): Table
    {
        return $table
            ->heading($this->getTableHeading())
            ->records(function (?string $search = null, ?string $sortColumn = null, ?string $sortDirection = null) {
                $snapshot = SynodReportSnapshot::latestSnapshot();
                $records = collect($snapshot?->church_comparisons ?? []);

                if ($search) {
                    $records = $records->filter(function ($record) use ($search) {
                        return str_contains(strtolower($record['name'] ?? ''), strtolower($search))
                            || str_contains(strtolower($record['slug'] ?? ''), strtolower($search));
                    });
                }

                if ($sortColumn) {
                    $records = $records->sortBy(
                        callback: fn ($record) => $record[$sortColumn] ?? null,
                        descending: strtolower($sortDirection ?? 'asc') === 'desc'
                    );
                }

                return $records->values();
            })
            ->columns([
                TextColumn::make('name')
                    ->label('Nama Gereja')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->colors([
                        'success' => 'active',
                        'danger' => 'suspended',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'active' => 'Aktif',
                        'suspended' => 'Ditangguhkan',
                        default => $state,
                    }),

                TextColumn::make('provisioning_status')
                    ->label('Konfigurasi Modul')
                    ->badge()
                    ->colors([
                        'success' => 'provisioned',
                        'warning' => 'unprovisioned',
                    ])
                    ->icons([
                        'heroicon-o-check-circle' => 'provisioned',
                        'heroicon-o-exclamation-triangle' => 'unprovisioned',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'provisioned' => 'Terkonfigurasi',
                        'unprovisioned' => 'Belum Terkonfigurasi',
                        default => $state,
                    })
                    ->tooltip(fn (string $state): string => match ($state) {
                        'unprovisioned' => 'Gereja ini belum memiliki konfigurasi modul. Jalankan: php artisan churches:backfill-modules',
                        'provisioned' => 'Modul sudah terprovisioning.',
                        default => '',
                    }),

                TextColumn::make('active_modules_count')
                    ->label('Modul Aktif')
                    ->alignCenter()
                    ->sortable()
                    ->formatStateUsing(function ($state, $record): string {
                        $provisioned = $record['total_modules_provisioned'] ?? 0;

                        if ($provisioned === 0) {
                            return '—';
                        }

                        return $state.'/'.$provisioned;
                    })
                    ->color(function ($state, $record): string {
                        $provisioned = $record['total_modules_provisioned'] ?? 0;

                        if ($provisioned === 0) {
                            return 'warning';
                        }

                        return $state > 0 ? 'success' : 'gray';
                    }),

                TextColumn::make('member_count')
                    ->label('Jumlah Jemaat')
                    ->alignCenter()
                    ->sortable()
                    ->numeric(),

                TextColumn::make('total_donations')
                    ->label('Total Persembahan')
                    ->alignEnd()
                    ->sortable()
                    ->formatStateUsing(fn ($state): string => 'Rp '.number_format((float) $state, 0, ',', '.')),
            ])
            ->defaultSort('name', 'asc')
            ->paginationMode(PaginationMode::Simple)
            ->defaultPaginationPageOption(10);
    }
}
