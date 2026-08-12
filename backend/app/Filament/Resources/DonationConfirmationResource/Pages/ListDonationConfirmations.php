<?php

namespace App\Filament\Resources\DonationConfirmationResource\Pages;

use App\Filament\Resources\DonationConfirmationResource;
use Filament\Resources\Pages\ListRecords;

class ListDonationConfirmations extends ListRecords
{
    protected static string $resource = DonationConfirmationResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}
