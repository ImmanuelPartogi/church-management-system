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
            'manage wartas',
            'manage form types',
            'manage form applications',
            'manage prayer requests',
            'manage bank accounts',
            'manage chart of accounts',
            'manage donations',
            'manage financial transactions',
            'manage resorts',
            'manage sectors',
            'manage fellowships',
            'manage church servants',
            'manage sermons',
            'manage songbooks',
            'manage songs',
            'view members',
            'view schedules',
            'view announcements',
            'view daily verses',
            'view wartas',
            'view form types',
            'view form applications',
            'view prayer requests',
            'view private prayer requests',
            'view bank accounts',
            'view chart of accounts',
            'view donations',
            'view financial transactions',
            'view resorts',
            'view sectors',
            'view fellowships',
            'view church servants',
            'view sermons',
            'view songbooks',
            'view songs',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Create roles and assign existing permissions

        // Admin: has all permissions
        $adminRole = Role::firstOrCreate(['name' => 'admin']);
        $adminRole->givePermissionTo(Permission::all());

        // Bendahara (Treasurer): has full finance permissions and view access
        $bendaharaRole = Role::firstOrCreate(['name' => 'bendahara']);
        $bendaharaRole->givePermissionTo([
            'manage bank accounts',
            'manage chart of accounts',
            'manage donations',
            'manage financial transactions',
            'view bank accounts',
            'view chart of accounts',
            'view donations',
            'view financial transactions',
            'view resorts',
            'view sectors',
            'view fellowships',
            'view church servants',
            'view sermons',
            'view songbooks',
            'view songs',
        ]);

        // Pastor: has domain management permissions
        $pastorRole = Role::firstOrCreate(['name' => 'pastor']);
        $pastorRole->givePermissionTo([
            'manage members',
            'manage schedules',
            'manage announcements',
            'manage daily verses',
            'manage wartas',
            'manage form applications',
            'manage prayer requests',
            'manage resorts',
            'manage sectors',
            'manage fellowships',
            'manage church servants',
            'manage sermons',
            'manage songbooks',
            'manage songs',
            'view members',
            'view schedules',
            'view announcements',
            'view daily verses',
            'view wartas',
            'view form types',
            'view form applications',
            'view prayer requests',
            'view private prayer requests',
            'view bank accounts',
            'view chart of accounts',
            'view donations',
            'view financial transactions',
            'view resorts',
            'view sectors',
            'view fellowships',
            'view church servants',
            'view sermons',
            'view songbooks',
            'view songs',
        ]);

        // Staff: can manage schedules, announcements, daily verses, wartas, sermons, songbooks, songs and view community
        $staffRole = Role::firstOrCreate(['name' => 'staff']);
        $staffRole->givePermissionTo([
            'manage schedules',
            'manage announcements',
            'manage daily verses',
            'manage wartas',
            'manage sermons',
            'manage songbooks',
            'manage songs',
            'view members',
            'view schedules',
            'view announcements',
            'view daily verses',
            'view wartas',
            'view form types',
            'view form applications',
            'view prayer requests',
            'view bank accounts',
            'view chart of accounts',
            'view donations',
            'view financial transactions',
            'view resorts',
            'view sectors',
            'view fellowships',
            'view church servants',
            'view sermons',
            'view songbooks',
            'view songs',
        ]);

        // Member: can view public schedules, announcements, daily verses, wartas, sermons, songbooks, songs
        $memberRole = Role::firstOrCreate(['name' => 'member']);
        $memberRole->givePermissionTo([
            'view schedules',
            'view announcements',
            'view daily verses',
            'view wartas',
            'view sermons',
            'view songbooks',
            'view songs',
        ]);
    }
}
