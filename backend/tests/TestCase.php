<?php

namespace Tests;

use App\Models\Church;
use App\Models\Module;
use App\Services\Tenant\ChurchModuleService;
use Database\Seeders\ModuleSeeder;
use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Spatie\Permission\PermissionRegistrar;

abstract class TestCase extends BaseTestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        if (Schema::hasTable('churches')) {
            $defaultChurch = Church::firstOrCreate(
                ['slug' => (string) config('tenant.default_church_slug', 'default')],
                [
                    'uuid' => (string) Str::uuid(),
                    'name' => 'Default Test Church',
                    'status' => 'active',
                    'timezone' => 'Asia/Jakarta',
                ]
            );

            app()->instance('current_church_id', $defaultChurch->id);
            app()->instance('current_church', $defaultChurch);

            if (config('permission.teams')) {
                app(PermissionRegistrar::class)->setPermissionsTeamId($defaultChurch->id);
            }

            if (Schema::hasTable('modules') && Module::count() === 0) {
                $this->seed(ModuleSeeder::class);
            }

            if (Schema::hasTable('church_modules')) {
                app(ChurchModuleService::class)->provisionDefaults($defaultChurch);
            }
        }
    }
}
