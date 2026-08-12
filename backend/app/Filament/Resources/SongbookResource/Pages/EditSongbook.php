<?php

namespace App\Filament\Resources\SongbookResource\Pages;

use App\Filament\Resources\SongbookResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditSongbook extends EditRecord
{
    protected static string $resource = SongbookResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
