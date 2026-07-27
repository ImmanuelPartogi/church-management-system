<?php

namespace App\Http\Resources\Api;

use App\Models\DailyVerse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Carbon;

/**
 * @mixin DailyVerse
 */
class DailyVerseResource extends JsonResource
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
            'verse_reference' => $this->verse_reference,
            'content' => $this->content,
            'date' => $this->date ? Carbon::parse($this->date)->toDateString() : null,
        ];
    }
}
