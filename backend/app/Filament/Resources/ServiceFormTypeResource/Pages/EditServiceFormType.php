<?php

namespace App\Filament\Resources\ServiceFormTypeResource\Pages;

use App\Filament\Resources\ServiceFormTypeResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditServiceFormType extends EditRecord
{
    protected static string $resource = ServiceFormTypeResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
