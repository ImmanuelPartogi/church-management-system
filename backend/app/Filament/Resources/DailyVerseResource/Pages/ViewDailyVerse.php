<?php

namespace App\Filament\Resources\DailyVerseResource\Pages;

use App\Filament\Resources\DailyVerseResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewDailyVerse extends ViewRecord
{
    protected static string $resource = DailyVerseResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
