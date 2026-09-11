<?php

namespace App\Filament\Resources\ChurchRegistrationResource\Pages;

use App\Filament\Resources\ChurchRegistrationResource;
use Filament\Resources\Pages\ListRecords;

class ListChurchRegistrations extends ListRecords
{
    protected static string $resource = ChurchRegistrationResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}
