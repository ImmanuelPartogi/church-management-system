<?php

namespace Database\Seeders;

use App\Models\ChurchMember;
use App\Models\WorshipOfficer;
use App\Models\WorshipSchedule;
use Illuminate\Database\Seeder;

class WorshipScheduleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Sunday General Service I
        $service1 = WorshipSchedule::create([
            'title' => 'Sunday Service I',
            'description' => 'General Worship Service Session 1',
            'day' => 'Sunday',
            'start_time' => '07:00:00',
            'end_time' => '09:00:00',
            'location' => 'Main Sanctuary',
            'active' => true,
        ]);

        // 2. Sunday General Service II
        $service2 = WorshipSchedule::create([
            'title' => 'Sunday Service II',
            'description' => 'General Worship Service Session 2',
            'day' => 'Sunday',
            'start_time' => '10:00:00',
            'end_time' => '12:00:00',
            'location' => 'Main Sanctuary',
            'active' => true,
        ]);

        // 3. Saturday Youth Service
        $youthService = WorshipSchedule::create([
            'title' => 'Youth Service',
            'description' => 'Youth and Young Adults Fellowship',
            'day' => 'Saturday',
            'start_time' => '17:00:00',
            'end_time' => '19:00:00',
            'location' => 'Chapel Room B',
            'active' => true,
        ]);

        // Fetch some members to assign as officers
        $pastor = ChurchMember::where('full_name', 'Rev. John Doe')->first();
        $staff = ChurchMember::where('full_name', 'Jane Smith')->first();
        $member1 = ChurchMember::where('full_name', 'Michael Chang')->first();
        $member2 = ChurchMember::where('full_name', 'Sarah Connor')->first();

        // Assign officers for Service I
        if ($pastor) {
            WorshipOfficer::create([
                'worship_schedule_id' => $service1->id,
                'member_id' => $pastor->id,
                'role' => 'Preacher',
            ]);
        }
        if ($staff) {
            WorshipOfficer::create([
                'worship_schedule_id' => $service1->id,
                'member_id' => $staff->id,
                'role' => 'Liturgist',
            ]);
        }
        if ($member1) {
            WorshipOfficer::create([
                'worship_schedule_id' => $service1->id,
                'member_id' => $member1->id,
                'role' => 'Musician',
            ]);
        }

        // Assign officers for Service II
        if ($pastor) {
            WorshipOfficer::create([
                'worship_schedule_id' => $service2->id,
                'member_id' => $pastor->id,
                'role' => 'Preacher',
            ]);
        }
        if ($member2) {
            WorshipOfficer::create([
                'worship_schedule_id' => $service2->id,
                'member_id' => $member2->id,
                'role' => 'Liturgist',
            ]);
        }
    }
}
