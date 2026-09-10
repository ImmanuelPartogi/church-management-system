<?php

namespace App\Filament\Resources\ChurchResource\Pages;

use App\Filament\Resources\ChurchResource;
use Filament\Resources\Pages\EditRecord;

class EditChurch extends EditRecord
{
    protected static string $resource = ChurchResource::class;

    protected function getHeaderActions(): array
    {
        // Strictly no DeleteAction. Deactivation is handled exclusively via status = suspended.
        return [];
    }
}
