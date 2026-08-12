<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Run Roles and Permissions Seeder
        $this->call(RolesAndPermissionsSeeder::class);

        // 2. Create Default Admin User
        $adminUser = User::create([
            'name' => 'System Admin',
            'email' => 'admin@church.org',
            'firebase_uid' => 'mock-admin-uid',
            'password' => Hash::make('password123'),
        ]);
        $adminUser->assignRole('admin');

        // 3. Run rest of the seeders
        $this->call([
            ChurchMemberSeeder::class,
            WorshipScheduleSeeder::class,
            AnnouncementSeeder::class,
            DailyVerseSeeder::class,
            ServiceFormTypeSeeder::class,
        ]);
    }
}
