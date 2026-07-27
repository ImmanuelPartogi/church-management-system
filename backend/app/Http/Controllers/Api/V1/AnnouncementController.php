<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\AnnouncementResource;
use App\Models\Announcement;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AnnouncementController extends Controller
{
    /**
     * Display a listing of published announcements.
     */
    public function index(Request $request): JsonResponse
    {
        $announcements = Announcement::where('status', 'published')
            ->where('published_at', '<=', now())
            ->orderBy('published_at', 'desc')
            ->paginate(10);

        return $this->jsonPaginated(AnnouncementResource::collection($announcements), 'Announcements retrieved successfully.');
    }
}
