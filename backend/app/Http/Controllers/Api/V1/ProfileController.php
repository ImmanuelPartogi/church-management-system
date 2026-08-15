<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\MemberDirectoryResource;
use App\Models\ChurchMember;
use App\Models\DeviceToken;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProfileController extends Controller
{
    /**
     * Get the authenticated user's profile and linked jemaat member details.
     */
    public function show(Request $request): JsonResponse
    {
        $user = $request->user();
        $user->load('member');

        return $this->jsonSuccess([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone ?? ($user->member?->phone),
            'address' => $user->address ?? ($user->member?->address),
            'roles' => $user->getRoleNames(),
            'member' => $user->member ? (new MemberDirectoryResource($user->member))->resolve() : null,
        ], 'Profile retrieved successfully.');
    }

    /**
     * Update allowed user profile details.
     */
    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'nullable|string|max:30',
            'address' => 'nullable|string|max:1000',
        ]);

        DB::transaction(function () use ($user, $validated) {
            $user->update([
                'name' => $validated['name'],
                'phone' => $validated['phone'] ?? null,
                'address' => $validated['address'] ?? null,
            ]);

            if ($user->member) {
                $user->member->update([
                    'full_name' => $validated['name'],
                    'phone' => $validated['phone'] ?? $user->member->phone,
                    'address' => $validated['address'] ?? $user->member->address,
                ]);
            }
        });

        $user->refresh()->load('member');

        return $this->jsonSuccess([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone ?? ($user->member?->phone),
            'address' => $user->address ?? ($user->member?->address),
            'roles' => $user->getRoleNames(),
            'member' => $user->member ? (new MemberDirectoryResource($user->member))->resolve() : null,
        ], 'Profile updated successfully.');
    }

    /**
     * Delete the authenticated user account in compliance with UU PDP data privacy rights.
     */
    public function destroy(Request $request): JsonResponse
    {
        $user = $request->user();

        DB::transaction(function () use ($user) {
            // 1. Purge FCM device tokens
            DeviceToken::where('user_id', $user->id)->delete();

            // 2. Unlink ChurchMember record to safely retain church organizational archive
            ChurchMember::where('user_id', $user->id)->update(['user_id' => null]);

            // 3. Revoke all Sanctum tokens
            $user->tokens()->delete();

            // 4. Delete user account
            $user->delete();
        });

        return $this->jsonSuccess(null, 'Account deleted successfully.');
    }
}
