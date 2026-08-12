<?php

namespace App\Filament\Resources\WorshipScheduleResource\Pages;

use App\Filament\Resources\WorshipScheduleResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditWorshipSchedule extends EditRecord
{
    protected static string $resource = WorshipScheduleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
