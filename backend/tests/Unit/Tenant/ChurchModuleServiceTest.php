<?php

namespace Tests\Unit\Tenant;

use App\Models\Church;
use App\Models\ChurchBankAccount;
use App\Models\ChurchModule;
use App\Models\Module;
use App\Services\Tenant\ChurchModuleService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use InvalidArgumentException;
use Tests\TestCase;

class ChurchModuleServiceTest extends TestCase
{
    use RefreshDatabase;

    protected Church $church;

    protected ChurchModuleService $service;

    protected function setUp(): void
    {
        parent::setUp();

        $this->church = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Test Unit Tenant',
            'slug' => 'hkbp-test-unit',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        $this->service = app(ChurchModuleService::class);
    }

    public function test_provision_defaults_enables_all_12_modules(): void
    {
        $this->service->provisionDefaults($this->church);

        $enabledCount = ChurchModule::where('church_id', $this->church->id)
            ->where('is_enabled', true)
            ->count();

        $this->assertSame(12, $enabledCount);
        $this->assertTrue($this->service->isModuleEnabled('membership', $this->church->id));
        $this->assertTrue($this->service->isModuleEnabled('announcements', $this->church->id));
        $this->assertTrue($this->service->isModuleEnabled('finance', $this->church->id));
        $this->assertTrue($this->service->isModuleEnabled('donations', $this->church->id));
    }

    public function test_is_module_enabled_returns_correct_status_and_uses_cache(): void
    {
        $this->service->provisionDefaults($this->church);
        $this->assertTrue($this->service->isModuleEnabled('warta', $this->church->id));

        // Disable module directly on DB to test cache
        ChurchModule::where('church_id', $this->church->id)
            ->whereHas('module', fn ($q) => $q->where('key', 'warta'))
            ->update(['is_enabled' => false]);

        // Returns cached true
        $this->assertTrue($this->service->isModuleEnabled('warta', $this->church->id));

        // Clear cache and verify fresh false
        $this->service->clearCache($this->church->id);
        $this->assertFalse($this->service->isModuleEnabled('warta', $this->church->id));
    }

    public function test_core_modules_cannot_be_disabled(): void
    {
        $this->service->provisionDefaults($this->church);

        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage("Modul inti 'Pengumuman Gereja' tidak dapat dinonaktifkan.");

        $this->service->disableModule($this->church, 'announcements');
    }

    public function test_membership_core_module_cannot_be_disabled(): void
    {
        $this->service->provisionDefaults($this->church);

        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage("Modul inti 'Jemaat & Keanggotaan' tidak dapat dinonaktifkan.");

        $this->service->disableModule($this->church, 'membership');
    }

    public function test_cannot_disable_parent_module_when_child_is_active(): void
    {
        $this->service->provisionDefaults($this->church);

        // donations depends on finance
        $this->assertTrue($this->service->isModuleEnabled('donations', $this->church->id));

        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage("Tidak dapat menonaktifkan modul 'Keuangan & Buku Kas' karena modul 'Donasi & Persembahan Online' masih aktif dan bergantung padanya.");

        $this->service->disableModule($this->church, 'finance');
    }

    public function test_can_disable_parent_module_after_children_are_disabled(): void
    {
        $this->service->provisionDefaults($this->church);

        // 1. Disable child first
        $this->service->disableModule($this->church, 'donations');
        $this->assertFalse($this->service->isModuleEnabled('donations', $this->church->id));

        // 2. Now disabling parent succeeds
        $this->service->disableModule($this->church, 'finance');
        $this->assertFalse($this->service->isModuleEnabled('finance', $this->church->id));
    }

    public function test_cannot_enable_child_module_when_parent_is_disabled(): void
    {
        $this->service->provisionDefaults($this->church);

        // Disable child and parent
        $this->service->disableModule($this->church, 'donations');
        $this->service->disableModule($this->church, 'finance');

        // Attempt to enable child while parent is disabled
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage("Tidak dapat mengaktifkan modul 'Donasi & Persembahan Online' karena modul induk 'Keuangan & Buku Kas' belum aktif.");

        $this->service->enableModule($this->church, 'donations');
    }

    public function test_can_enable_child_module_when_parent_is_enabled(): void
    {
        $this->service->provisionDefaults($this->church);

        // Disable child
        $this->service->disableModule($this->church, 'donations');
        $this->assertFalse($this->service->isModuleEnabled('donations', $this->church->id));

        // Parent (finance) is still active, so re-enabling child succeeds
        $this->service->enableModule($this->church, 'donations');
        $this->assertTrue($this->service->isModuleEnabled('donations', $this->church->id));
    }

    public function test_disabling_module_preserves_historical_data_in_database(): void
    {
        $this->service->provisionDefaults($this->church);

        app()->instance('current_church_id', $this->church->id);

        // Create a bank account record under finance module
        $bankAccount = ChurchBankAccount::create([
            'bank_name' => 'Bank Mandiri',
            'account_number' => '1234567890',
            'account_holder_name' => 'HKBP Test Kas',
            'is_active' => true,
        ]);

        $this->assertDatabaseHas('church_bank_accounts', [
            'id' => $bankAccount->id,
            'church_id' => $this->church->id,
            'bank_name' => 'Bank Mandiri',
        ]);

        // Disable child (donations) and parent (finance)
        $this->service->disableModule($this->church, 'donations');
        $this->service->disableModule($this->church, 'finance');

        // Verify module is disabled
        $this->assertFalse($this->service->isModuleEnabled('finance', $this->church->id));

        // ZERO DATA LOSS GUARANTEE: Database record still exists completely intact!
        $this->assertDatabaseHas('church_bank_accounts', [
            'id' => $bankAccount->id,
            'church_id' => $this->church->id,
            'bank_name' => 'Bank Mandiri',
        ]);
        $this->assertNotNull(ChurchBankAccount::find($bankAccount->id));
    }
}
