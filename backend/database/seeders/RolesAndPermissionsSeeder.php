<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class RolesAndPermissionsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[PermissionRegistrar::class]->forgetCachedPermissions();

        // Create permissions
        $permissions = [
            'manage members',
            'manage schedules',
            'manage announcements',
            'manage daily verses',
            'view members',
            'view schedules',
            'view announcements',
            'view daily verses',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Create roles and assign existing permissions

        // Admin: has all permissions
        $adminRole = Role::firstOrCreate(['name' => 'admin']);
        $adminRole->givePermissionTo(Permission::all());

        // Pastor: has all permissions except managing roles or other high-level configurations
        $pastorRole = Role::firstOrCreate(['name' => 'pastor']);
        $pastorRole->givePermissionTo([
            'manage members',
            'manage schedules',
            'manage announcements',
            'manage daily verses',
            'view members',
            'view schedules',
            'view announcements',
            'view daily verses',
        ]);

        // Staff: can manage schedules, announcements, and daily verses
        $staffRole = Role::firstOrCreate(['name' => 'staff']);
        $staffRole->givePermissionTo([
            'manage schedules',
            'manage announcements',
            'manage daily verses',
            'view members',
            'view schedules',
            'view announcements',
            'view daily verses',
        ]);

        // Member: can view schedules, announcements, daily verses
        $memberRole = Role::firstOrCreate(['name' => 'member']);
        $memberRole->givePermissionTo([
            'view schedules',
            'view announcements',
            'view daily verses',
        ]);
    }
}
