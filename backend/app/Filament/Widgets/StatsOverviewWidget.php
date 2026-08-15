<?php

namespace App\Filament\Widgets;

use App\Models\ChurchMember;
use App\Models\ChurchServant;
use App\Models\DonationConfirmation;
use App\Models\PrayerRequest;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverviewWidget extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        $totalMembers = ChurchMember::count();
        $totalServants = ChurchServant::count();
        $pendingPrayerRequests = PrayerRequest::where('status', 'submitted')->count();
        $totalDonations = DonationConfirmation::where('status', 'verified')->sum('amount');

        return [
            Stat::make('Total Jemaat', number_format($totalMembers))
                ->description('Anggota jemaat terdaftar')
                ->descriptionIcon('heroicon-m-user-group')
                ->color('info'),

            Stat::make('Pelayan Gereja', number_format($totalServants))
                ->description('Pelayan & pengurus aktif')
                ->descriptionIcon('heroicon-m-academic-cap')
                ->color('success'),

            Stat::make('Permohonan Doa Baru', number_format($pendingPrayerRequests))
                ->description('Perlu tindak lanjut gembala')
                ->descriptionIcon('heroicon-m-heart')
                ->color('warning'),

            Stat::make('Total Persembahan', 'Rp '.number_format($totalDonations, 0, ',', '.'))
                ->description('Persembahan terverifikasi')
                ->descriptionIcon('heroicon-m-currency-dollar')
                ->color('primary'),
        ];
    }
}
