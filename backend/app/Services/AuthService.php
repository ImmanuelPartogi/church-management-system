<?php

namespace App\Services;

use App\Models\Church;
use App\Models\ChurchUserMembership;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

class AuthService
{
    /**
     * Match or create a Laravel user from Firebase details and issue a Sanctum token.
     *
     * @param  array{uid: string, email: ?string, name: ?string}  $firebaseData
     * @return array{token: string, user: User}
     */
    public function authenticateFromFirebase(array $firebaseData): array
    {
        $firebaseUid = $firebaseData['uid'];
        $email = $firebaseData['email'];
        $name = $firebaseData['name'] ?? Str::before($email, '@');

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

            // Synchronously create initial ChurchUserMembership in active church context
            if (Schema::hasTable('churches') && Schema::hasTable('church_user_memberships')) {
                $targetChurchId = app()->bound('current_church_id') ? app('current_church_id') : null;
                if (! $targetChurchId) {
                    $targetChurchId = Church::where('slug', (string) config('tenant.default_church_slug', 'default'))->value('id');
                }

                if ($targetChurchId) {
                    ChurchUserMembership::create([
                        'user_id' => $user->id,
                        'church_id' => $targetChurchId,
                        'role' => 'member',
                        'status' => 'active',
                        'joined_at' => now(),
                    ]);
                }
            }
        }

        // Revoke previous tokens
        $user->tokens()->delete();

        // Create new Sanctum token
        $token = $user->createToken('auth-token')->plainTextToken;

        return [
            'token' => $token,
            'user' => $user,
        ];
    }
}
