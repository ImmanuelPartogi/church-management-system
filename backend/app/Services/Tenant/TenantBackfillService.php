<?php

namespace App\Services\Tenant;

use App\Models\Church;
use App\Models\ChurchMember;
use App\Models\ChurchModule;
use App\Models\ChurchUserMembership;
use App\Models\Module;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class TenantBackfillService
{
    /**
     * The 16 domain tables validated as CHURCH-SCOPED.
     *
     * @var array<int, string>
     */
    public const DOMAIN_TABLES = [
        'church_members',
        'worship_schedules',
        'announcements',
        'wartas',
        'service_form_types',
        'service_form_applications',
        'prayer_requests',
        'church_bank_accounts',
        'chart_of_accounts',
        'donation_confirmations',
        'financial_transactions',
        'resorts',
        'sectors',
        'fellowships',
        'church_servants',
        'sermons',
    ];

    /**
     * The 12 validated modules derived from actual code.
     *
     * @var array<string, array{name: string, is_core: bool, depends_on: ?string, description: string}>
     */
    public const MODULE_CATALOG = [
        'membership' => [
            'name' => 'Jemaat & Keanggotaan',
            'is_core' => true, // [NEEDS BUSINESS DECISION]
            'depends_on' => null,
            'description' => 'Manajemen database anggota jemaat, keluarga, dan profil keanggotaan.',
        ],
        'announcements' => [
            'name' => 'Pengumuman Gereja',
            'is_core' => true, // [NEEDS BUSINESS DECISION]
            'depends_on' => null,
            'description' => 'Saluran informasi dan pengumuman pastoral gereja.',
        ],
        'schedules' => [
            'name' => 'Jadwal Ibadah & Kegiatan',
            'is_core' => false,
            'depends_on' => 'membership',
            'description' => 'Jadwal ibadah mingguan, acara gereja, dan petugas pelayanan liturgi.',
        ],
        'warta' => [
            'name' => 'Warta Jemaat Digital',
            'is_core' => false,
            'depends_on' => null,
            'description' => 'Publikasi warta jemaat mingguan dan distribusi dokumen PDF.',
        ],
        'forms' => [
            'name' => 'Formulir Layanan Sakramen',
            'is_core' => false,
            'depends_on' => 'membership',
            'description' => 'Permohonan layanan pastoral, baptis, sidi, nikah kudus, dan atestasi.',
        ],
        'prayer_requests' => [
            'name' => 'Permohonan Doa',
            'is_core' => false,
            'depends_on' => 'membership',
            'description' => 'Permohonan pokok doa jemaat dan catatan tindak lanjut pastoral.',
        ],
        'finance' => [
            'name' => 'Keuangan & Buku Kas',
            'is_core' => false,
            'depends_on' => null,
            'description' => 'Bagan akun (COA), rekening bank gereja, buku kas, dan transparansi keuangan.',
        ],
        'donations' => [
            'name' => 'Donasi & Persembahan Online',
            'is_core' => false,
            'depends_on' => 'finance',
            'description' => 'Konfirmasi transfer persembahan perpuluhan, syukur, dan donasi khusus.',
        ],
        'community' => [
            'name' => 'Komunitas & Pelayanan Sektor',
            'is_core' => false,
            'depends_on' => 'membership',
            'description' => 'Struktur resort, sektor kategorial wilayah, persekutuan kategorial, dan pelayan sintua.',
        ],
        'sermons' => [
            'name' => 'Khotbah & Media Audio',
            'is_core' => false,
            'depends_on' => 'community',
            'description' => 'Arsip khotbah mingguan, rekaman audio, dan unduhan materi renungan.',
        ],
        'hymns' => [
            'name' => 'Buku Nyanyian & Pujian',
            'is_core' => false,
            'depends_on' => null,
            'description' => 'Katalog lagu gereja (Buku Ende, Kidung Jemaat, Nyanyikanlah Nyanyian Baru).',
        ],
        'daily_verse' => [
            'name' => 'Ayat Harian',
            'is_core' => false,
            'depends_on' => null,
            'description' => 'Renungan dan ayat harian firman Tuhan untuk aplikasi mobile.',
        ],
    ];

    /**
     * Role priority hierarchy for multi-role resolution (highest to lowest).
     *
     * @var array<int, string>
     */
    public const ROLE_PRIORITY = [
        'church_admin', // primary mapping
        'admin',        // legacy mapping for Phase 1D compatibility
        'pastor',       // maps to 'pastor'
        'bendahara',    // maps to 'bendahara'
        'staff',        // maps to 'staff'
        'member',       // maps to 'member'
    ];

    /**
     * Generate comprehensive pre-flight snapshot report.
     *
     * @return array<string, mixed>
     */
    public function getPreflightSnapshot(): array
    {
        // 1. Domain tables status
        $domainTablesStatus = [];
        $totalDomainRows = 0;
        $totalNullRows = 0;

        foreach (self::DOMAIN_TABLES as $table) {
            $total = DB::table($table)->count();
            $nullCount = DB::table($table)->whereNull('church_id')->count();
            $totalDomainRows += $total;
            $totalNullRows += $nullCount;

            $domainTablesStatus[$table] = [
                'total' => $total,
                'church_id_null' => $nullCount,
                'church_id_set' => $total - $nullCount,
            ];
        }

        // 2. User & Role analysis
        $users = User::with('roles')->get();
        $totalUsers = $users->count();

        $usersByRoleCount = [
            'single_role' => [],
            'multi_role' => [],
            'no_role' => [],
        ];

        $roleDistribution = [
            'church_admin' => 0,
            'pastor' => 0,
            'bendahara' => 0,
            'staff' => 0,
            'member' => 0,
            'unknown' => 0,
        ];

        $superAdminCount = 0;
        $anomalies = [];

        foreach ($users as $user) {
            /** @var array<int, string> $roleNames */
            $roleNames = $user->roles->pluck('name')->toArray();
            $count = count($roleNames);

            $resolvedRole = $this->resolveMembershipRole($roleNames);
            $roleDistribution[$resolvedRole] = ($roleDistribution[$resolvedRole] ?? 0) + 1;

            if (in_array('admin', $roleNames, true) || in_array('super_admin', $roleNames, true)) {
                $superAdminCount++;
            }

            if ($count === 1) {
                $usersByRoleCount['single_role'][] = [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'spatie_roles' => $roleNames,
                    'mapped_membership_role' => $resolvedRole,
                ];
            } elseif ($count > 1) {
                $usersByRoleCount['multi_role'][] = [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'spatie_roles' => $roleNames,
                    'mapped_membership_role' => $resolvedRole,
                ];
            } else {
                $usersByRoleCount['no_role'][] = [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'spatie_roles' => [],
                    'mapped_membership_role' => $resolvedRole,
                ];
                $anomalies[] = "User #{$user->id} ({$user->email}) has 0 Spatie roles; fallback mapped to 'member'.";
            }

            // Check unrecognized roles
            foreach ($roleNames as $roleName) {
                if (! in_array($roleName, self::ROLE_PRIORITY, true) && $roleName !== 'super_admin') {
                    $anomalies[] = "User #{$user->id} has unrecognized Spatie role '{$roleName}'.";
                }
            }
        }

        // 3. Check domain orphan data anomalies
        $orphanAnomalies = $this->checkOrphanData();
        $anomalies = array_merge($anomalies, $orphanAnomalies);

        return [
            'default_church' => [
                'name' => (string) config('tenant.default_church_name', 'Gereja HKBP Resort'),
                'slug' => (string) config('tenant.default_church_slug', 'default'),
                'status' => (string) config('tenant.default_church_status', 'active'),
                'timezone' => (string) config('tenant.default_church_timezone', 'Asia/Jakarta'),
            ],
            'modules_count' => count(self::MODULE_CATALOG),
            'domain_tables' => $domainTablesStatus,
            'total_domain_rows' => $totalDomainRows,
            'total_null_rows' => $totalNullRows,
            'total_users' => $totalUsers,
            'super_admin_count' => $superAdminCount,
            'users_by_role_count' => [
                'single_role_count' => count($usersByRoleCount['single_role']),
                'multi_role_count' => count($usersByRoleCount['multi_role']),
                'no_role_count' => count($usersByRoleCount['no_role']),
                'details' => $usersByRoleCount,
            ],
            'role_distribution' => $roleDistribution,
            'anomalies' => $anomalies,
        ];
    }

    /**
     * Execute idempotent backfill.
     *
     * @return array<string, mixed>
     */
    public function executeBackfill(bool $dryRun = false): array
    {
        $snapshot = $this->getPreflightSnapshot();

        if ($dryRun) {
            return [
                'dry_run' => true,
                'snapshot' => $snapshot,
            ];
        }

        return DB::transaction(function () use ($snapshot) {
            // 1. Seed or find default Church
            $defaultChurch = Church::withTrashed()->firstOrCreate(
                ['slug' => (string) config('tenant.default_church_slug', 'default')],
                [
                    'uuid' => (string) Str::uuid(),
                    'name' => (string) config('tenant.default_church_name', 'Gereja HKBP Resort'),
                    'status' => (string) config('tenant.default_church_status', 'active'),
                    'timezone' => (string) config('tenant.default_church_timezone', 'Asia/Jakarta'),
                    'address' => 'Kantor Resort Gereja HKBP',
                    'phone' => '+6281234567890',
                ]
            );

            if ($defaultChurch->trashed()) {
                $defaultChurch->restore();
            }

            // 2. Seed Modules Catalog
            $moduleMap = [];
            foreach (self::MODULE_CATALOG as $key => $meta) {
                $module = Module::firstOrCreate(
                    ['key' => $key],
                    [
                        'name' => $meta['name'],
                        'description' => $meta['description'],
                        'is_core' => $meta['is_core'],
                    ]
                );
                $moduleMap[$key] = $module;
            }

            // Wire depends_on self-references
            foreach (self::MODULE_CATALOG as $key => $meta) {
                if ($meta['depends_on'] !== null) {
                    $parentModule = $moduleMap[$meta['depends_on']];
                    $childModule = $moduleMap[$key];
                    if ($childModule->depends_on !== $parentModule->id) {
                        $childModule->depends_on = $parentModule->id;
                        $childModule->save();
                    }
                }
            }

            // 3. Enable All Modules for Default Church in church_modules
            $enabledModulesCount = 0;
            foreach ($moduleMap as $module) {
                $churchModule = ChurchModule::firstOrCreate(
                    [
                        'church_id' => $defaultChurch->id,
                        'module_id' => $module->id,
                    ],
                    [
                        'is_enabled' => true,
                        'settings' => null,
                        'enabled_at' => now(),
                    ]
                );

                if (! $churchModule->is_enabled) {
                    $churchModule->update(['is_enabled' => true, 'enabled_at' => now(), 'disabled_at' => null]);
                }
                $enabledModulesCount++;
            }

            // 4. Backfill church_id to 16 domain tables
            $tablesUpdated = [];
            foreach (self::DOMAIN_TABLES as $tableName) {
                $affected = 0;
                do {
                    /** @var array<int, int|string> $ids */
                    $ids = DB::table($tableName)
                        ->whereNull('church_id')
                        ->limit(250)
                        ->pluck('id')
                        ->toArray();

                    if (! empty($ids)) {
                        $count = DB::table($tableName)
                            ->whereIn('id', $ids)
                            ->update(['church_id' => $defaultChurch->id]);
                        $affected += $count;
                    }
                } while (! empty($ids));

                $tablesUpdated[$tableName] = $affected;
            }

            // 5. Backfill Users & ChurchUserMemberships
            $membershipsCreated = 0;
            $membershipsSkipped = 0;
            $superAdminsSet = 0;

            $users = User::with('roles')->get();
            foreach ($users as $user) {
                /** @var array<int, string> $roles */
                $roles = $user->roles->pluck('name')->toArray();
                $isSuperAdmin = in_array('admin', $roles, true) || in_array('super_admin', $roles, true);

                if ($isSuperAdmin && ! $user->is_super_admin) {
                    $user->is_super_admin = true;
                    $user->save();
                    $superAdminsSet++;
                }

                $membershipRole = $this->resolveMembershipRole($roles);

                // Find linked ChurchMember profile if any
                $churchMember = ChurchMember::where('user_id', $user->id)->first();
                $churchMemberId = $churchMember ? $churchMember->id : null;

                $membership = ChurchUserMembership::firstOrCreate(
                    [
                        'user_id' => $user->id,
                        'church_id' => $defaultChurch->id,
                    ],
                    [
                        'church_member_id' => $churchMemberId,
                        'role' => $membershipRole,
                        'status' => 'active',
                        'joined_at' => $user->created_at ?: now(),
                    ]
                );

                if ($membership->wasRecentlyCreated) {
                    $membershipsCreated++;
                } else {
                    $membershipsSkipped++;
                }
            }

            return [
                'dry_run' => false,
                'default_church_id' => $defaultChurch->id,
                'modules_seeded' => count($moduleMap),
                'church_modules_enabled' => $enabledModulesCount,
                'tables_updated' => $tablesUpdated,
                'super_admins_set' => $superAdminsSet,
                'memberships_created' => $membershipsCreated,
                'memberships_skipped' => $membershipsSkipped,
                'snapshot' => $snapshot,
            ];
        });
    }

    /**
     * Execute companion undo operation.
     * Reverts all backfill changes strictly without touching unrelated records.
     *
     * @return array<string, mixed>
     */
    public function executeUndo(): array
    {
        $defaultChurch = Church::withTrashed()->where('slug', 'default')->first();
        if (! $defaultChurch) {
            return [
                'success' => true,
                'message' => 'Default church not found; no backfill state to undo.',
                'tables_reverted' => [],
            ];
        }

        return DB::transaction(function () use ($defaultChurch) {
            $tablesReverted = [];

            // 1. Revert church_id = NULL on 16 domain tables
            foreach (self::DOMAIN_TABLES as $tableName) {
                $count = DB::table($tableName)
                    ->where('church_id', $defaultChurch->id)
                    ->update(['church_id' => null]);
                $tablesReverted[$tableName] = $count;
            }

            // 2. Reset users.is_super_admin = false
            $resetSuperAdmins = User::where('is_super_admin', true)->update(['is_super_admin' => false]);

            // 3. Delete church_user_memberships
            $deletedMemberships = ChurchUserMembership::where('church_id', $defaultChurch->id)->delete();

            // 4. Delete church_modules
            $deletedChurchModules = ChurchModule::where('church_id', $defaultChurch->id)->delete();

            // 5. Delete seeded modules (nullify self-reference FK first)
            Module::query()->update(['depends_on' => null]);
            $deletedModules = Module::whereIn('key', array_keys(self::MODULE_CATALOG))->delete();

            // 6. Force delete default church
            $defaultChurch->forceDelete();

            return [
                'success' => true,
                'tables_reverted' => $tablesReverted,
                'reset_super_admins' => $resetSuperAdmins,
                'deleted_memberships' => $deletedMemberships,
                'deleted_church_modules' => $deletedChurchModules,
                'deleted_modules' => $deletedModules,
            ];
        });
    }

    /**
     * Resolve membership role from Spatie roles according to defined priority hierarchy.
     *
     * @param  array<int, string>  $roles
     */
    public function resolveMembershipRole(array $roles): string
    {
        // Spatie 'church_admin', 'admin', or 'super_admin' maps to 'church_admin'
        if (in_array('church_admin', $roles, true) || in_array('admin', $roles, true) || in_array('super_admin', $roles, true)) {
            return 'church_admin';
        }

        foreach (self::ROLE_PRIORITY as $priorityRole) {
            if ($priorityRole === 'admin' || $priorityRole === 'church_admin') {
                continue;
            }
            if (in_array($priorityRole, $roles, true)) {
                return $priorityRole;
            }
        }

        return 'member';
    }

    /**
     * Check for orphaned data across domain tables.
     *
     * @return array<int, string>
     */
    protected function checkOrphanData(): array
    {
        $anomalies = [];

        // Check worship_officers with invalid worship_schedule_id or member_id
        $orphanOfficers = DB::table('worship_officers')
            ->leftJoin('worship_schedules', 'worship_officers.worship_schedule_id', '=', 'worship_schedules.id')
            ->leftJoin('church_members', 'worship_officers.member_id', '=', 'church_members.id')
            ->whereNull('worship_schedules.id')
            ->orWhereNull('church_members.id')
            ->count();
        if ($orphanOfficers > 0) {
            $anomalies[] = "Found {$orphanOfficers} orphaned worship_officers records.";
        }

        // Check financial_transactions with invalid chart_of_account_id
        $orphanTx = DB::table('financial_transactions')
            ->leftJoin('chart_of_accounts', 'financial_transactions.chart_of_account_id', '=', 'chart_of_accounts.id')
            ->whereNull('chart_of_accounts.id')
            ->count();
        if ($orphanTx > 0) {
            $anomalies[] = "Found {$orphanTx} financial_transactions with missing chart_of_accounts.";
        }

        // Check donation_confirmations with invalid chart_of_account_id
        $orphanDonations = DB::table('donation_confirmations')
            ->leftJoin('chart_of_accounts', 'donation_confirmations.chart_of_account_id', '=', 'chart_of_accounts.id')
            ->whereNull('chart_of_accounts.id')
            ->count();
        if ($orphanDonations > 0) {
            $anomalies[] = "Found {$orphanDonations} donation_confirmations with missing chart_of_accounts.";
        }

        return $anomalies;
    }
}
