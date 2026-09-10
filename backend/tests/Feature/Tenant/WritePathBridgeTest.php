<?php

namespace Tests\Feature\Tenant;

use App\Models\Announcement;
use App\Models\ChartOfAccount;
use App\Models\Church;
use App\Models\ChurchMember;
use App\Models\FinancialTransaction;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use RuntimeException;
use Tests\TestCase;

class WritePathBridgeTest extends TestCase
{
    use RefreshDatabase;

    private Church $defaultChurch;

    protected function setUp(): void
    {
        parent::setUp();

        $this->defaultChurch = Church::firstOrCreate(
            ['slug' => 'default'],
            [
                'uuid' => (string) Str::uuid(),
                'name' => 'Gereja HKBP Resort Default',
                'status' => 'active',
                'timezone' => 'Asia/Jakarta',
            ]
        );
    }

    /**
     * Model 1: FinancialTransaction (onDelete restrict).
     */
    public function test_financial_transaction_auto_assigns_default_church_id(): void
    {
        $coa = ChartOfAccount::create([
            'code' => 'COA-TEST-001',
            'name' => 'Persembahan Ibadah',
            'type' => 'income',
            'is_active' => true,
        ]);

        $this->assertSame($this->defaultChurch->id, $coa->church_id);

        $tx = FinancialTransaction::create([
            'transaction_number' => 'TX-2026-0001',
            'transaction_date' => now()->toDateString(),
            'chart_of_account_id' => $coa->id,
            'type' => 'income',
            'amount' => 500000.00,
            'description' => 'Test financial transaction with restrict onDelete',
        ]);

        $this->assertNotNull($tx->church_id);
        $this->assertSame($this->defaultChurch->id, $tx->church_id);
        $this->assertDatabaseHas('financial_transactions', [
            'id' => $tx->id,
            'church_id' => $this->defaultChurch->id,
            'transaction_number' => 'TX-2026-0001',
        ]);
    }

    /**
     * Model 2: ChurchMember (onDelete cascade).
     */
    public function test_church_member_auto_assigns_default_church_id(): void
    {
        $member = ChurchMember::create([
            'membership_number' => 'MEM-TEST-9999',
            'full_name' => 'John Doe Test',
            'gender' => 'Male',
            'birth_date' => '1990-01-01',
            'phone' => '+628123456789',
            'email' => 'member-test@example.com',
            'address' => 'Jl. Test No. 1',
            'status' => 'active',
        ]);

        $this->assertNotNull($member->church_id);
        $this->assertSame($this->defaultChurch->id, $member->church_id);
        $this->assertDatabaseHas('church_members', [
            'id' => $member->id,
            'church_id' => $this->defaultChurch->id,
            'membership_number' => 'MEM-TEST-9999',
        ]);
    }

    /**
     * Model 3: Announcement with chained/multiple creating model events.
     */
    public function test_model_with_chained_creating_event_coexists_without_conflict(): void
    {
        // Dynamically register a secondary creating event on Announcement
        Announcement::creating(function (Announcement $announcement) {
            $announcement->title = strtoupper($announcement->title);
        });

        $announcement = Announcement::create([
            'title' => 'ibadah raya minggu',
            'content' => 'Pengumuman ibadah raya minggu pukul 09:00 WIB',
            'is_published' => true,
            'published_at' => now(),
        ]);

        // 1. Verify AutoAssignDefaultChurchOnCreate assigned default church_id
        $this->assertNotNull($announcement->church_id);
        $this->assertSame($this->defaultChurch->id, $announcement->church_id);

        // 2. Verify secondary model event also executed
        $this->assertSame('IBADAH RAYA MINGGU', $announcement->title);

        $this->assertDatabaseHas('announcements', [
            'id' => $announcement->id,
            'church_id' => $this->defaultChurch->id,
            'title' => 'IBADAH RAYA MINGGU',
        ]);
    }

    /**
     * Verify strict exception when default church context is missing (No silent ?? 1 fallback).
     */
    public function test_throws_runtime_exception_when_default_church_context_is_missing(): void
    {
        // Unbind church context so tenant context is completely missing
        app()->forgetInstance('current_church_id');
        app()->forgetInstance('current_church');

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage('Tenant context is missing — cannot create ['.ChurchMember::class.'] without an active church context.');

        ChurchMember::create([
            'membership_number' => 'MEM-FAIL-0001',
            'full_name' => 'Failing Member',
            'gender' => 'Male',
            'birth_date' => '1990-01-01',
            'phone' => '+628123456789',
            'email' => 'fail@example.com',
            'address' => 'Jl. Fail No. 1',
            'status' => 'active',
        ]);
    }

    /**
     * Verify idempotency: Explicitly provided church_id via direct assignment is NEVER overwritten.
     */
    public function test_explicit_direct_church_id_assignment_is_preserved_and_not_overwritten(): void
    {
        $anotherChurch = Church::create([
            'slug' => 'second-church',
            'uuid' => (string) Str::uuid(),
            'name' => 'Gereja HKBP Kedua',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        $member = new ChurchMember([
            'membership_number' => 'MEM-SECOND-0001',
            'full_name' => 'Second Church Member',
            'gender' => 'Female',
            'birth_date' => '1995-05-05',
            'phone' => '+628123456780',
            'email' => 'second@example.com',
            'address' => 'Jl. Kedua No. 2',
            'status' => 'active',
        ]);
        $member->church_id = $anotherChurch->id;
        $member->save();

        $this->assertSame($anotherChurch->id, $member->church_id);
        $this->assertNotSame($this->defaultChurch->id, $member->church_id);
    }

    /**
     * Verify mass-assignment protection: church_id is guarded so client payload cannot tamper with it.
     */
    public function test_mass_assignment_payload_cannot_tamper_with_guarded_church_id(): void
    {
        $member = ChurchMember::create([
            'church_id' => 99999, // Attempted cross-tenant spoofing in payload
            'membership_number' => 'MEM-SPOOF-0001',
            'full_name' => 'Spoof Attempt Member',
            'gender' => 'Male',
            'birth_date' => '1990-01-01',
            'phone' => '+628123456781',
            'email' => 'spoof@example.com',
            'address' => 'Jl. Spoof No. 3',
            'status' => 'active',
        ]);

        // church_id is stripped by Eloquent guard, and trait safely assigns default church
        $this->assertNotSame(99999, $member->church_id);
        $this->assertSame($this->defaultChurch->id, $member->church_id);
    }
}
