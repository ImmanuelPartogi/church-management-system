<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\DailyVerseResource;
use App\Models\DailyVerse;
use Illuminate\Http\JsonResponse;

class DailyVerseController extends Controller
{
    /**
     * Display the daily verse for today, or fallback to the latest one.
     */
    public function show(): JsonResponse|DailyVerseResource
    {
        $today = now()->toDateString();
        $verse = DailyVerse::where('date', $today)->first();

        // Fallback to the latest verse if today's is not seeded
        if (! $verse) {
            $verse = DailyVerse::orderBy('date', 'desc')->first();
        }

        if (! $verse) {
            return response()->json([
                'message' => 'Daily verse not found.',
            ], 404);
        }

        return new DailyVerseResource($verse);
    }
}
