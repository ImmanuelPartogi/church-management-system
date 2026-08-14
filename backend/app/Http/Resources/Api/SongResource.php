<?php

namespace App\Http\Resources\Api;

use App\Models\Song;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Song
 */
class SongResource extends JsonResource
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
            'songbook_id' => $this->songbook_id,
            'songbook_name' => $this->whenLoaded('songbook', fn () => $this->songbook->name),
            'songbook_code' => $this->whenLoaded('songbook', fn () => $this->songbook->code),
            'number' => $this->number,
            'title' => $this->title,
            'lyrics' => $this->lyrics,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
