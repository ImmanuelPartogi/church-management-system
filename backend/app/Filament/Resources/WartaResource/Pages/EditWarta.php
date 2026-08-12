<?php

namespace App\Filament\Resources\WartaResource\Pages;

use App\Filament\Resources\WartaResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditWarta extends EditRecord
{
    protected static string $resource = WartaResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
