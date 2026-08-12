<?php

namespace App\Filament\Resources\ServiceFormTypeResource\Pages;

use App\Filament\Resources\ServiceFormTypeResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListServiceFormTypes extends ListRecords
{
    protected static string $resource = ServiceFormTypeResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
