<?php

namespace App\Filament\Pages;

use App\Filament\Widgets\SynodChurchesComparisonWidget;
use App\Filament\Widgets\SynodOverviewStatsWidget;
use App\Jobs\GenerateSynodReportSnapshotJob;
use App\Models\SynodReportSnapshot;
use App\Services\Reporting\SynodReportExportService;
use Filament\Actions\Action;
use Filament\Actions\ActionGroup;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Illuminate\Support\Facades\Log;

class SynodDashboard extends Page
{
    protected static string $routePath = '/synod-dashboard';

    protected static ?string $title = 'Dashboard Sinode';

    protected static ?string $navigationLabel = 'Dashboard Sinode';

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-chart-bar-square';

    protected static string|\UnitEnum|null $navigationGroup = 'Pengaturan Gereja';

    protected static ?int $navigationSort = 100;

    protected string $view = 'filament.pages.synod-dashboard';

    /**
     * Authorization gate: only Super Admins can access this page.
     */
    public static function canAccess(): bool
    {
        return (bool) auth()->user()?->is_super_admin;
    }

    /**
     * Audit log on page mount: record who viewed the synod dashboard and when.
     */
    public function mount(): void
    {
        Log::channel('single')->info('SynodDashboard.accessed', [
            'user_id' => auth()->id(),
            'user_email' => auth()->user()?->email,
            'ip' => request()->ip(),
            'timestamp' => now()->toIso8601String(),
        ]);
    }

    /**
     * Header actions: Generate Snapshot and Export Report buttons.
     */
    protected function getHeaderActions(): array
    {
        $hasSnapshot = SynodReportSnapshot::latestSnapshot() !== null;

        return [
            ActionGroup::make([
                Action::make('exportPdf')
                    ->label('Unduh Dokumen Resmi (PDF)')
                    ->icon('heroicon-o-document-arrow-down')
                    ->color('danger')
                    ->disabled(! $hasSnapshot)
                    ->action(function (SynodReportExportService $service) {
                        $snapshot = SynodReportSnapshot::latestSnapshot();

                        if (! $snapshot) {
                            Notification::make()
                                ->title('Belum ada data untuk diekspor')
                                ->body('Silakan generate laporan terlebih dahulu untuk membuat snapshot data sinode.')
                                ->warning()
                                ->send();

                            return null;
                        }

                        return $service->exportPdf($snapshot);
                    }),
                Action::make('exportCsv')
                    ->label('Unduh Spreadsheet (Excel / CSV)')
                    ->icon('heroicon-o-table-cells')
                    ->color('success')
                    ->disabled(! $hasSnapshot)
                    ->action(function (SynodReportExportService $service) {
                        $snapshot = SynodReportSnapshot::latestSnapshot();

                        if (! $snapshot) {
                            Notification::make()
                                ->title('Belum ada data untuk diekspor')
                                ->body('Silakan generate laporan terlebih dahulu untuk membuat snapshot data sinode.')
                                ->warning()
                                ->send();

                            return null;
                        }

                        return $service->exportCsv($snapshot);
                    }),
            ])
                ->label('Ekspor Laporan')
                ->icon('heroicon-o-arrow-down-tray')
                ->color('gray')
                ->button(),

            Action::make('generateSnapshot')
                ->label('Generate Laporan Terbaru')
                ->icon('heroicon-o-arrow-path')
                ->color('primary')
                ->requiresConfirmation()
                ->modalHeading('Generate Snapshot Laporan Sinode')
                ->modalDescription('Proses ini akan mengagregasi data seluruh gereja secara asinkron. Snapshot baru akan tersedia dalam beberapa detik setelah job selesai dieksekusi oleh queue worker.')
                ->action(function () {
                    GenerateSynodReportSnapshotJob::dispatch(now()->toDateString());

                    Log::channel('single')->info('SynodDashboard.snapshot_triggered', [
                        'user_id' => auth()->id(),
                        'user_email' => auth()->user()?->email,
                        'period_date' => now()->toDateString(),
                        'timestamp' => now()->toIso8601String(),
                    ]);

                    Notification::make()
                        ->title('Job laporan sinode berhasil di-dispatch ke antrean.')
                        ->body('Refresh halaman ini dalam beberapa detik untuk melihat snapshot terbaru.')
                        ->success()
                        ->send();
                }),
        ];
    }

    /**
     * Widgets rendered on this page (in display order).
     */
    public function getWidgets(): array
    {
        return [
            SynodOverviewStatsWidget::class,
            SynodChurchesComparisonWidget::class,
        ];
    }

    public function getFooterWidgets(): array
    {
        return $this->getWidgets();
    }

    public function getFooterWidgetsColumns(): int|array
    {
        return 1;
    }

    /**
     * Provide the latest snapshot data to the Blade view.
     */
    protected function getViewData(): array
    {
        $snapshot = SynodReportSnapshot::latestSnapshot();

        return [
            'snapshot' => $snapshot,
            'hasSnapshot' => $snapshot !== null,
            'lastGenerated' => $snapshot?->created_at?->diffForHumans(),
            'generatedBy' => $snapshot?->generatedBy?->name ?? 'System (Scheduler)',
        ];
    }
}
