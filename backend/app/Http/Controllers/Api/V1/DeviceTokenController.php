<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\DeviceToken;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeviceTokenController extends Controller
{
    /**
     * Store or update a device token for the authenticated user.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'token' => 'required|string|max:500',
            'platform' => 'nullable|string|in:android,ios,web',
            'device_name' => 'nullable|string|max:255',
        ]);

        $user = $request->user();

        $deviceToken = DeviceToken::updateOrCreate(
            ['token' => $validated['token']],
            [
                'user_id' => $user->id,
                'platform' => $validated['platform'] ?? 'android',
                'device_name' => $validated['device_name'] ?? null,
                'last_used_at' => now(),
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Device token registered successfully.',
            'data' => [
                'id' => $deviceToken->id,
                'user_id' => $deviceToken->user_id,
                'token' => $deviceToken->token,
                'platform' => $deviceToken->platform,
                'device_name' => $deviceToken->device_name,
                'last_used_at' => $deviceToken->last_used_at?->toIso8601String(),
            ],
        ]);
    }

    /**
     * Delete a device token for the authenticated user.
     */
    public function destroy(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'token' => 'required|string|max:500',
        ]);

        $user = $request->user();

        DeviceToken::where('user_id', $user->id)
            ->where('token', $validated['token'])
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'Device token deleted successfully.',
        ]);
    }
}
