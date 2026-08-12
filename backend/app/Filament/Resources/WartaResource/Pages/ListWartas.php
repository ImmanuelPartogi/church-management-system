<?php

namespace App\Filament\Resources\WartaResource\Pages;

use App\Filament\Resources\WartaResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListWartas extends ListRecords
{
    protected static string $resource = WartaResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
