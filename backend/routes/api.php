<?php

use App\Http\Controllers\Api\V1\AnnouncementController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\ChurchBankAccountController;
use App\Http\Controllers\Api\V1\ChurchController;
use App\Http\Controllers\Api\V1\DailyVerseController;
use App\Http\Controllers\Api\V1\DeviceTokenController;
use App\Http\Controllers\Api\V1\DonationConfirmationController;
use App\Http\Controllers\Api\V1\FinancialTransparencyController;
use App\Http\Controllers\Api\V1\MemberController;
use App\Http\Controllers\Api\V1\PrayerRequestController;
use App\Http\Controllers\Api\V1\ProfileController;
use App\Http\Controllers\Api\V1\SearchController;
use App\Http\Controllers\Api\V1\SermonController;
use App\Http\Controllers\Api\V1\ServantController;
use App\Http\Controllers\Api\V1\ServiceFormApplicationController;
use App\Http\Controllers\Api\V1\ServiceFormTypeController;
use App\Http\Controllers\Api\V1\SongController;
use App\Http\Controllers\Api\V1\WartaController;
use App\Http\Controllers\Api\V1\WorshipScheduleController;
use App\Http\Middleware\ResolveChurchContext;
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
})->withoutMiddleware(ResolveChurchContext::class);

// Public routes
// Phase 4A Public Churches Directory (Mobile Onboarding)
Route::get('/churches', [ChurchController::class, 'index'])
    ->withoutMiddleware(ResolveChurchContext::class);

Route::middleware('module:daily_verse')->group(function () {
    Route::get('/daily-verse', [DailyVerseController::class, 'show']);
});

Route::middleware('module:announcements')->group(function () {
    Route::get('/announcements', [AnnouncementController::class, 'index']);
});

Route::middleware('module:schedules')->group(function () {
    Route::get('/worship-schedules', [WorshipScheduleController::class, 'index']);
    Route::get('/worship-schedules/calendar', [WorshipScheduleController::class, 'calendar']);
});

// Phase 3.1 Public Extended Endpoints (Warta Module)
Route::middleware('module:warta')->group(function () {
    Route::get('/wartas', [WartaController::class, 'index']);
    Route::get('/wartas/{id}', [WartaController::class, 'show']);
    Route::get('/wartas/{id}/download', [WartaController::class, 'download']);
});

// Phase 3.1 Public Extended Endpoints (Forms Module)
Route::middleware('module:forms')->group(function () {
    Route::get('/service-form-types', [ServiceFormTypeController::class, 'index']);
    Route::get('/service-form-types/{id}', [ServiceFormTypeController::class, 'show']);
});

// Phase 3.2 & 3.3 Public Extended Endpoints (Finance Module)
Route::middleware('module:finance')->group(function () {
    Route::get('/church-bank-accounts', [ChurchBankAccountController::class, 'index']);
    Route::get('/finances/transparency', [FinancialTransparencyController::class, 'index']);
});

// Phase 10.1 Public Extended Endpoints (Hymns / Songbooks)
Route::middleware('module:hymns')->group(function () {
    Route::get('/songbooks', [SongController::class, 'songbooks']);
    Route::get('/songs', [SongController::class, 'index']);
    Route::get('/songs/{id}', [SongController::class, 'show']);
});

// Phase 12.1 Public Extended Endpoints (Community & Sermons Modules)
Route::middleware('module:community')->group(function () {
    Route::get('/servants', [ServantController::class, 'index']);
    Route::get('/servants/{id}', [ServantController::class, 'show']);
});

Route::middleware('module:sermons')->group(function () {
    Route::get('/sermons', [SermonController::class, 'index']);
    Route::get('/sermons/{id}', [SermonController::class, 'show']);
    Route::get('/sermons/{id}/download', [SermonController::class, 'download']);
});

// Phase 14.1 Global Cross-Module Search Endpoint
Route::get('/search', [SearchController::class, 'search']);

// Auth token exchange with rate limit
Route::post('/auth/firebase', [AuthController::class, 'firebase'])
    ->middleware('throttle:firebase-auth');

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout'])
        ->withoutMiddleware(ResolveChurchContext::class);
    Route::get('/auth/me', [AuthController::class, 'me'])
        ->withoutMiddleware(ResolveChurchContext::class)
        ->middleware(ResolveChurchContext::class.':optional');

    // Phase 15.1 Profile & Account Management
    Route::get('/profile', [ProfileController::class, 'show'])
        ->withoutMiddleware(ResolveChurchContext::class)
        ->middleware(ResolveChurchContext::class.':optional');
    Route::put('/profile', [ProfileController::class, 'update'])
        ->withoutMiddleware(ResolveChurchContext::class)
        ->middleware(ResolveChurchContext::class.':optional');
    Route::delete('/profile', [ProfileController::class, 'destroy'])
        ->withoutMiddleware(ResolveChurchContext::class)
        ->middleware(ResolveChurchContext::class.':optional');

    // Phase 13.1 Device Token Registration
    Route::post('/notifications/device-token', [DeviceTokenController::class, 'store']);
    Route::delete('/notifications/device-token', [DeviceTokenController::class, 'destroy']);

    // Phase 3.3 Member Directory (Membership Module)
    Route::middleware('module:membership')->group(function () {
        Route::get('/members/search', [MemberController::class, 'search']);
        Route::get('/members', [MemberController::class, 'index']);
        Route::get('/members/{id}', [MemberController::class, 'show']);
    });

    // Phase 3.1 Protected Extended Endpoints (Forms Module)
    Route::middleware('module:forms')->group(function () {
        Route::get('/service-form-applications', [ServiceFormApplicationController::class, 'index']);
        Route::get('/service-form-applications/{id}', [ServiceFormApplicationController::class, 'show']);
        Route::post('/service-form-applications', [ServiceFormApplicationController::class, 'store']);
    });

    // Phase 3.2 Protected Extended Endpoints (Donations Module)
    Route::middleware('module:donations')->group(function () {
        Route::post('/donations/confirm', [DonationConfirmationController::class, 'confirm']);
        Route::get('/donations/my-donations', [DonationConfirmationController::class, 'myDonations']);
        Route::get('/donations/{id}', [DonationConfirmationController::class, 'show']);
    });

    // Phase 3.3 Protected Extended Endpoints (Prayer Requests Module)
    Route::middleware('module:prayer_requests')->group(function () {
        Route::get('/prayer-requests', [PrayerRequestController::class, 'index']);
        Route::post('/prayer-requests', [PrayerRequestController::class, 'store']);
        Route::get('/prayer-requests/{id}', [PrayerRequestController::class, 'show']);
    });
});
