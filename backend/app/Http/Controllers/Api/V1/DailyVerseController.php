<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\DailyVerseResource;
use App\Models\DailyVerse;
use Illuminate\Http\JsonResponse;

class DailyVerseController extends Controller
{
    /**
     * Display the daily verse for today, or fallback to the latest one.
     */
    public function show(): JsonResponse
    {
        $today = now()->toDateString();
        $verse = DailyVerse::where('date', $today)->first();

        // Fallback to the latest verse if today's is not seeded
        if (! $verse) {
            $verse = DailyVerse::orderBy('date', 'desc')->first();
        }

        if (! $verse) {
            return $this->jsonError('Daily verse not found.', null, 404);
        }

        return $this->jsonSuccess(new DailyVerseResource($verse), 'Daily verse retrieved successfully.');
    }
}
