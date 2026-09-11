<?php

namespace App\Filament\Widgets;

use App\Models\SynodReportSnapshot;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class SynodOverviewStatsWidget extends BaseWidget
{
    protected static ?int $sort = 1;

    protected int|string|array $columnSpan = 'full';

    /**
     * This widget should only appear on the SynodDashboard page,
     * not on the default Dashboard.
     */
    protected static bool $isDiscovered = false;

    protected function getStats(): array
    {
        $snapshot = SynodReportSnapshot::latestSnapshot();

        if (! $snapshot) {
            return [
                Stat::make('Status', 'Belum Ada Data')
                    ->description('Klik "Generate Laporan Terbaru" untuk membuat snapshot pertama.')
                    ->descriptionIcon('heroicon-m-exclamation-triangle')
                    ->color('warning'),
            ];
        }

        // Module adoption summary: find module with highest and lowest adoption
        $moduleAdoption = $snapshot->module_adoption ?? [];
        $avgAdoption = count($moduleAdoption) > 0
            ? round(collect($moduleAdoption)->avg('adoption_percentage'), 1)
            : 0;

        // Count unprovisioned churches
        $comparisons = collect($snapshot->church_comparisons ?? []);
        $unprovisionedCount = $comparisons->where('provisioning_status', 'unprovisioned')->count();

        return [
            Stat::make('Total Gereja', number_format($snapshot->total_churches))
                ->description(
                    $snapshot->active_churches.' aktif · '.$snapshot->suspended_churches.' ditangguhkan'
                )
                ->descriptionIcon('heroicon-m-building-library')
                ->color('info'),

            Stat::make('Jemaat (Gereja Aktif)', number_format($snapshot->total_active_members))
                ->description(
                    number_format($snapshot->total_all_members).' total (termasuk suspended)'
                )
                ->descriptionIcon('heroicon-m-user-group')
                ->color('success'),

            Stat::make('Persembahan Terverifikasi', 'Rp '.number_format((float) $snapshot->total_active_donations, 0, ',', '.'))
                ->description(
                    'Rp '.number_format((float) $snapshot->total_all_donations, 0, ',', '.').' total seluruh gereja'
                )
                ->descriptionIcon('heroicon-m-currency-dollar')
                ->color('primary'),

            Stat::make('Pelayanan Sakramen', number_format($snapshot->total_active_sacraments))
                ->description(
                    number_format($snapshot->total_all_sacraments).' total (termasuk suspended)'
                )
                ->descriptionIcon('heroicon-m-clipboard-document-list')
                ->color('info'),

            Stat::make('Rata-rata Adopsi Modul', $avgAdoption.'%')
                ->description(
                    count($moduleAdoption).' modul terdaftar di sinode'
                )
                ->descriptionIcon('heroicon-m-puzzle-piece')
                ->color($avgAdoption >= 75 ? 'success' : ($avgAdoption >= 50 ? 'warning' : 'danger')),

            Stat::make('Gereja Belum Terkonfigurasi', $unprovisionedCount > 0 ? $unprovisionedCount : '0')
                ->description(
                    $unprovisionedCount > 0
                        ? 'Perlu backfill: php artisan churches:backfill-modules'
                        : 'Semua gereja sudah terprovisioning'
                )
                ->descriptionIcon($unprovisionedCount > 0 ? 'heroicon-m-exclamation-triangle' : 'heroicon-m-check-circle')
                ->color($unprovisionedCount > 0 ? 'warning' : 'success'),
        ];
    }
}
