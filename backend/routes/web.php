<?php

use Kreait\Firebase\Contract\Auth;

Route::get('/firebase-test', function (Auth $auth) {
    return response()->json([
        'message' => 'Firebase connected successfully',
    ]);
});