<?php

namespace App\Filament\Resources\SongbookResource\Pages;

use App\Filament\Resources\SongbookResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListSongbooks extends ListRecords
{
    protected static string $resource = SongbookResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
