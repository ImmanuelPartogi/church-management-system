<?php

namespace App\Filament\Resources\ServiceFormApplicationResource\Pages;

use App\Filament\Resources\ServiceFormApplicationResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditServiceFormApplication extends EditRecord
{
    protected static string $resource = ServiceFormApplicationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
