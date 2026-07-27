<?php

namespace App\Http\Resources;

use App\Models\WorshipOfficer;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin WorshipOfficer
 */
class WorshipOfficerResource extends JsonResource
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
            'role' => $this->role,
            'member' => [
                'id' => $this->member->id,
                'full_name' => $this->member->full_name,
                'membership_number' => $this->member->membership_number,
            ],
        ];
    }
}
