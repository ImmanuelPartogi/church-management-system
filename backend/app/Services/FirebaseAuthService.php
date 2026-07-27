<?php

namespace App\Services;

use Kreait\Firebase\Contract\Auth as FirebaseAuth;

class FirebaseAuthService
{
    protected FirebaseAuth $firebaseAuth;

    public function __construct(FirebaseAuth $firebaseAuth)
    {
        $this->firebaseAuth = $firebaseAuth;
    }

    /**
     * Verify Firebase ID Token and return verification payload claims.
     *
     * @return array{uid: string, email: ?string, name: ?string}
     *
     * @throws \Exception
     */
    public function verifyToken(string $token): array
    {
        $verifiedIdToken = $this->firebaseAuth->verifyIdToken($token);
        $uid = $verifiedIdToken->claims()->get('sub');
        $email = $verifiedIdToken->claims()->get('email');
        $name = $verifiedIdToken->claims()->get('name');

        return [
            'uid' => $uid,
            'email' => $email,
            'name' => $name,
        ];
    }
}
