<?php

namespace App\Filament\Resources\ServiceFormTypeResource\Pages;

use App\Filament\Resources\ServiceFormTypeResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewServiceFormType extends ViewRecord
{
    protected static string $resource = ServiceFormTypeResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
