<?php

namespace App\Http\Resources\Api;

use App\Models\PrayerRequest;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin PrayerRequest
 */
class PrayerRequestResource extends JsonResource
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
            'user_id' => $this->user_id,
            'member_id' => $this->member_id,
            'title' => $this->title,
            'content' => $this->content,
            'category' => $this->category,
            'is_private' => $this->is_private,
            'status' => $this->status,
            'follow_up_notes' => $this->follow_up_notes,
            'followed_up_at' => $this->followed_up_at,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
