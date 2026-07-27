<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\WorshipScheduleResource;
use App\Models\WorshipSchedule;
use Illuminate\Http\JsonResponse;

class WorshipScheduleController extends Controller
{
    /**
     * Display a listing of active worship schedules.
     */
    public function index(): JsonResponse
    {
        $schedules = WorshipSchedule::where('active', true)
            ->with(['officers.member'])
            ->get();

        return $this->jsonSuccess(WorshipScheduleResource::collection($schedules), 'Worship schedules retrieved successfully.');
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

        return $this->jsonSuccess($grouped, 'Worship schedules grouped by calendar day retrieved successfully.');
    }
}
