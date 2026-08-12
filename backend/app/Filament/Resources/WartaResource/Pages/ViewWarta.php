<?php

namespace App\Filament\Resources\WartaResource\Pages;

use App\Filament\Resources\WartaResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewWarta extends ViewRecord
{
    protected static string $resource = WartaResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
