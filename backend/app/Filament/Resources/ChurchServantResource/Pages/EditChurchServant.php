<?php

namespace App\Filament\Resources\ChurchServantResource\Pages;

use App\Filament\Resources\ChurchServantResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditChurchServant extends EditRecord
{
    protected static string $resource = ChurchServantResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
