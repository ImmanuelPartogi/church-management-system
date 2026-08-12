<?php

namespace App\Filament\Resources\ChurchServantResource\Pages;

use App\Filament\Resources\ChurchServantResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewChurchServant extends ViewRecord
{
    protected static string $resource = ChurchServantResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
