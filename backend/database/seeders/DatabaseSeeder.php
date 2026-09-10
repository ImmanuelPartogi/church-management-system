<?php

namespace Database\Seeders;

use App\Models\Church;
use App\Models\ChurchUserMembership;
use App\Models\User;
use App\Services\Tenant\ChurchModuleService;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Spatie\Permission\PermissionRegistrar;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 0. Ensure Default Church tenant exists and bind tenant context for console/seeder lifecycle
        $defaultChurch = Church::firstOrCreate(
            ['slug' => (string) config('tenant.default_church_slug', 'default')],
            [
                'uuid' => (string) Str::uuid(),
                'name' => 'Gereja HKBP Resort Default',
                'status' => 'active',
                'timezone' => 'Asia/Jakarta',
            ]
        );

        app()->instance('current_church_id', $defaultChurch->id);
        app()->instance('current_church', $defaultChurch);

        if (config('permission.teams')) {
            app(PermissionRegistrar::class)->setPermissionsTeamId($defaultChurch->id);
        }

        // 0.1 Seed Modules and Provision Default Church
        $this->call(ModuleSeeder::class);
        app(ChurchModuleService::class)->provisionDefaults($defaultChurch);

        // 1. Run Roles and Permissions Seeder
        $this->call(RolesAndPermissionsSeeder::class);

        // 2. Create Default Admin User
        $adminUser = User::create([
            'name' => 'System Admin',
            'email' => 'admin@church.org',
            'firebase_uid' => 'mock-admin-uid',
            'password' => Hash::make('password123'),
            'is_super_admin' => true,
        ]);
        $adminUser->assignRole('church_admin');

        ChurchUserMembership::firstOrCreate(
            [
                'church_id' => $defaultChurch->id,
                'user_id' => $adminUser->id,
            ],
            [
                'role' => 'church_admin',
                'status' => 'active',
            ]
        );

        // 3. Run rest of the seeders
        $this->call([
            ChurchMemberSeeder::class,
            WorshipScheduleSeeder::class,
            AnnouncementSeeder::class,
            DailyVerseSeeder::class,
            ServiceFormTypeSeeder::class,
            ChartOfAccountSeeder::class,
            ChurchBankAccountSeeder::class,
            ResortSeeder::class,
            SectorSeeder::class,
            FellowshipSeeder::class,
            SongbookSeeder::class,
        ]);
    }
}
