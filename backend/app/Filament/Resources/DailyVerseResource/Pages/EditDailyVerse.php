<?php

namespace App\Filament\Resources\DailyVerseResource\Pages;

use App\Filament\Resources\DailyVerseResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditDailyVerse extends EditRecord
{
    protected static string $resource = DailyVerseResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
