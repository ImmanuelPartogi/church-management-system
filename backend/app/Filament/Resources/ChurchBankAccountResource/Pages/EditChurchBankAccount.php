<?php

namespace App\Filament\Resources\ChurchBankAccountResource\Pages;

use App\Filament\Resources\ChurchBankAccountResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditChurchBankAccount extends EditRecord
{
    protected static string $resource = ChurchBankAccountResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
