<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Phase 7: Prune abandoned unverified church registrations older than 7 days daily at 02:00
Schedule::command('church-registrations:prune-stale --days=7')->dailyAt('02:00');

// Phase 6A: Generate aggregated synod report snapshot daily at 00:05
Schedule::command('synod:generate-report')->dailyAt('00:05');
