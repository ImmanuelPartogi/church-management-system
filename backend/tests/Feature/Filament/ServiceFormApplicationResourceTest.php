<?php

namespace Tests\Feature\Filament;

use App\Enums\ServiceFormStatus;
use App\Filament\Resources\ServiceFormApplicationResource;
use App\Models\ChurchMember;
use App\Models\ServiceFormApplication;
use App\Models\ServiceFormType;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class ServiceFormApplicationResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_admin_can_render_applications_list(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('church_admin');

        $user = User::factory()->create();
        $member = ChurchMember::factory()->create(['user_id' => $user->id]);
        $type = ServiceFormType::factory()->create();

        $application = ServiceFormApplication::factory()->create([
            'user_id' => $user->id,
            'member_id' => $member->id,
            'service_form_type_id' => $type->id,
        ]);

        $this->actingAs($admin)
            ->get(ServiceFormApplicationResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($admin)
            ->test(ServiceFormApplicationResource\Pages\ListServiceFormApplications::class)
            ->assertCanSeeTableRecords([$application]);
    }

    public function test_unauthorized_user_cannot_access_applications(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->get(ServiceFormApplicationResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_admin_can_process_and_approve_application(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('church_admin');

        $user = User::factory()->create();
        $member = ChurchMember::factory()->create(['user_id' => $user->id]);
        $type = ServiceFormType::factory()->create();

        $application = ServiceFormApplication::factory()->create([
            'user_id' => $user->id,
            'member_id' => $member->id,
            'service_form_type_id' => $type->id,
            'status' => ServiceFormStatus::Pending,
        ]);

        Livewire::actingAs($admin)
            ->test(ServiceFormApplicationResource\Pages\ListServiceFormApplications::class)
            ->callTableAction('process', $application);

        $this->assertEquals(ServiceFormStatus::Processing, $application->fresh()->status);

        Livewire::actingAs($admin)
            ->test(ServiceFormApplicationResource\Pages\ListServiceFormApplications::class)
            ->callTableAction('approve', $application->fresh());

        $this->assertEquals(ServiceFormStatus::Approved, $application->fresh()->status);
        $this->assertEquals($admin->id, $application->fresh()->reviewed_by);
    }
}
