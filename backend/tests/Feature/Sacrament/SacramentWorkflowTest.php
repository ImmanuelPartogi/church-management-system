<?php

namespace Tests\Feature\Sacrament;

use App\Enums\ServiceFormStatus;
use App\Models\Church;
use App\Models\ChurchMember;
use App\Models\ChurchServant;
use App\Models\Sector;
use App\Models\ServiceFormApplication;
use App\Models\ServiceFormType;
use App\Models\User;
use App\Observers\ChurchServantObserver;
use App\Services\Sacrament\SacramentWorkflowService;
use Database\Seeders\RolesAndPermissionsSeeder;
use DomainException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class SacramentWorkflowTest extends TestCase
{
    use RefreshDatabase;

    protected SacramentWorkflowService $service;

    protected Church $church;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
        $this->service = app(SacramentWorkflowService::class);
        $this->church = app('current_church');
    }

    public function test_full_sacrament_lifecycle_submit_to_complete(): void
    {
        $sector = Sector::factory()->create();

        // 1. Applicant Member
        $applicantUser = User::factory()->create();
        $applicantMember = ChurchMember::factory()->create([
            'user_id' => $applicantUser->id,
            'sector_id' => $sector->id,
            'baptism_date' => null,
        ]);

        // 2. Sintua Verifier
        $sintuaUser = User::factory()->create();
        $sintuaMember = ChurchMember::factory()->create(['user_id' => $sintuaUser->id]);
        $sintuaServant = ChurchServant::factory()->create([
            'member_id' => $sintuaMember->id,
            'role' => 'sintua',
            'active' => true,
        ]);
        $sintuaServant->assignedSectors()->attach($sector->id, ['church_id' => $this->church->id]);

        // 3. Lead Pastor
        $pastorUser = User::factory()->create();
        $pastorMember = ChurchMember::factory()->create(['user_id' => $pastorUser->id]);
        ChurchServant::factory()->create([
            'member_id' => $pastorMember->id,
            'role' => 'pdt_resort',
            'is_lead_pastor' => true,
            'active' => true,
        ]);

        // 4. Sacrament Form Type (Baptis)
        $formType = ServiceFormType::factory()->create([
            'name' => 'Baptis Kudus',
            'slug' => 'baptis',
            'is_sacrament' => true,
        ]);

        $app = ServiceFormApplication::factory()->create([
            'service_form_type_id' => $formType->id,
            'status' => ServiceFormStatus::Pending,
        ]);

        // Step 1: Submit
        $this->service->submit($app, $applicantUser);
        $this->assertEquals(ServiceFormStatus::Pending, $app->fresh()->status);
        $this->assertEquals($applicantMember->id, $app->fresh()->member_id);

        // Step 2: Verify Sector
        $this->service->verifySector($app, $sintuaUser);
        $app->refresh();
        $this->assertEquals(ServiceFormStatus::SectorVerified, $app->status);
        $this->assertEquals($sintuaUser->id, $app->sector_reviewed_by);
        $this->assertNotNull($app->sector_reviewed_at);

        // Step 3: Pastoral Approval
        $this->service->approvePastoral($app, $pastorUser);
        $app->refresh();
        $this->assertEquals(ServiceFormStatus::PastorApproved, $app->status);
        $this->assertEquals($pastorUser->id, $app->pastor_reviewed_by);
        $this->assertNotNull($app->pastor_reviewed_at);

        // Step 4: Complete
        $this->service->complete($app);
        $app->refresh();
        $this->assertEquals(ServiceFormStatus::Completed, $app->status);
        $this->assertNotNull($app->sacrament_completed_at);
        $this->assertEquals(now()->toDateString(), $applicantMember->fresh()->baptism_date?->toDateString());
    }

    public function test_submit_fails_loud_when_user_has_no_member_profile(): void
    {
        $selfRegisteredUser = User::factory()->create(); // No member linked

        $formType = ServiceFormType::factory()->create(['is_sacrament' => true]);
        $app = ServiceFormApplication::factory()->create([
            'service_form_type_id' => $formType->id,
            'status' => ServiceFormStatus::Pending,
        ]);

        $this->expectException(DomainException::class);
        $this->expectExceptionMessage('Akun Anda belum tertaut ke profil keanggotaan jemaat. Hubungi admin gereja untuk penautan sebelum mengajukan sakramen.');

        $this->service->submit($app, $selfRegisteredUser);
    }

    public function test_submit_fails_loud_when_church_requires_sector_but_member_has_no_sector(): void
    {
        $this->church->update(['requires_sector_verification' => true]);

        $user = User::factory()->create();
        ChurchMember::factory()->create([
            'user_id' => $user->id,
            'sector_id' => null, // No sector assigned
        ]);

        $formType = ServiceFormType::factory()->create(['is_sacrament' => true]);
        $app = ServiceFormApplication::factory()->create([
            'service_form_type_id' => $formType->id,
            'status' => ServiceFormStatus::Pending,
        ]);

        $this->expectException(DomainException::class);
        $this->expectExceptionMessage('Profil keanggotaan Anda belum terdaftar dalam sektor manapun. Hubungi admin gereja untuk pembaruan sektor sebelum mengajukan sakramen.');

        $this->service->submit($app, $user);
    }

    public function test_submit_bypasses_sector_verification_when_church_disables_it(): void
    {
        $this->church->update(['requires_sector_verification' => false]);

        $user = User::factory()->create();
        ChurchMember::factory()->create([
            'user_id' => $user->id,
            'sector_id' => null,
        ]);

        $pastorUser = User::factory()->create();
        $pastorMember = ChurchMember::factory()->create(['user_id' => $pastorUser->id]);
        ChurchServant::factory()->create([
            'member_id' => $pastorMember->id,
            'is_lead_pastor' => true,
            'active' => true,
        ]);

        $formType = ServiceFormType::factory()->create(['is_sacrament' => true]);
        $app = ServiceFormApplication::factory()->create([
            'service_form_type_id' => $formType->id,
            'status' => ServiceFormStatus::Pending,
        ]);

        // Submit directly transitions to SectorVerified
        $this->service->submit($app, $user);
        $this->assertEquals(ServiceFormStatus::SectorVerified, $app->fresh()->status);

        // Lead Pastor can directly approve without Sintua
        $this->service->approvePastoral($app, $pastorUser);
        $this->assertEquals(ServiceFormStatus::PastorApproved, $app->fresh()->status);
    }

    public function test_sintua_from_different_sector_cannot_verify_application(): void
    {
        $sectorA = Sector::factory()->create(['name' => 'Sektor A']);
        $sectorB = Sector::factory()->create(['name' => 'Sektor B']);

        $applicantUser = User::factory()->create();
        ChurchMember::factory()->create([
            'user_id' => $applicantUser->id,
            'sector_id' => $sectorA->id,
        ]);

        // Sintua only assigned to Sector B
        $sintuaUser = User::factory()->create();
        $sintuaMember = ChurchMember::factory()->create(['user_id' => $sintuaUser->id]);
        $sintuaServant = ChurchServant::factory()->create([
            'member_id' => $sintuaMember->id,
            'role' => 'sintua',
            'active' => true,
        ]);
        $sintuaServant->assignedSectors()->attach($sectorB->id, ['church_id' => $this->church->id]);

        $formType = ServiceFormType::factory()->create(['is_sacrament' => true]);
        $app = ServiceFormApplication::factory()->create([
            'service_form_type_id' => $formType->id,
            'status' => ServiceFormStatus::Pending,
        ]);
        $this->service->submit($app, $applicantUser);

        $this->expectException(DomainException::class);
        $this->expectExceptionMessage('Sintua hanya dapat memverifikasi permohonan sakramen jemaat di sektor binaannya.');

        $this->service->verifySector($app, $sintuaUser);
    }

    public function test_non_lead_pastor_cannot_approve_pastoral(): void
    {
        $sector = Sector::factory()->create();

        $applicantUser = User::factory()->create();
        ChurchMember::factory()->create([
            'user_id' => $applicantUser->id,
            'sector_id' => $sector->id,
        ]);

        // Assistant pastor with is_lead_pastor = false
        $assistantPastor = User::factory()->create();
        $assistantMember = ChurchMember::factory()->create(['user_id' => $assistantPastor->id]);
        ChurchServant::factory()->create([
            'member_id' => $assistantMember->id,
            'role' => 'pdt_resort',
            'is_lead_pastor' => false,
            'active' => true,
        ]);

        $formType = ServiceFormType::factory()->create(['is_sacrament' => true]);
        $app = ServiceFormApplication::factory()->create([
            'service_form_type_id' => $formType->id,
            'status' => ServiceFormStatus::SectorVerified,
        ]);

        $this->expectException(DomainException::class);
        $this->expectExceptionMessage('Hanya Pendeta Ressort / Pimpinan Jemaat yang berwenang mengesahkan sakramen.');

        $this->service->approvePastoral($app, $assistantPastor);
    }

    public function test_rejection_requires_non_empty_reason_and_updates_status(): void
    {
        $formType = ServiceFormType::factory()->create(['is_sacrament' => true]);
        $app = ServiceFormApplication::factory()->create([
            'service_form_type_id' => $formType->id,
            'status' => ServiceFormStatus::Pending,
        ]);
        $reviewer = User::factory()->create();

        // 1. Empty reason rejected
        try {
            $this->service->reject($app, $reviewer, '   ');
            $this->fail('Expected DomainException for empty rejection reason');
        } catch (DomainException $e) {
            $this->assertEquals('Alasan penolakan permohonan sakramen wajib diisi.', $e->getMessage());
        }

        // 2. Valid reason accepted
        $this->service->reject($app, $reviewer, 'Dokumen surat pengantar tidak lengkap.');
        $app->refresh();
        $this->assertEquals(ServiceFormStatus::Rejected, $app->status);
        $this->assertEquals('Dokumen surat pengantar tidak lengkap.', $app->rejection_reason);
        $this->assertEquals($reviewer->id, $app->reviewed_by);
    }

    public function test_non_sacrament_application_is_rejected_by_sacrament_workflow(): void
    {
        $nonSacramentType = ServiceFormType::factory()->create(['is_sacrament' => false]);
        $app = ServiceFormApplication::factory()->create([
            'service_form_type_id' => $nonSacramentType->id,
            'status' => ServiceFormStatus::Pending,
        ]);
        $user = User::factory()->create();

        $this->expectException(DomainException::class);
        $this->expectExceptionMessage('Alur persetujuan berjenjang hanya berlaku untuk formulir sakramen.');

        $this->service->submit($app, $user);
    }

    public function test_sidi_sacrament_completion_updates_sidi_date(): void
    {
        $user = User::factory()->create();
        $member = ChurchMember::factory()->create([
            'user_id' => $user->id,
            'sidi_date' => null,
        ]);

        $formType = ServiceFormType::factory()->create([
            'slug' => 'sidi',
            'is_sacrament' => true,
        ]);

        $app = ServiceFormApplication::factory()->create([
            'service_form_type_id' => $formType->id,
            'member_id' => $member->id,
            'status' => ServiceFormStatus::PastorApproved,
        ]);

        $this->service->complete($app);

        $this->assertEquals(ServiceFormStatus::Completed, $app->fresh()->status);
        $this->assertEquals(now()->toDateString(), $member->fresh()->sidi_date?->toDateString());
    }

    public function test_church_servant_observer_auto_syncs_sintua_spatie_role(): void
    {
        $user = User::factory()->create();
        $member = ChurchMember::factory()->create(['user_id' => $user->id]);

        // Create active sintua servant -> role assigned
        $servant = ChurchServant::factory()->create([
            'member_id' => $member->id,
            'role' => 'sintua',
            'active' => true,
        ]);

        $this->assertTrue($user->fresh()->hasRole('sintua'));

        // Deactivate servant -> role revoked
        $servant->update(['active' => false]);
        $this->assertFalse($user->fresh()->hasRole('sintua'));

        // Reactivate servant -> role reassigned
        $servant->update(['active' => true]);
        $this->assertTrue($user->fresh()->hasRole('sintua'));
    }

    public function test_service_form_application_policy_gates(): void
    {
        $sectorA = Sector::factory()->create(['name' => 'Sektor Alfa']);
        $sectorB = Sector::factory()->create(['name' => 'Sektor Beta']);

        $sacramentType = ServiceFormType::factory()->create(['is_sacrament' => true]);
        $nonSacramentType = ServiceFormType::factory()->create(['is_sacrament' => false]);

        $applicant = ChurchMember::factory()->create(['sector_id' => $sectorA->id]);
        $sacramentApp = ServiceFormApplication::factory()->create([
            'service_form_type_id' => $sacramentType->id,
            'member_id' => $applicant->id,
        ]);
        $nonSacramentApp = ServiceFormApplication::factory()->create([
            'service_form_type_id' => $nonSacramentType->id,
            'member_id' => $applicant->id,
        ]);

        // Sintua with sector A
        $sintuaUser = User::factory()->create();
        $sintuaUser->givePermissionTo('verify sectoral sacraments');
        $sintuaMember = ChurchMember::factory()->create(['user_id' => $sintuaUser->id]);
        $sintuaServant = ChurchServant::factory()->create([
            'member_id' => $sintuaMember->id,
            'role' => 'sintua',
            'active' => true,
        ]);
        $sintuaServant->assignedSectors()->attach($sectorA->id, ['church_id' => $this->church->id]);

        // Policy verifySector: true for sacrament in sector A, false for non-sacrament
        $this->assertTrue($sintuaUser->can('verifySector', $sacramentApp));
        $this->assertFalse($sintuaUser->can('verifySector', $nonSacramentApp));

        // Lead Pastor
        $leadPastorUser = User::factory()->create();
        $leadPastorUser->givePermissionTo('approve final sacraments');
        $leadPastorMember = ChurchMember::factory()->create(['user_id' => $leadPastorUser->id]);
        ChurchServant::factory()->create([
            'member_id' => $leadPastorMember->id,
            'role' => 'pdt_resort',
            'is_lead_pastor' => true,
            'active' => true,
        ]);

        // Assistant Pastor
        $assistantPastorUser = User::factory()->create();
        $assistantPastorUser->givePermissionTo('approve final sacraments');
        $assistantPastorMember = ChurchMember::factory()->create(['user_id' => $assistantPastorUser->id]);
        ChurchServant::factory()->create([
            'member_id' => $assistantPastorMember->id,
            'role' => 'pdt_resort',
            'is_lead_pastor' => false,
            'active' => true,
        ]);

        $this->assertTrue($leadPastorUser->can('approvePastoral', $sacramentApp));
        $this->assertFalse($assistantPastorUser->can('approvePastoral', $sacramentApp));
        $this->assertFalse($leadPastorUser->can('approvePastoral', $nonSacramentApp));
    }

    public function test_servant_observer_syncs_sintua_role_lifecycle_including_defensive_restored(): void
    {
        $user = User::factory()->create();
        $member = ChurchMember::factory()->create(['user_id' => $user->id]);

        $this->assertFalse($user->hasRole('sintua'));

        // 1. Create active sintua servant -> auto assigns 'sintua' role
        $servant = ChurchServant::factory()->create([
            'member_id' => $member->id,
            'role' => 'sintua',
            'active' => true,
        ]);

        $this->assertTrue($user->fresh()->hasRole('sintua'));

        // 2. Deactivate servant -> revokes 'sintua' role
        $servant->update(['active' => false]);
        $this->assertFalse($user->fresh()->hasRole('sintua'));

        // 3. Reactivate servant -> re-assigns 'sintua' role
        $servant->update(['active' => true]);
        $this->assertTrue($user->fresh()->hasRole('sintua'));

        // 4. Defensive restored hook -> ensures role stays synced
        app(ChurchServantObserver::class)->restored($servant);
        $this->assertTrue($user->fresh()->hasRole('sintua'));

        // 5. Delete servant -> revokes 'sintua' role
        $servant->delete();
        $this->assertFalse($user->fresh()->hasRole('sintua'));
    }

    public function test_is_lead_pastor_authorization_is_enforced_via_domain_policy_without_direct_spatie_permission_pollution(): void
    {
        $pastorUser = User::factory()->create();
        $pastorUser->assignRole('pastor');
        $pastorMember = ChurchMember::factory()->create(['user_id' => $pastorUser->id]);

        // Creating lead pastor servant
        $servant = ChurchServant::factory()->create([
            'member_id' => $pastorMember->id,
            'role' => 'pdt_resort',
            'is_lead_pastor' => true,
            'active' => true,
        ]);

        // Assert no direct model permission pollution in model_has_permissions
        $directPermissions = DB::table('model_has_permissions')
            ->where('model_id', $pastorUser->id)
            ->where('model_type', User::class)
            ->count();
        $this->assertSame(0, $directPermissions, 'Direct model permissions should not be created; RBAC role inheritance must be used.');

        $sacramentType = ServiceFormType::factory()->create(['is_sacrament' => true]);
        $sacramentApp = ServiceFormApplication::factory()->create([
            'service_form_type_id' => $sacramentType->id,
        ]);

        // Authorized as lead pastor
        $this->assertTrue($pastorUser->can('approvePastoral', $sacramentApp));

        // Immediately revoked if lead pastor flag is removed
        $servant->update(['is_lead_pastor' => false]);
        $this->assertFalse($pastorUser->fresh()->can('approvePastoral', $sacramentApp));
    }
}
