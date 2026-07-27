<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes (v1)
|--------------------------------------------------------------------------
|
| Semua route dikonsumsi oleh aplikasi Flutter. Web Admin (Filament) TIDAK
| memakai route di file ini — Filament mengakses Service/Repository layer
| secara langsung di dalam proses Laravel yang sama.
|
| Implementasi controller & route per modul menyusul di fase pengembangan
| fitur (lihat docs/api-contract.md untuk kontrak endpoint).
|
*/

Route::prefix('v1')->group(function () {
    // Auth: exchange Firebase ID token -> Sanctum token
    // Route::post('/auth/exchange-token', ...);
    // Route::get('/auth/me', ...)->middleware('auth:sanctum');
    // Route::post('/auth/logout', ...)->middleware('auth:sanctum');

    Route::middleware('auth:sanctum')->group(function () {
        // Route::get('/home', ...);
        // Route::apiResource('/schedules', ...);
        // Route::apiResource('/announcements', ...);
        // Route::apiResource('/service-forms', ...);
        // Route::apiResource('/prayer-requests', ...);
        // Route::apiResource('/donations', ...);
        // Route::get('/church-bank-accounts', ...);
        // Route::get('/directory', ...);
        // Route::get('/communities', ...);
        // Route::get('/finance/summary', ...);
        // Route::get('/media/sermons', ...);
        // Route::get('/media/hymns', ...);
        // Route::get('/profile', ...);
        // Route::put('/profile', ...);
        // Route::delete('/profile', ...);
        // Route::get('/search', ...);
    });
});
