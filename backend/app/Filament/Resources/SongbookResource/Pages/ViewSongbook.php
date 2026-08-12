<?php

namespace App\Filament\Resources\SongbookResource\Pages;

use App\Filament\Resources\SongbookResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewSongbook extends ViewRecord
{
    protected static string $resource = SongbookResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
