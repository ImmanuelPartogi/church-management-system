<?php

use App\Http\Controllers\Api\V1\AnnouncementController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\ChurchBankAccountController;
use App\Http\Controllers\Api\V1\DailyVerseController;
use App\Http\Controllers\Api\V1\DonationConfirmationController;
use App\Http\Controllers\Api\V1\FinancialTransparencyController;
use App\Http\Controllers\Api\V1\MemberController;
use App\Http\Controllers\Api\V1\PrayerRequestController;
use App\Http\Controllers\Api\V1\ServiceFormApplicationController;
use App\Http\Controllers\Api\V1\ServiceFormTypeController;
use App\Http\Controllers\Api\V1\WartaController;
use App\Http\Controllers\Api\V1\WorshipScheduleController;
use Illuminate\Support\Facades\Route;

// Health Check Endpoint
Route::get('/health', function () {
    return response()->json([
        'success' => true,
        'message' => 'API is running',
        'data' => [
            'version' => '1.0.0',
            'environment' => app()->environment(),
        ],
    ]);
});

// Public routes
Route::get('/daily-verse', [DailyVerseController::class, 'show']);
Route::get('/announcements', [AnnouncementController::class, 'index']);
Route::get('/worship-schedules', [WorshipScheduleController::class, 'index']);
Route::get('/worship-schedules/calendar', [WorshipScheduleController::class, 'calendar']);

// Phase 3.1 Public Extended Endpoints
Route::get('/wartas', [WartaController::class, 'index']);
Route::get('/wartas/{id}', [WartaController::class, 'show']);
Route::get('/wartas/{id}/download', [WartaController::class, 'download']);

Route::get('/service-form-types', [ServiceFormTypeController::class, 'index']);
Route::get('/service-form-types/{id}', [ServiceFormTypeController::class, 'show']);

// Phase 3.2 Public Extended Endpoints
Route::get('/church-bank-accounts', [ChurchBankAccountController::class, 'index']);

// Phase 3.3 Public Extended Endpoints
Route::get('/finances/transparency', [FinancialTransparencyController::class, 'index']);

// Auth token exchange with rate limit
Route::post('/auth/firebase', [AuthController::class, 'firebase'])
    ->middleware('throttle:firebase-auth');

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    // Phase 3.3 Member Directory Search (placed before /members/{id} to prevent route collision)
    Route::get('/members/search', [MemberController::class, 'search']);

    Route::get('/members', [MemberController::class, 'index']);
    Route::get('/members/{id}', [MemberController::class, 'show']);

    // Phase 3.1 Protected Extended Endpoints
    Route::get('/service-form-applications', [ServiceFormApplicationController::class, 'index']);
    Route::get('/service-form-applications/{id}', [ServiceFormApplicationController::class, 'show']);
    Route::post('/service-form-applications', [ServiceFormApplicationController::class, 'store']);

    // Phase 3.2 Protected Extended Endpoints
    Route::post('/donations/confirm', [DonationConfirmationController::class, 'confirm']);
    Route::get('/donations/my-donations', [DonationConfirmationController::class, 'myDonations']);
    Route::get('/donations/{id}', [DonationConfirmationController::class, 'show']);

    // Phase 3.3 Protected Extended Endpoints
    Route::get('/prayer-requests', [PrayerRequestController::class, 'index']);
    Route::post('/prayer-requests', [PrayerRequestController::class, 'store']);
    Route::get('/prayer-requests/{id}', [PrayerRequestController::class, 'show']);
});
