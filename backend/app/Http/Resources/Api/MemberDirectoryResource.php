<?php

namespace App\Http\Resources\Api;

use App\Models\ChurchMember;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin ChurchMember
 */
class MemberDirectoryResource extends JsonResource
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
            'membership_number' => $this->membership_number,
            'full_name' => $this->full_name,
            'gender' => $this->gender,
            'status' => $this->status,
            'masked_phone' => $this->maskPhone($this->phone),
            'has_app_account' => $this->user_id !== null,
        ];
    }

    /**
     * Mask phone number for member directory privacy.
     */
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
