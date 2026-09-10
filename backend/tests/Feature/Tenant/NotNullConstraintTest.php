<?php

namespace Tests\Feature\Tenant;

use App\Models\Announcement;
use App\Models\ChartOfAccount;
use App\Models\Church;
use App\Models\ChurchMember;
use App\Models\FinancialTransaction;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

class NotNullConstraintTest extends TestCase
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
     * 1. Test creating models without explicit church_id when NOT NULL is active in DB.
     * Verified through write-path bridge AutoAssignDefaultChurchOnCreate.
     */
    public function test_create_without_explicit_church_id_succeeds_under_not_null_constraint(): void
    {
        // 1. ChurchMember
        $member = ChurchMember::create([
            'membership_number' => 'MEM-NN-001',
            'full_name' => 'Not Null Test Member',
            'gender' => 'Male',
            'birth_date' => '1990-01-01',
            'phone' => '+628123456789',
            'email' => 'nn-member@example.com',
            'address' => 'Jl. Not Null No. 1',
            'status' => 'active',
        ]);
        $this->assertNotNull($member->church_id);
        $this->assertSame($this->defaultChurch->id, $member->church_id);

        // 2. Announcement
        $announcement = Announcement::create([
            'title' => 'Not Null Announcement',
            'content' => 'Content for testing NOT NULL constraint',
            'status' => 'published',
            'published_at' => now(),
        ]);
        $this->assertNotNull($announcement->church_id);
        $this->assertSame($this->defaultChurch->id, $announcement->church_id);

        // 3. FinancialTransaction
        $coa = ChartOfAccount::create([
            'code' => 'COA-NN-001',
            'name' => 'Kas Operasional',
            'type' => 'income',
            'is_active' => true,
        ]);
        $tx = FinancialTransaction::create([
            'transaction_number' => 'TX-NN-001',
            'transaction_date' => now()->toDateString(),
            'chart_of_account_id' => $coa->id,
            'type' => 'income',
            'amount' => 100000.00,
        ]);
        $this->assertNotNull($tx->church_id);
        $this->assertSame($this->defaultChurch->id, $tx->church_id);
    }

    /**
     * 2. Test database strictly rejects raw INSERT with church_id = NULL.
     */
    public function test_database_strictly_rejects_forced_null_church_id_insert_on_church_members(): void
    {
        $this->expectException(QueryException::class);
        $this->expectExceptionMessage('NOT NULL constraint failed');

        DB::table('church_members')->insert([
            'church_id' => null,
            'membership_number' => 'MEM-FORCED-NULL',
            'full_name' => 'Forced Null Member',
            'gender' => 'Male',
            'birth_date' => '1990-01-01',
            'phone' => '+628123456789',
            'email' => 'forced-null@example.com',
            'address' => 'Jl. Forced Null',
            'status' => 'active',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    /**
     * 2b. Test database strictly rejects raw INSERT with church_id = NULL on announcements.
     */
    public function test_database_strictly_rejects_forced_null_church_id_insert_on_announcements(): void
    {
        $this->expectException(QueryException::class);
        $this->expectExceptionMessage('NOT NULL constraint failed');

        DB::table('announcements')->insert([
            'church_id' => null,
            'title' => 'Forced Null Announcement',
            'content' => 'This raw insert must fail',
            'status' => 'published',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    /**
     * 2c. Test database strictly rejects raw INSERT with church_id = NULL on financial_transactions.
     */
    public function test_database_strictly_rejects_forced_null_church_id_insert_on_financial_transactions(): void
    {
        $coa = ChartOfAccount::create([
            'code' => 'COA-NN-002',
            'name' => 'Kas Lain-lain',
            'type' => 'income',
            'is_active' => true,
        ]);

        $this->expectException(QueryException::class);
        $this->expectExceptionMessage('NOT NULL constraint failed');

        DB::table('financial_transactions')->insert([
            'church_id' => null,
            'transaction_number' => 'TX-FORCED-NULL',
            'transaction_date' => now()->toDateString(),
            'chart_of_account_id' => $coa->id,
            'type' => 'income',
            'amount' => 50000.00,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
