<?php

namespace Database\Seeders;

use App\Models\ChurchMember;
use App\Models\ChurchUserMembership;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class ChurchMemberSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $churchId = app('current_church_id') ?? 1;

        // 1. Create Pastor User and Profile
        $pastorUser = User::create([
            'name' => 'Rev. John Doe',
            'email' => 'pastor@church.org',
            'firebase_uid' => 'mock-pastor-uid',
            'password' => Hash::make('password123'),
        ]);
        $pastorUser->assignRole('pastor');

        $pastorMember = ChurchMember::create([
            'user_id' => $pastorUser->id,
            'membership_number' => 'MEM-2026-0001',
            'full_name' => 'Rev. John Doe',
            'gender' => 'Male',
            'birth_date' => '1975-04-12',
            'phone' => '+6281234567890',
            'email' => 'pastor@church.org',
            'address' => 'Jl. Kebon Sirih No. 10, Jakarta Pusat',
            'baptism_date' => '1995-12-25',
            'status' => 'active',
        ]);

        ChurchUserMembership::firstOrCreate(
            [
                'church_id' => $churchId,
                'user_id' => $pastorUser->id,
            ],
            [
                'church_member_id' => $pastorMember->id,
                'role' => 'pastor',
                'status' => 'active',
            ]
        );

        // 2. Create Staff User and Profile
        $staffUser = User::create([
            'name' => 'Jane Smith',
            'email' => 'staff@church.org',
            'firebase_uid' => 'mock-staff-uid',
            'password' => Hash::make('password123'),
        ]);
        $staffUser->assignRole('staff');

        $staffMember = ChurchMember::create([
            'user_id' => $staffUser->id,
            'membership_number' => 'MEM-2026-0002',
            'full_name' => 'Jane Smith',
            'gender' => 'Female',
            'birth_date' => '1988-08-20',
            'phone' => '+6281234567891',
            'email' => 'staff@church.org',
            'address' => 'Jl. Thamrin No. 45, Jakarta Pusat',
            'baptism_date' => '2005-04-10',
            'status' => 'active',
        ]);

        ChurchUserMembership::firstOrCreate(
            [
                'church_id' => $churchId,
                'user_id' => $staffUser->id,
            ],
            [
                'church_member_id' => $staffMember->id,
                'role' => 'staff',
                'status' => 'active',
            ]
        );

        // 2.1 Create Bendahara (Treasurer) User and Profile
        $bendaharaUser = User::create([
            'name' => 'Robert Siregar',
            'email' => 'bendahara@church.org',
            'firebase_uid' => 'mock-bendahara-uid',
            'password' => Hash::make('password123'),
        ]);
        $bendaharaUser->assignRole('bendahara');

        $bendaharaMember = ChurchMember::create([
            'user_id' => $bendaharaUser->id,
            'membership_number' => 'MEM-2026-0003',
            'full_name' => 'Robert Siregar',
            'gender' => 'Male',
            'birth_date' => '1982-11-10',
            'phone' => '+6281234567899',
            'email' => 'bendahara@church.org',
            'address' => 'Jl. Senayan No. 18, Jakarta Selatan',
            'baptism_date' => '2000-08-15',
            'status' => 'active',
        ]);

        ChurchUserMembership::firstOrCreate(
            [
                'church_id' => $churchId,
                'user_id' => $bendaharaUser->id,
            ],
            [
                'church_member_id' => $bendaharaMember->id,
                'role' => 'bendahara',
                'status' => 'active',
            ]
        );

        // 3. Create normal Member Users and Profiles
        $membersData = [
            [
                'name' => 'Michael Chang',
                'email' => 'michael@example.com',
                'firebase_uid' => 'mock-member1-uid',
                'gender' => 'Male',
                'birth_date' => '1992-03-15',
                'phone' => '+6281234567892',
                'address' => 'Jl. Sudirman No. 22, Jakarta Selatan',
                'baptism_date' => '2010-06-20',
                'status' => 'active',
            ],
            [
                'name' => 'Sarah Connor',
                'email' => 'sarah@example.com',
                'firebase_uid' => 'mock-member2-uid',
                'gender' => 'Female',
                'birth_date' => '1995-09-05',
                'phone' => '+6281234567893',
                'address' => 'Jl. Gatot Subroto No. 5, Jakarta Selatan',
                'baptism_date' => null,
                'status' => 'active',
            ],
        ];

        $index = 4;
        foreach ($membersData as $data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'firebase_uid' => $data['firebase_uid'],
                'password' => Hash::make('password123'),
            ]);
            $user->assignRole('member');

            $member = ChurchMember::create([
                'user_id' => $user->id,
                'membership_number' => 'MEM-2026-'.str_pad((string) $index, 4, '0', STR_PAD_LEFT),
                'full_name' => $data['name'],
                'gender' => $data['gender'],
                'birth_date' => $data['birth_date'],
                'phone' => $data['phone'],
                'email' => $data['email'],
                'address' => $data['address'],
                'baptism_date' => $data['baptism_date'],
                'status' => $data['status'],
            ]);

            ChurchUserMembership::firstOrCreate(
                [
                    'church_id' => $churchId,
                    'user_id' => $user->id,
                ],
                [
                    'church_member_id' => $member->id,
                    'role' => 'member',
                    'status' => 'active',
                ]
            );

            $index++;
        }

        // 4. Create some members who do NOT have user accounts (offline/older members)
        $offlineMembers = [
            [
                'full_name' => 'Budi Santoso',
                'gender' => 'Male',
                'birth_date' => '1950-11-30',
                'phone' => '+6281234567894',
                'email' => 'budi.santoso@example.com',
                'address' => 'Jl. Diponegoro No. 12, Menteng, Jakarta Pusat',
                'baptism_date' => '1970-05-15',
                'status' => 'active',
            ],
            [
                'full_name' => 'Maria Utami',
                'gender' => 'Female',
                'birth_date' => '1962-01-25',
                'phone' => '+6281234567895',
                'email' => 'maria.utami@example.com',
                'address' => 'Jl. Rasuna Said No. 100, Jakarta Selatan',
                'baptism_date' => '1980-08-17',
                'status' => 'active',
            ],
        ];

        foreach ($offlineMembers as $data) {
            ChurchMember::create([
                'user_id' => null,
                'membership_number' => 'MEM-2026-'.str_pad((string) $index, 4, '0', STR_PAD_LEFT),
                'full_name' => $data['full_name'],
                'gender' => $data['gender'],
                'birth_date' => $data['birth_date'],
                'phone' => $data['phone'],
                'email' => $data['email'],
                'address' => $data['address'],
                'baptism_date' => $data['baptism_date'],
                'status' => $data['status'],
            ]);
            $index++;
        }
    }
}
