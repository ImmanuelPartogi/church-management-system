<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\DeviceToken;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DeviceTokenController extends Controller
{
    /**
     * Store or update a device token for the authenticated user and church tenant context.
     * Fans out across all active memberships inside an atomic DB transaction.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'token' => 'required|string|max:500',
            'platform' => 'nullable|string|in:android,ios,web',
            'device_name' => 'nullable|string|max:255',
            'church_id' => 'nullable|integer|exists:churches,id',
        ]);

        $user = $request->user();

        // 1. Resolve target churches: all active memberships if user authenticated
        $activeChurchIds = collect();

        if ($user) {
            $activeChurchIds = $user->memberships()
                ->where('status', 'active')
                ->pluck('church_id');
        }

        // 2. Include explicitly requested church context if available
        $explicitChurchId = $validated['church_id']
            ?? (app()->bound('current_church_id') ? app('current_church_id') : null)
            ?? $request->header('X-Church-Id');

        if ($explicitChurchId && ! $activeChurchIds->contains((int) $explicitChurchId)) {
            $activeChurchIds->push((int) $explicitChurchId);
        }

        // 3. Fallback: if no active memberships and no explicit church, reject with 422
        if ($activeChurchIds->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Church context is required for device token registration.',
            ], 422);
        }

        // 4. Wrap fan-out updateOrCreate in an atomic DB transaction
        $registeredTokens = [];
        DB::transaction(function () use ($activeChurchIds, $validated, $user, &$registeredTokens) {
            foreach ($activeChurchIds as $cid) {
                $registeredTokens[] = DeviceToken::updateOrCreate(
                    [
                        'token' => $validated['token'],
                        'church_id' => (int) $cid,
                    ],
                    [
                        'user_id' => $user?->id,
                        'platform' => $validated['platform'] ?? 'android',
                        'device_name' => $validated['device_name'] ?? null,
                        'is_active' => true,
                        'last_used_at' => now(),
                    ]
                );
            }
        });

        $primaryToken = $registeredTokens[0] ?? null;

        return response()->json([
            'success' => true,
            'message' => 'Device token registered successfully.',
            'data' => [
                'id' => $primaryToken?->id,
                'user_id' => $primaryToken?->user_id,
                'church_id' => $primaryToken?->church_id,
                'token' => $primaryToken?->token,
                'platform' => $primaryToken?->platform,
                'device_name' => $primaryToken?->device_name,
                'is_active' => (bool) $primaryToken?->is_active,
                'last_used_at' => $primaryToken?->last_used_at?->toIso8601String(),
                'registered_count' => count($registeredTokens),
            ],
        ]);
    }

    /**
     * Delete a device token for the authenticated user and optional church context.
     */
    public function destroy(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'token' => 'required|string|max:500',
            'church_id' => 'nullable|integer|exists:churches,id',
        ]);

        $user = $request->user();

        $query = DeviceToken::where('token', $validated['token']);

        if ($user) {
            $query->where('user_id', $user->id);
        }

        if (! empty($validated['church_id'])) {
            $query->where('church_id', (int) $validated['church_id']);
        }

        $query->delete();

        return response()->json([
            'success' => true,
            'message' => 'Device token deleted successfully.',
        ]);
    }
}
