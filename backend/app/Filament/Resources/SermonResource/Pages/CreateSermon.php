<?php

namespace App\Filament\Resources\SermonResource\Pages;

use App\Filament\Resources\SermonResource;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Facades\Storage;

class CreateSermon extends CreateRecord
{
    protected static string $resource = SermonResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        if (isset($data['file_path']) && is_string($data['file_path'])) {
            $data['file_name'] = basename($data['file_path']);
            if (Storage::disk('public')->exists($data['file_path'])) {
                $data['file_size'] = Storage::disk('public')->size($data['file_path']);
                $data['mime_type'] = Storage::disk('public')->mimeType($data['file_path']);
            }
        }

        return $data;
    }
}
