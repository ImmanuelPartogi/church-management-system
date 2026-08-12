<?php

namespace Tests\Feature\Domain;

use App\Enums\PaymentStatus;
use App\Enums\PrayerRequestStatus;
use App\Enums\ServiceFormStatus;
use App\Models\ChurchMember;
use App\Models\PrayerRequest;
use App\Models\ServiceFormApplication;
use App\Models\ServiceFormDocument;
use App\Models\ServiceFormType;
use App\Models\User;
use App\Models\Warta;
use Database\Seeders\ServiceFormTypeSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WartaAndFormsFoundationTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test Warta model creation and published scope.
     */
    public function test_warta_can_be_created_and_filtered_by_published_scope(): void
    {
        $published = Warta::factory()->create([
            'title' => 'Warta Published',
            'is_published' => true,
            'published_at' => now()->subDay(),
        ]);

        $future = Warta::factory()->create([
            'title' => 'Warta Future',
            'is_published' => true,
            'published_at' => now()->addDay(),
        ]);

        $draft = Warta::factory()->unpublished()->create([
            'title' => 'Warta Draft',
        ]);

        $publishedList = Warta::published()->get();

        $this->assertTrue($publishedList->contains($published));
        $this->assertFalse($publishedList->contains($future));
        $this->assertFalse($publishedList->contains($draft));
    }

    /**
     * Test ServiceFormType creation and configurable fee.
     */
    public function test_service_form_type_has_configurable_fee_and_unique_slug(): void
    {
        $formType = ServiceFormType::factory()->create([
            'name' => 'Layanan Khusus',
            'slug' => 'layanan-khusus',
            'fee_amount' => 50000.00,
            'active' => true,
        ]);

        $this->assertDatabaseHas('service_form_types', [
            'slug' => 'layanan-khusus',
            'fee_amount' => 50000.00,
        ]);

        $this->assertEquals(50000.00, $formType->fee_amount);
        $this->assertTrue($formType->active);
    }

    /**
     * Test ServiceFormApplication relationships and enum casts.
     */
    public function test_service_form_application_relationships_and_enum_casts(): void
    {
        $user = User::factory()->create();
        $member = ChurchMember::factory()->create(['user_id' => $user->id]);
        $type = ServiceFormType::factory()->create();
        $reviewer = User::factory()->create();

        $application = ServiceFormApplication::factory()->create([
            'user_id' => $user->id,
            'member_id' => $member->id,
            'service_form_type_id' => $type->id,
            'status' => ServiceFormStatus::Pending,
            'payment_status' => PaymentStatus::Unpaid,
            'reviewed_by' => $reviewer->id,
            'reviewed_at' => now(),
        ]);

        $this->assertInstanceOf(ServiceFormStatus::class, $application->status);
        $this->assertEquals(ServiceFormStatus::Pending, $application->status);
        $this->assertInstanceOf(PaymentStatus::class, $application->payment_status);
        $this->assertEquals(PaymentStatus::Unpaid, $application->payment_status);

        $this->assertTrue($application->user->is($user));
        $this->assertTrue($application->member->is($member));
        $this->assertTrue($application->serviceFormType->is($type));
        $this->assertTrue($application->reviewer->is($reviewer));
    }

    /**
     * Test ServiceFormDocument relationship and cascade delete.
     */
    public function test_service_form_document_belongs_to_application_and_cascades_on_delete(): void
    {
        $application = ServiceFormApplication::factory()->create();
        $document = ServiceFormDocument::factory()->create([
            'service_form_application_id' => $application->id,
            'document_name' => 'KTP Attachment',
        ]);

        $this->assertTrue($document->application->is($application));
        $this->assertCount(1, $application->documents);

        $application->delete();

        $this->assertDatabaseMissing('service_form_documents', [
            'id' => $document->id,
        ]);
    }

    /**
     * Test PrayerRequest defaults to private and supports status enum cast.
     */
    public function test_prayer_request_defaults_to_private_and_casts_status_enum(): void
    {
        $user = User::factory()->create();
        $member = ChurchMember::factory()->create();

        $prayer = PrayerRequest::factory()->create([
            'user_id' => $user->id,
            'member_id' => $member->id,
            'content' => 'Mohon doa untuk kesehatan keluarga.',
            'status' => PrayerRequestStatus::Submitted,
        ]);

        $this->assertTrue($prayer->is_private);
        $this->assertInstanceOf(PrayerRequestStatus::class, $prayer->status);
        $this->assertEquals(PrayerRequestStatus::Submitted, $prayer->status);
        $this->assertTrue($prayer->user->is($user));
        $this->assertTrue($prayer->member->is($member));
    }

    /**
     * Test nullOnDelete behavior preserves historical records when user is deleted.
     */
    public function test_deleting_user_nullifies_foreign_key_on_historical_records(): void
    {
        $user = User::factory()->create();

        $application = ServiceFormApplication::factory()->create([
            'user_id' => $user->id,
        ]);

        $prayer = PrayerRequest::factory()->create([
            'user_id' => $user->id,
        ]);

        $user->delete();

        $application->refresh();
        $prayer->refresh();

        $this->assertNull($application->user_id);
        $this->assertNull($prayer->user_id);
    }

    /**
     * Test ServiceFormTypeSeeder seeds standard service form types.
     */
    public function test_seeder_creates_default_service_form_types(): void
    {
        $this->seed(ServiceFormTypeSeeder::class);

        $this->assertDatabaseHas('service_form_types', ['slug' => 'baptis']);
        $this->assertDatabaseHas('service_form_types', ['slug' => 'sidi']);
        $this->assertDatabaseHas('service_form_types', ['slug' => 'nikah']);
        $this->assertDatabaseHas('service_form_types', ['slug' => 'konseling']);
        $this->assertDatabaseHas('service_form_types', ['slug' => 'pindah-masuk']);
        $this->assertDatabaseHas('service_form_types', ['slug' => 'pindah-keluar']);
    }
}
