<?php

use Kreait\Firebase\Contract\Auth;

Route::get('/', function () {
    return response()->json([
        'name' => config('app.name'),
        'status' => 'online',
    ]);
});

Route::get('/firebase-test', function (Auth $auth) {
    return response()->json([
        'message' => 'Firebase connected successfully',
    ]);
});
