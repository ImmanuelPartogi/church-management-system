<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\WorshipScheduleResource;
use App\Models\WorshipSchedule;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class WorshipScheduleController extends Controller
{
    /**
     * Display a listing of active worship schedules.
     */
    public function index(): AnonymousResourceCollection
    {
        $schedules = WorshipSchedule::where('active', true)
            ->with(['officers.member'])
            ->get();

        return WorshipScheduleResource::collection($schedules);
    }

    /**
     * Display worship schedules grouped by day for calendar display.
     */
    public function calendar(): JsonResponse
    {
        $schedules = WorshipSchedule::where('active', true)
            ->with(['officers.member'])
            ->get();

        $grouped = [];
        foreach ($schedules->groupBy('day') as $day => $items) {
            $grouped[$day] = WorshipScheduleResource::collection($items);
        }

        return response()->json($grouped);
    }
}
