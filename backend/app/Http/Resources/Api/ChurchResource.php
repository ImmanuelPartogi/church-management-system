<?php

namespace App\Http\Resources\Api;

use App\Models\Church;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Church
 */
class ChurchResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'uuid' => $this->uuid,
            'name' => $this->name,
            'slug' => $this->slug,
            'timezone' => $this->timezone,
            'address' => $this->address,
            'phone' => $this->phone,
            'logo_url' => $this->logo_path ? asset('storage/'.$this->logo_path) : null,
            'theme_primary_color' => $this->theme_primary_color ?? '#1B4B66',
            'theme_secondary_color' => $this->theme_secondary_color ?? '#F5A623',
            'theme_version' => (int) ($this->theme_version ?? 1),
        ];
    }
}
