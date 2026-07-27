<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Kreait\Firebase\Contract\Auth as FirebaseAuth;

class AuthController extends Controller
{
    protected FirebaseAuth $firebaseAuth;

    /**
     * AuthController constructor.
     */
    public function __construct(FirebaseAuth $firebaseAuth)
    {
        $this->firebaseAuth = $firebaseAuth;
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
            // Verify the Firebase ID Token
            $verifiedIdToken = $this->firebaseAuth->verifyIdToken($request->input('firebase_id_token'));

            // Extract info from token claims
            $firebaseUid = $verifiedIdToken->claims()->get('sub');
            $email = $verifiedIdToken->claims()->get('email');
            $name = $verifiedIdToken->claims()->get('name') ?? Str::before($email, '@');

            if (! $firebaseUid) {
                return $this->jsonError('Unauthorized: Invalid token claims.', null, 401);
            }

            // Find or create the user in Laravel DB
            $user = User::where('firebase_uid', $firebaseUid)->first();

            if (! $user && $email) {
                // Link via email if user exists but has no firebase_uid yet
                $user = User::where('email', $email)->first();
                if ($user) {
                    $user->update(['firebase_uid' => $firebaseUid]);
                }
            }

            if (! $user) {
                $user = User::create([
                    'name' => $name,
                    'email' => $email,
                    'firebase_uid' => $firebaseUid,
                    'password' => Hash::make(Str::random(24)),
                ]);

                // Default new users to the 'member' role
                $user->assignRole('member');
            }

            // Revoke previous tokens if any, to keep it clean (optional, but good for single session)
            $user->tokens()->delete();

            // Create new Sanctum token
            $token = $user->createToken('auth-token')->plainTextToken;

            return $this->jsonSuccess([
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'roles' => $user->getRoleNames(),
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
            'roles' => $user->getRoleNames(),
        ], 'Profile retrieved successfully.');
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
