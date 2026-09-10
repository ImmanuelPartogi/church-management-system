<?php

namespace App\Filament\Resources\ChurchResource\Pages;

use App\Filament\Resources\ChurchResource;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Str;

class CreateChurch extends CreateRecord
{
    protected static string $resource = ChurchResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        if (empty($data['uuid'])) {
            $data['uuid'] = (string) Str::uuid();
        }

        return $data;
    }
}
