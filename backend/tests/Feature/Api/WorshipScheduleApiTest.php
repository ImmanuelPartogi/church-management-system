<?php

namespace Tests\Feature\Api;

use App\Models\ChurchMember;
use App\Models\WorshipOfficer;
use App\Models\WorshipSchedule;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WorshipScheduleApiTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test active worship schedules endpoint.
     */
    public function test_can_retrieve_active_worship_schedules(): void
    {
        $schedule = WorshipSchedule::create([
            'title' => 'Sunday Service',
            'description' => 'Test Description',
            'day' => 'Sunday',
            'start_time' => '09:00:00',
            'end_time' => '11:00:00',
            'location' => 'Chapel',
            'active' => true,
        ]);

        $member = ChurchMember::create([
            'membership_number' => 'MEM-100',
            'full_name' => 'Worship Leader',
            'gender' => 'Male',
            'birth_date' => '1990-01-01',
            'phone' => '123',
            'email' => 'leader@example.com',
            'address' => 'Addr',
        ]);

        WorshipOfficer::create([
            'worship_schedule_id' => $schedule->id,
            'member_id' => $member->id,
            'role' => 'Singer',
        ]);

        $response = $this->getJson('/api/v1/worship-schedules');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'title',
                        'description',
                        'day',
                        'start_time',
                        'end_time',
                        'location',
                        'active',
                        'officers' => [
                            '*' => [
                                'id',
                                'role',
                                'member' => [
                                    'id',
                                    'full_name',
                                    'membership_number',
                                ],
                            ],
                        ],
                    ],
                ],
            ]);

        $this->assertCount(1, $response->json('data'));
        $this->assertEquals('Sunday Service', $response->json('data.0.title'));
        $this->assertEquals('Singer', $response->json('data.0.officers.0.role'));
    }

    /**
     * Test worship schedules grouped by day for calendar display.
     */
    public function test_can_retrieve_schedules_grouped_by_day(): void
    {
        WorshipSchedule::create([
            'title' => 'Sunday Service I',
            'description' => 'Desc I',
            'day' => 'Sunday',
            'start_time' => '07:00:00',
            'end_time' => '09:00:00',
            'location' => 'Main Sanctuary',
            'active' => true,
        ]);

        WorshipSchedule::create([
            'title' => 'Youth Fellowship',
            'description' => 'Youth Description',
            'day' => 'Saturday',
            'start_time' => '17:00:00',
            'end_time' => '19:00:00',
            'location' => 'Chapel',
            'active' => true,
        ]);

        $response = $this->getJson('/api/v1/worship-schedules/calendar');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'Sunday',
                    'Saturday',
                ],
            ]);

        $this->assertCount(1, $response->json('data.Sunday'));
        $this->assertCount(1, $response->json('data.Saturday'));
        $this->assertEquals('Sunday Service I', $response->json('data.Sunday.0.title'));
        $this->assertEquals('Youth Fellowship', $response->json('data.Saturday.0.title'));
    }
}
