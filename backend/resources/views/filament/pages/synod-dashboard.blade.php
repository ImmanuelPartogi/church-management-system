<x-filament-panels::page>
    @if ($hasSnapshot)
        <div class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm dark:border-gray-800 dark:bg-gray-900 mb-6">
            <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between text-sm text-gray-600 dark:text-gray-400">
                <div class="flex items-center gap-2">
                    <span class="inline-block h-2.5 w-2.5 rounded-full bg-emerald-500"></span>
                    <span>Snapshot Periode: <strong class="font-semibold text-gray-900 dark:text-gray-100">{{ $snapshot->period_date }}</strong></span>
                </div>
                <div>
                    Terakhir di-generate: <strong class="font-semibold text-gray-900 dark:text-gray-100">{{ $lastGenerated }}</strong> (oleh {{ $generatedBy }})
                </div>
            </div>
        </div>
    @else
        <div class="rounded-xl border border-amber-200 bg-amber-50 p-4 text-amber-800 dark:border-amber-900/50 dark:bg-amber-950/20 dark:text-amber-300 mb-6">
            <div class="flex items-center gap-2 text-sm font-medium">
                <x-heroicon-m-exclamation-triangle class="h-5 w-5 text-amber-500" />
                <span>Belum ada snapshot laporan sinode. Klik tombol <strong>"Generate Laporan Terbaru"</strong> di pojok kanan atas untuk membuat snapshot pertama.</span>
            </div>
        </div>
    @endif
</x-filament-panels::page>
