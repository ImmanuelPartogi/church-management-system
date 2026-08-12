<?php

namespace App\Filament\Resources\DonationConfirmationResource\Pages;

use App\Filament\Resources\DonationConfirmationResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditDonationConfirmation extends EditRecord
{
    protected static string $resource = DonationConfirmationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
