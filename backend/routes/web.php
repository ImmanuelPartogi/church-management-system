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

Route::get('/preview/no-membership', function () {
    return response()->view('errors.no-membership', [
        'title' => 'Keanggotaan Gereja Belum Terdaftar',
        'message' => 'Akun Anda saat ini belum terhubung dengan keanggotaan gereja aktif mana pun. Hubungi administrator gereja untuk mendapatkan akses.',
        'code' => 'NO_ACTIVE_MEMBERSHIP',
    ], 403);
});
