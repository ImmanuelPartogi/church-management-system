<?php

use App\Http\Controllers\Api\AnnouncementController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DailyVerseController;
use App\Http\Controllers\Api\MemberController;
use App\Http\Controllers\Api\WorshipScheduleController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::get('/daily-verse', [DailyVerseController::class, 'show']);
Route::get('/announcements', [AnnouncementController::class, 'index']);
Route::get('/worship-schedules', [WorshipScheduleController::class, 'index']);
Route::get('/worship-schedules/calendar', [WorshipScheduleController::class, 'calendar']);

// Auth token exchange
Route::post('/auth/firebase', [AuthController::class, 'firebase']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);

    Route::get('/members', [MemberController::class, 'index']);
    Route::get('/members/{id}', [MemberController::class, 'show']);
});
