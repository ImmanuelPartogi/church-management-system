<?php

namespace App\Http\Resources\Api;

use App\Models\Sermon;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Sermon
 */
class SermonResource extends JsonResource
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
            'preacher_name' => $this->preacher_name,
            'servant' => $this->whenLoaded('servant', fn () => $this->servant ? [
                'id' => $this->servant->id,
                'name' => $this->servant->name,
                'role' => $this->servant->role->value,
            ] : null),
            'file_name' => $this->file_name,
            'file_size' => $this->file_size,
            'mime_type' => $this->mime_type,
            'download_count' => $this->download_count,
            'published_at' => $this->published_at?->toIso8601String(),
            'is_published' => $this->is_published,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
