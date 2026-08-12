<?php

namespace App\Filament\Resources\WorshipScheduleResource\Pages;

use App\Filament\Resources\WorshipScheduleResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListWorshipSchedules extends ListRecords
{
    protected static string $resource = WorshipScheduleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
