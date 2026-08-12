<?php

namespace Tests\Feature\Filament;

use App\Enums\PrayerRequestStatus;
use App\Filament\Resources\PrayerRequestResource;
use App\Models\ChurchMember;
use App\Models\PrayerRequest;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class PrayerRequestResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_admin_can_render_prayer_request_list(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $user = User::factory()->create();
        $member = ChurchMember::factory()->create(['user_id' => $user->id]);

        $request = PrayerRequest::factory()->create([
            'user_id' => $user->id,
            'member_id' => $member->id,
            'is_private' => false,
        ]);

        $this->actingAs($admin)
            ->get(PrayerRequestResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($admin)
            ->test(PrayerRequestResource\Pages\ListPrayerRequests::class)
            ->assertCanSeeTableRecords([$request]);
    }

    public function test_private_prayer_request_hidden_from_staff_lacking_private_permission(): void
    {
        $staff = User::factory()->create();
        $staff->assignRole('staff');

        $user = User::factory()->create();
        $member = ChurchMember::factory()->create(['user_id' => $user->id]);

        $publicRequest = PrayerRequest::factory()->create([
            'user_id' => $user->id,
            'member_id' => $member->id,
            'is_private' => false,
        ]);

        $privateRequest = PrayerRequest::factory()->create([
            'user_id' => $user->id,
            'member_id' => $member->id,
            'is_private' => true,
        ]);

        Livewire::actingAs($staff)
            ->test(PrayerRequestResource\Pages\ListPrayerRequests::class)
            ->assertCanSeeTableRecords([$publicRequest])
            ->assertCanNotSeeTableRecords([$privateRequest]);
    }

    public function test_pastor_can_see_private_prayer_requests(): void
    {
        $pastor = User::factory()->create();
        $pastor->assignRole('pastor');

        $user = User::factory()->create();
        $member = ChurchMember::factory()->create(['user_id' => $user->id]);

        $privateRequest = PrayerRequest::factory()->create([
            'user_id' => $user->id,
            'member_id' => $member->id,
            'is_private' => true,
        ]);

        Livewire::actingAs($pastor)
            ->test(PrayerRequestResource\Pages\ListPrayerRequests::class)
            ->assertCanSeeTableRecords([$privateRequest]);
    }

    public function test_admin_can_follow_up_prayer_request(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $user = User::factory()->create();
        $member = ChurchMember::factory()->create(['user_id' => $user->id]);

        $request = PrayerRequest::factory()->create([
            'user_id' => $user->id,
            'member_id' => $member->id,
            'status' => PrayerRequestStatus::Submitted,
        ]);

        Livewire::actingAs($admin)
            ->test(PrayerRequestResource\Pages\ListPrayerRequests::class)
            ->callTableAction('markFollowedUp', $request, [
                'follow_up_notes' => 'Sudah didoakan dan dikunjungi oleh Sintua.',
            ]);

        $this->assertEquals(PrayerRequestStatus::FollowedUp, $request->fresh()->status);
        $this->assertEquals('Sudah didoakan dan dikunjungi oleh Sintua.', $request->fresh()->follow_up_notes);
        $this->assertEquals($admin->id, $request->fresh()->followed_up_by);
    }
}
