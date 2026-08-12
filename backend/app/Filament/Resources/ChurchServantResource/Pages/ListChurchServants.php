<?php

namespace App\Filament\Resources\ChurchServantResource\Pages;

use App\Filament\Resources\ChurchServantResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListChurchServants extends ListRecords
{
    protected static string $resource = ChurchServantResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
