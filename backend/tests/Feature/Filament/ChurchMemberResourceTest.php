<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\ChurchMemberResource;
use App\Models\ChurchMember;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class ChurchMemberResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
    }

    public function test_authorized_admin_can_render_church_member_resource_list(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        $member = ChurchMember::factory()->create(['user_id' => $admin->id]);

        $this->actingAs($admin)
            ->get(ChurchMemberResource::getUrl('index'))
            ->assertSuccessful();

        Livewire::actingAs($admin)
            ->test(ChurchMemberResource\Pages\ListChurchMembers::class)
            ->assertCanSeeTableRecords([$member]);
    }

    public function test_unauthorized_user_cannot_access_church_member_resource(): void
    {
        $user = User::factory()->create(); // no role / permissions

        $this->actingAs($user)
            ->get(ChurchMemberResource::getUrl('index'))
            ->assertForbidden();
    }

    public function test_admin_can_create_church_member(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        Livewire::actingAs($admin)
            ->test(ChurchMemberResource\Pages\CreateChurchMember::class)
            ->fillForm([
                'membership_number' => 'MEM-9999',
                'full_name' => 'John Doe',
                'gender' => 'Male',
                'birth_date' => '1990-01-01',
                'phone' => '08123456789',
                'email' => 'john.doe@example.com',
                'address' => 'Jakarta, Indonesia',
                'status' => 'active',
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas('church_members', [
            'membership_number' => 'MEM-9999',
            'full_name' => 'John Doe',
            'email' => 'john.doe@example.com',
        ]);
    }
}
