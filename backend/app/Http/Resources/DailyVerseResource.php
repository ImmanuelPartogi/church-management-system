<?php

namespace App\Http\Resources;

use App\Models\DailyVerse;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

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
