<?php

namespace App\Filament\Resources\ChurchBankAccountResource\Pages;

use App\Filament\Resources\ChurchBankAccountResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListChurchBankAccounts extends ListRecords
{
    protected static string $resource = ChurchBankAccountResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
