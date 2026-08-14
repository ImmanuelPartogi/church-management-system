<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\PrayerRequestStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\StorePrayerRequestRequest;
use App\Http\Resources\Api\PrayerRequestResource;
use App\Models\PrayerRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PrayerRequestController extends Controller
{
    /**
     * Display a listing of prayer requests submitted by the authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $prayerRequests = PrayerRequest::where('user_id', $user->id)
            ->latest('created_at')
            ->latest('id')
            ->paginate(10);

        return $this->jsonPaginated(PrayerRequestResource::collection($prayerRequests), 'Prayer requests retrieved successfully.');
    }

    /**
     * Display the specified prayer request details for the authenticated user.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $user = $request->user();

        $prayerRequest = PrayerRequest::find($id);

        if (! $prayerRequest) {
            return $this->jsonError('Prayer request not found.', null, 404);
        }

        // Strict ownership check
        if ($prayerRequest->user_id !== $user->id) {
            return $this->jsonError('You are not authorized to view this prayer request.', null, 403);
        }

        return $this->jsonSuccess(new PrayerRequestResource($prayerRequest), 'Prayer request details retrieved successfully.');
    }

    /**
     * Submit a new prayer request for the authenticated user.
     */
    public function store(StorePrayerRequestRequest $request): JsonResponse
    {
        $user = $request->user();
        $member = $user->member;

        $validated = $request->validated();

        $prayerRequest = PrayerRequest::create([
            'user_id' => $user->id,
            'member_id' => $member?->id,
            'title' => $validated['title'],
            'content' => $validated['content'],
            'category' => $validated['category'] ?? null,
            'is_private' => $validated['is_private'] ?? true,
            'status' => PrayerRequestStatus::Submitted,
            'follow_up_notes' => null,
            'followed_up_by' => null,
            'followed_up_at' => null,
        ]);

        return $this->jsonSuccess(new PrayerRequestResource($prayerRequest), 'Prayer request submitted successfully.', 201);
    }
}
