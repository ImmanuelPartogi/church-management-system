<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\AuthService;
use App\Services\FirebaseAuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    protected FirebaseAuthService $firebaseAuthService;

    protected AuthService $authService;

    public function __construct(FirebaseAuthService $firebaseAuthService, AuthService $authService)
    {
        $this->firebaseAuthService = $firebaseAuthService;
        $this->authService = $authService;
    }

    /**
     * Exchange Firebase ID Token for a Laravel Sanctum Token.
     */
    public function firebase(Request $request): JsonResponse
    {
        $request->validate([
            'firebase_id_token' => 'required|string',
        ]);

        try {
            $firebaseData = $this->firebaseAuthService->verifyToken($request->input('firebase_id_token'));

            $result = $this->authService->authenticateFromFirebase($firebaseData);

            return $this->jsonSuccess([
                'token' => $result['token'],
                'user' => [
                    'id' => $result['user']->id,
                    'name' => $result['user']->name,
                    'email' => $result['user']->email,
                    'is_super_admin' => (bool) $result['user']->is_super_admin,
                    'roles' => $result['user']->getRoleNames(),
                    'memberships' => $this->getUserMemberships($result['user']),
                ],
            ], 'Authentication successful.');
        } catch (\Exception $e) {
            return $this->jsonError('Unauthorized: Invalid Firebase token.', $e->getMessage(), 401);
        }
    }

    /**
     * Get the authenticated user profile.
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        return $this->jsonSuccess([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'is_super_admin' => (bool) $user->is_super_admin,
            'roles' => $user->getRoleNames(),
            'memberships' => $this->getUserMemberships($user),
        ], 'Profile retrieved successfully.');
    }

    /**
     * Get deterministic active memberships for user.
     *
     * @return array<int, array<string, mixed>>
     */
    protected function getUserMemberships($user): array
    {
        return $user->memberships()
            ->where('status', 'active')
            ->orderBy('joined_at', 'asc')
            ->orderBy('id', 'asc')
            ->with('church')
            ->get()
            ->map(fn ($m) => [
                'church_id' => $m->church_id,
                'church_uuid' => $m->church?->uuid,
                'church_name' => $m->church?->name,
                'church_slug' => $m->church?->slug,
                'role' => $m->role,
            ])
            ->values()
            ->all();
    }

    /**
     * Log out the current user by revoking their current Sanctum token.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return $this->jsonSuccess(null, 'Logged out successfully.');
    }
}
