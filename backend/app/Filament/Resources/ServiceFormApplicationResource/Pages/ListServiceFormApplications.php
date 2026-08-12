<?php

namespace App\Filament\Resources\ServiceFormApplicationResource\Pages;

use App\Filament\Resources\ServiceFormApplicationResource;
use Filament\Resources\Pages\ListRecords;

class ListServiceFormApplications extends ListRecords
{
    protected static string $resource = ServiceFormApplicationResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}
