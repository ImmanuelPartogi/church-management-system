<?php

namespace App\Http\Resources\Api;

use App\Enums\ChurchServantRole;
use App\Models\ChurchServant;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin ChurchServant
 */
class ChurchServantResource extends JsonResource
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
            'name' => $this->name,
            'role' => $this->role->value,
            'role_label' => match ($this->role) {
                ChurchServantRole::PdtResort => 'Pendeta Resort',
                ChurchServantRole::Sintua => 'Sintua',
                ChurchServantRole::Majelis => 'Majelis',
                ChurchServantRole::SectorLeader => 'Ketua Sektor',
                ChurchServantRole::FellowshipLeader => 'Ketua Seksi/Punguan',
            },
            'masked_phone' => $this->maskPhone($this->phone),
            'phone' => $request->user() ? $this->phone : null,
            'email' => $this->email,
            'description' => $this->description,
            'active' => $this->active,
            'resort_name' => $this->resort?->name,
            'sector_name' => $this->sector?->name,
            'fellowship_name' => $this->fellowship?->name,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }

    private function maskPhone(?string $phone): ?string
    {
        if (! $phone || strlen($phone) < 6) {
            return null;
        }

        $prefix = substr($phone, 0, 4);
        $suffix = substr($phone, -3);

        return $prefix.'****'.$suffix;
    }
}
