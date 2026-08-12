<?php

namespace App\Filament\Resources\WorshipScheduleResource\Pages;

use App\Filament\Resources\WorshipScheduleResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewWorshipSchedule extends ViewRecord
{
    protected static string $resource = WorshipScheduleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
