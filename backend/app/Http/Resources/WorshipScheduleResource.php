<?php

namespace App\Http\Resources;

use App\Models\WorshipSchedule;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin WorshipSchedule
 */
class WorshipScheduleResource extends JsonResource
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
            'title' => $this->title,
            'description' => $this->description,
            'day' => $this->day,
            'start_time' => $this->start_time,
            'end_time' => $this->end_time,
            'location' => $this->location,
            'active' => $this->active,
            'officers' => WorshipOfficerResource::collection($this->whenLoaded('officers')),
        ];
    }
}
