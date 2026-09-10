<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Default Tenant Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration values for the platform default church tenant created
    | during the Phase 1D data backfill.
    |
    */

    'default_church_name' => env('DEFAULT_CHURCH_NAME', 'Gereja HKBP Resort'),
    'default_church_slug' => 'default',
    'default_church_status' => 'active',
    'default_church_timezone' => 'Asia/Jakarta',
];
