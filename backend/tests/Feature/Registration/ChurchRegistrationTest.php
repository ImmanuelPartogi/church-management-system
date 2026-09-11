<?php

namespace Tests\Feature\Registration;

use App\Filament\Resources\ChurchRegistrationResource;
use App\Models\Church;
use App\Models\ChurchModule;
use App\Models\ChurchRegistration;
use App\Models\User;
use App\Notifications\Registration\ChurchRegistrationApprovedNotification;
use App\Notifications\Registration\ChurchRegistrationRejectedNotification;
use App\Notifications\Registration\ChurchRegistrationVerifyNotification;
use App\Services\Registration\ChurchRegistrationService;
use Database\Seeders\ModuleSeeder;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

class ChurchRegistrationTest extends TestCase
{
    use RefreshDatabase;

    protected User $superAdmin;

    protected User $churchAdmin;

    protected Church $defaultChurch;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(RolesAndPermissionsSeeder::class);
        $this->seed(ModuleSeeder::class);

        $this->defaultChurch = Church::first();

        $this->superAdmin = User::create([
            'name' => 'Super Admin',
            'email' => 'superadmin@synod.org',
            'password' => bcrypt('password'),
            'is_super_admin' => true,
        ]);

        $this->churchAdmin = User::create([
            'name' => 'Regular Admin',
            'email' => 'admin@church.org',
            'password' => bcrypt('password'),
            'is_super_admin' => false,
        ]);
        $this->defaultChurch->memberships()->create([
            'user_id' => $this->churchAdmin->id,
            'role' => 'church_admin',
            'status' => 'active',
        ]);
    }

    public function test_public_registration_endpoint_submits_and_requires_email_verification(): void
    {
        Notification::fake();

        $payload = [
            'church_name' => 'HKBP Balige Kota',
            'slug' => 'hkbp-balige-kota',
            'city' => 'Balige',
            'address' => 'Jl. Gereja No. 1',
            'phone' => '081234567890',
            'timezone' => 'Asia/Jakarta',
            'applicant_name' => 'Pendeta Balige',
            'applicant_email' => 'pendeta@balige.org',
            'applicant_phone' => '081234567891',
            'password' => 'secret12345',
            'password_confirmation' => 'secret12345',
        ];

        $response = $this->postJson('/api/v1/public/church-registration', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('data.church_name', 'HKBP Balige Kota')
            ->assertJsonPath('data.slug', 'hkbp-balige-kota')
            ->assertJsonPath('data.status', 'pending_email_verification')
            ->assertJsonPath('data.is_existing_user', false);

        // Assert record exists in church_registrations but NOT in churches
        $this->assertDatabaseHas('church_registrations', [
            'church_name' => 'HKBP Balige Kota',
            'slug' => 'hkbp-balige-kota',
            'applicant_email' => 'pendeta@balige.org',
            'status' => 'pending_email_verification',
        ]);
        $this->assertDatabaseMissing('churches', [
            'slug' => 'hkbp-balige-kota',
        ]);

        Notification::assertSentOnDemand(
            ChurchRegistrationVerifyNotification::class,
            function (ChurchRegistrationVerifyNotification $notification, array $channels, object $notifiable) {
                return $notifiable->routes['mail'] === 'pendeta@balige.org'
                    && $notification->registration->slug === 'hkbp-balige-kota';
            }
        );
    }

    public function test_registration_detects_existing_user_at_submit_time_and_records_id(): void
    {
        Notification::fake();

        // Existing user in system
        $existingUser = User::create([
            'name' => 'Existing Pastor',
            'email' => 'pastor.existing@hkbp.org',
            'password' => bcrypt('secret123'),
            'is_super_admin' => false,
        ]);

        $payload = [
            'church_name' => 'HKBP Pos Pelayanan Baru',
            'slug' => 'hkbp-pos-pelayanan-baru',
            'applicant_name' => 'Existing Pastor',
            'applicant_email' => 'pastor.existing@hkbp.org',
            'password' => 'secret12345',
            'password_confirmation' => 'secret12345',
        ];

        $response = $this->postJson('/api/v1/public/church-registration', $payload);

        $response->assertStatus(201)
            ->assertJsonPath('data.is_existing_user', true);

        $registration = ChurchRegistration::where('slug', 'hkbp-pos-pelayanan-baru')->firstOrFail();
        $this->assertSame($existingUser->id, $registration->existing_user_id);
        $this->assertTrue($registration->isExistingUser());
    }

    public function test_registration_blocks_reserved_slugs(): void
    {
        $payload = [
            'church_name' => 'Admin Church',
            'slug' => 'admin',
            'applicant_name' => 'Hacker Wannabe',
            'applicant_email' => 'hacker@example.com',
            'password' => 'secret12345',
            'password_confirmation' => 'secret12345',
        ];

        $response = $this->postJson('/api/v1/public/church-registration', $payload);
        $response->assertStatus(422)
            ->assertJsonValidationErrors('slug');
    }

    public function test_registration_enforces_slug_uniqueness_against_existing_churches_and_pending_registrations(): void
    {
        // 1. Conflict with active church
        $payload1 = [
            'church_name' => 'Default Church Duplicate',
            'slug' => $this->defaultChurch->slug,
            'applicant_name' => 'Pastor John',
            'applicant_email' => 'john@example.com',
            'password' => 'secret12345',
            'password_confirmation' => 'secret12345',
        ];
        $response1 = $this->postJson('/api/v1/public/church-registration', $payload1);
        $response1->assertStatus(422)
            ->assertJsonValidationErrors('slug');

        // 2. Conflict with another pending registration
        ChurchRegistration::create([
            'church_name' => 'HKBP Sibolga',
            'slug' => 'hkbp-sibolga',
            'applicant_name' => 'Pastor Sibolga',
            'applicant_email' => 'sibolga@example.com',
            'applicant_password_hash' => bcrypt('password'),
            'status' => 'pending_review',
        ]);

        $payload2 = [
            'church_name' => 'HKBP Sibolga Second Request',
            'slug' => 'hkbp-sibolga',
            'applicant_name' => 'Another Pastor',
            'applicant_email' => 'another@example.com',
            'password' => 'secret12345',
            'password_confirmation' => 'secret12345',
        ];
        $response2 = $this->postJson('/api/v1/public/church-registration', $payload2);
        $response2->assertStatus(422)
            ->assertJsonValidationErrors('slug');
    }

    public function test_race_condition_unique_slug_insert_caught_and_returns_friendly_validation_error(): void
    {
        Notification::fake();

        // Create an initial registration directly in DB with slug 'hkbp-race'
        ChurchRegistration::create([
            'church_name' => 'HKBP Race First',
            'slug' => 'hkbp-race',
            'applicant_name' => 'Pastor First',
            'applicant_email' => 'first@example.com',
            'applicant_password_hash' => bcrypt('password'),
            'status' => 'pending_email_verification',
        ]);

        // Now call the service directly with the same slug to simulate losing a race condition
        // (bypassing the form request validation layer)
        $service = app(ChurchRegistrationService::class);

        $this->expectException(ValidationException::class);

        try {
            $service->submit([
                'church_name' => 'HKBP Race Second',
                'slug' => 'hkbp-race',
                'applicant_name' => 'Pastor Second',
                'applicant_email' => 'second@example.com',
                'password' => 'secret12345',
            ]);
        } catch (ValidationException $e) {
            $this->assertArrayHasKey('slug', $e->errors());
            $this->assertStringContainsString('baru saja digunakan oleh pendaftar lain', $e->errors()['slug'][0]);
            throw $e;
        }
    }

    public function test_signed_email_verification_link_transitions_status_to_pending_review(): void
    {
        $registration = ChurchRegistration::create([
            'church_name' => 'HKBP Tarutung',
            'slug' => 'hkbp-tarutung',
            'applicant_name' => 'Pastor Tarutung',
            'applicant_email' => 'tarutung@example.com',
            'applicant_password_hash' => bcrypt('password'),
            'status' => 'pending_email_verification',
        ]);

        // Generate authoritative signed route
        $signedUrl = URL::temporarySignedRoute(
            'public.church-registration.verify',
            now()->addHours(24),
            ['registration' => $registration->id]
        );

        $response = $this->getJson($signedUrl);

        $response->assertStatus(200)
            ->assertJsonPath('status', 'pending_review');

        $registration->refresh();
        $this->assertSame('pending_review', $registration->status);
        $this->assertNotNull($registration->verified_at);
    }

    public function test_tampered_or_expired_email_verification_link_is_rejected(): void
    {
        $registration = ChurchRegistration::create([
            'church_name' => 'HKBP Laguboti',
            'slug' => 'hkbp-laguboti',
            'applicant_name' => 'Pastor Laguboti',
            'applicant_email' => 'laguboti@example.com',
            'applicant_password_hash' => bcrypt('password'),
            'status' => 'pending_email_verification',
        ]);

        // 1. Unsigned request
        $response1 = $this->getJson("/api/v1/public/church-registration/verify/{$registration->id}");
        $response1->assertStatus(403);

        // 2. Expired signed request (expired 1 hour ago)
        $expiredUrl = URL::temporarySignedRoute(
            'public.church-registration.verify',
            now()->subHour(),
            ['registration' => $registration->id]
        );
        $response2 = $this->getJson($expiredUrl);
        $response2->assertStatus(403);

        // Registration remains unverified
        $registration->refresh();
        $this->assertSame('pending_email_verification', $registration->status);
        $this->assertNull($registration->verified_at);
    }

    public function test_super_admin_can_approve_new_user_registration_atomically(): void
    {
        Notification::fake();

        $registration = ChurchRegistration::create([
            'church_name' => 'HKBP Parapat Danau',
            'slug' => 'hkbp-parapat-danau',
            'city' => 'Parapat',
            'applicant_name' => 'Pendeta Parapat',
            'applicant_email' => 'pendeta@parapat.org',
            'applicant_password_hash' => bcrypt('parapat123'),
            'status' => 'pending_review',
            'verified_at' => now(),
        ]);

        $service = app(ChurchRegistrationService::class);
        $church = $service->approve($registration, $this->superAdmin);

        // 1. Church created and active
        $this->assertInstanceOf(Church::class, $church);
        $this->assertSame('active', $church->status);
        $this->assertSame('hkbp-parapat-danau', $church->slug);

        // 2. Modules automatically provisioned (12 default modules)
        $this->assertSame(12, ChurchModule::where('church_id', $church->id)->count());

        // 3. User created with is_super_admin = false
        $newUser = User::where('email', 'pendeta@parapat.org')->firstOrFail();
        $this->assertFalse($newUser->is_super_admin);
        $this->assertSame('Pendeta Parapat', $newUser->name);

        // 4. Church admin membership and Spatie team role
        $membership = $church->memberships()->where('user_id', $newUser->id)->firstOrFail();
        $this->assertSame('church_admin', $membership->role);
        $this->assertSame('active', $membership->status);

        // 5. Registration status updated
        $registration->refresh();
        $this->assertSame('approved', $registration->status);
        $this->assertSame($church->id, $registration->church_id);
        $this->assertSame($this->superAdmin->id, $registration->approved_by_user_id);
        $this->assertNotNull($registration->approved_at);

        // 6. Approval notification sent
        Notification::assertSentOnDemand(
            ChurchRegistrationApprovedNotification::class,
            function (ChurchRegistrationApprovedNotification $notification, array $channels, object $notifiable) {
                return $notifiable->routes['mail'] === 'pendeta@parapat.org';
            }
        );
    }

    public function test_super_admin_can_approve_existing_user_registration_without_duplicate_user(): void
    {
        Notification::fake();

        // Existing user
        $existingUser = User::create([
            'name' => 'Pendeta Senior',
            'email' => 'senior@hkbp.org',
            'password' => bcrypt('password'),
            'is_super_admin' => false,
        ]);
        $initialUserCount = User::count();

        $registration = ChurchRegistration::create([
            'church_name' => 'HKBP Cabang Dua',
            'slug' => 'hkbp-cabang-dua',
            'applicant_name' => 'Pendeta Senior',
            'applicant_email' => 'senior@hkbp.org',
            'applicant_password_hash' => bcrypt('dummy'),
            'existing_user_id' => $existingUser->id,
            'status' => 'pending_review',
            'verified_at' => now(),
        ]);

        $service = app(ChurchRegistrationService::class);
        $church = $service->approve($registration, $this->superAdmin);

        // No new user created
        $this->assertSame($initialUserCount, User::count());

        // Existing user has active membership in the new church
        $membership = $church->memberships()->where('user_id', $existingUser->id)->firstOrFail();
        $this->assertSame('church_admin', $membership->role);
    }

    public function test_super_admin_can_reject_registration_with_reason(): void
    {
        Notification::fake();

        $registration = ChurchRegistration::create([
            'church_name' => 'Gereja Fiktif',
            'slug' => 'gereja-fiktif',
            'applicant_name' => 'Spammer',
            'applicant_email' => 'spam@example.com',
            'applicant_password_hash' => bcrypt('dummy'),
            'status' => 'pending_review',
            'verified_at' => now(),
        ]);

        $service = app(ChurchRegistrationService::class);
        $service->reject($registration, $this->superAdmin, 'Data gereja tidak terdaftar di buku ressort Sinode.');

        $registration->refresh();
        $this->assertSame('rejected', $registration->status);
        $this->assertSame('Data gereja tidak terdaftar di buku ressort Sinode.', $registration->rejection_reason);

        // No church created
        $this->assertDatabaseMissing('churches', ['slug' => 'gereja-fiktif']);

        Notification::assertSentOnDemand(
            ChurchRegistrationRejectedNotification::class,
            function (ChurchRegistrationRejectedNotification $notification, array $channels, object $notifiable) {
                return $notifiable->routes['mail'] === 'spam@example.com'
                    && str_contains($notification->reason, 'buku ressort');
            }
        );
    }

    public function test_regular_church_admin_cannot_access_church_registration_resource(): void
    {
        $this->actingAs($this->superAdmin);
        $this->assertTrue(ChurchRegistrationResource::canViewAny());

        $this->actingAs($this->churchAdmin);
        $this->assertFalse(ChurchRegistrationResource::canViewAny());

        auth()->logout();
        $this->assertFalse(ChurchRegistrationResource::canViewAny());
    }

    public function test_check_slug_endpoint_reports_availability_accurately(): void
    {
        // 1. Available slug
        $res1 = $this->getJson('/api/v1/public/church-registration/check-slug?slug=hkbp-baru-tersedia');
        $res1->assertStatus(200)
            ->assertJsonPath('available', true)
            ->assertJsonPath('slug', 'hkbp-baru-tersedia');

        // 2. Reserved slug
        $res2 = $this->getJson('/api/v1/public/church-registration/check-slug?slug=admin');
        $res2->assertStatus(200)
            ->assertJsonPath('available', false)
            ->assertJsonPath('reason', 'reserved');

        // 3. Existing church slug (non-reserved)
        $existingChurch = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Medan Kota',
            'slug' => 'hkbp-medan-kota',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        $res3 = $this->getJson("/api/v1/public/church-registration/check-slug?slug={$existingChurch->slug}");
        $res3->assertStatus(200)
            ->assertJsonPath('available', false)
            ->assertJsonPath('reason', 'church_exists');
    }

    public function test_rate_limiter_blocks_spam_submissions(): void
    {
        Notification::fake();

        for ($i = 1; $i <= 5; $i++) {
            $payload = [
                'church_name' => "HKBP Spam {$i}",
                'slug' => "hkbp-spam-{$i}",
                'applicant_name' => "Applicant {$i}",
                'applicant_email' => "applicant{$i}@spam.com",
                'password' => 'secret12345',
                'password_confirmation' => 'secret12345',
            ];
            $res = $this->postJson('/api/v1/public/church-registration', $payload);
            $res->assertStatus(201);
        }

        // 6th request from same IP should receive HTTP 429
        $payload6 = [
            'church_name' => 'HKBP Spam 6',
            'slug' => 'hkbp-spam-6',
            'applicant_name' => 'Applicant 6',
            'applicant_email' => 'applicant6@spam.com',
            'password' => 'secret12345',
            'password_confirmation' => 'secret12345',
        ];
        $res6 = $this->postJson('/api/v1/public/church-registration', $payload6);
        $res6->assertStatus(429);
    }

    public function test_prune_stale_command_hard_deletes_unverified_records_older_than_cutoff_and_frees_slug(): void
    {
        // 1. Stale unverified registration (created 8 days ago) - MUST be pruned
        $staleRegistration = ChurchRegistration::create([
            'church_name' => 'HKBP Abandoned Stale',
            'slug' => 'hkbp-abandoned-stale',
            'applicant_name' => 'Abandoner',
            'applicant_email' => 'abandoned@example.com',
            'applicant_password_hash' => bcrypt('password'),
            'status' => 'pending_email_verification',
            'created_at' => now()->subDays(8),
            'updated_at' => now()->subDays(8),
        ]);

        // 2. Recent unverified registration (created 2 days ago) - MUST NOT be deleted
        $recentRegistration = ChurchRegistration::create([
            'church_name' => 'HKBP Recent Unverified',
            'slug' => 'hkbp-recent-unverified',
            'applicant_name' => 'Recent Person',
            'applicant_email' => 'recent@example.com',
            'applicant_password_hash' => bcrypt('password'),
            'status' => 'pending_email_verification',
            'created_at' => now()->subDays(2),
            'updated_at' => now()->subDays(2),
        ]);

        // 3. Stale verified registration waiting for Super Admin review (created 10 days ago) - MUST NOT be deleted
        $verifiedRegistration = ChurchRegistration::create([
            'church_name' => 'HKBP Legitimate Pending Review',
            'slug' => 'hkbp-legitimate-review',
            'applicant_name' => 'Patient Pastor',
            'applicant_email' => 'patient@example.com',
            'applicant_password_hash' => bcrypt('password'),
            'status' => 'pending_review',
            'verified_at' => now()->subDays(10),
            'created_at' => now()->subDays(10),
            'updated_at' => now()->subDays(10),
        ]);

        // Act: Run the prune command
        $this->artisan('church-registrations:prune-stale --days=7')
            ->expectsOutputToContain('Successfully pruned 1 stale unverified church registration(s).')
            ->assertExitCode(0);

        // Assert: Stale unverified record was deleted from database
        $this->assertDatabaseMissing('church_registrations', [
            'id' => $staleRegistration->id,
            'slug' => 'hkbp-abandoned-stale',
        ]);

        // Assert: Recent unverified and pending_review records are PRESERVED
        $this->assertDatabaseHas('church_registrations', [
            'id' => $recentRegistration->id,
            'slug' => 'hkbp-recent-unverified',
        ]);
        $this->assertDatabaseHas('church_registrations', [
            'id' => $verifiedRegistration->id,
            'slug' => 'hkbp-legitimate-review',
        ]);

        // Assert: The freed slug 'hkbp-abandoned-stale' can now be registered again by another applicant
        $checkResponse = $this->getJson('/api/v1/public/church-registration/check-slug?slug=hkbp-abandoned-stale');
        $checkResponse->assertStatus(200)
            ->assertJsonPath('available', true)
            ->assertJsonPath('slug', 'hkbp-abandoned-stale');

        $registerResponse = $this->postJson('/api/v1/public/church-registration', [
            'church_name' => 'HKBP Restored Church',
            'slug' => 'hkbp-abandoned-stale',
            'applicant_name' => 'Legitimate Pastor',
            'applicant_email' => 'legitimate@example.com',
            'password' => 'secret12345',
            'password_confirmation' => 'secret12345',
        ]);
        $registerResponse->assertStatus(201)
            ->assertJsonPath('data.slug', 'hkbp-abandoned-stale');
    }
}
