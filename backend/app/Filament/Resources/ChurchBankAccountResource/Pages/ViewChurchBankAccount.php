<?php

namespace App\Filament\Resources\ChurchBankAccountResource\Pages;

use App\Filament\Resources\ChurchBankAccountResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewChurchBankAccount extends ViewRecord
{
    protected static string $resource = ChurchBankAccountResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
