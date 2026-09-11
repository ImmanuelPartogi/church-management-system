<?php

namespace Database\Seeders;

use App\Models\Church;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;
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

        // When teams => true, set team context to default church so roles are seeded with church_id
        if (config('permission.teams')) {
            $defaultChurch = Church::firstOrCreate(
                ['slug' => (string) config('tenant.default_church_slug', 'default')],
                [
                    'uuid' => (string) Str::uuid(),
                    'name' => 'Gereja HKBP Resort Default',
                    'status' => 'active',
                    'timezone' => 'Asia/Jakarta',
                ]
            );
            app(PermissionRegistrar::class)->setPermissionsTeamId($defaultChurch->id);
            app()->instance('current_church_id', $defaultChurch->id);
            app()->instance('current_church', $defaultChurch);
        }

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
            'verify sectoral sacraments',
            'approve final sacraments',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Create roles and assign existing permissions
        $churchId = config('permission.teams') ? ($defaultChurch->id ?? null) : null;
        $createRole = function (string $name) use ($churchId): Role {
            $attributes = ['name' => $name, 'guard_name' => 'web'];
            if ($churchId) {
                $attributes['church_id'] = $churchId;
            }

            return Role::firstOrCreate($attributes);
        };

        // Church Admin: has all permissions within a church
        $churchAdminRole = $createRole('church_admin');
        $churchAdminRole->givePermissionTo(Permission::all());

        // Bendahara (Treasurer): has full finance permissions and view access
        $bendaharaRole = $createRole('bendahara');
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
        $pastorRole = $createRole('pastor');
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
            'verify sectoral sacraments',
            'approve final sacraments',
        ]);

        // Sintua: sectoral elder that verifies sacrament requests and views member/community data
        $sintuaRole = $createRole('sintua');
        $sintuaRole->givePermissionTo([
            'verify sectoral sacraments',
            'view form applications',
            'view members',
            'view sectors',
            'view church servants',
        ]);

        // Staff: can manage schedules, announcements, daily verses, wartas, sermons, songbooks, songs and view community
        $staffRole = $createRole('staff');
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
        $memberRole = $createRole('member');
        $memberRole->givePermissionTo([
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
    }
}
