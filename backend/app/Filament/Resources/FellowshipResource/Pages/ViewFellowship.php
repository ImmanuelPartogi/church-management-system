<?php

namespace App\Filament\Resources\FellowshipResource\Pages;

use App\Filament\Resources\FellowshipResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewFellowship extends ViewRecord
{
    protected static string $resource = FellowshipResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
