<?php

namespace Tests\Feature\Filament;

use App\Filament\Resources\ChurchResource\Pages\EditChurch;
use App\Filament\Resources\ChurchResource\RelationManagers\ChurchModulesRelationManager;
use App\Filament\Resources\FinancialTransactionResource;
use App\Filament\Resources\WartaResource;
use App\Models\Church;
use App\Models\ChurchModule;
use App\Models\Module;
use App\Models\User;
use App\Services\Tenant\ChurchModuleService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Livewire\Livewire;
use Tests\TestCase;

class ChurchModuleFilamentTest extends TestCase
{
    use RefreshDatabase;

    protected Church $church;

    protected User $superAdmin;

    protected User $churchAdmin;

    protected ChurchModuleService $moduleService;

    protected function setUp(): void
    {
        parent::setUp();

        $this->church = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Test Filament Tenant',
            'slug' => 'hkbp-test-filament',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        $this->moduleService = app(ChurchModuleService::class);
        $this->moduleService->provisionDefaults($this->church);

        app()->instance('current_church_id', $this->church->id);
        app()->instance('current_church', $this->church);

        $this->superAdmin = User::create([
            'name' => 'Super Admin',
            'email' => 'superadmin@filament.org',
            'password' => bcrypt('password'),
            'is_super_admin' => true,
        ]);

        $this->churchAdmin = User::create([
            'name' => 'Church Admin',
            'email' => 'admin@filament.org',
            'password' => bcrypt('password'),
            'is_super_admin' => false,
        ]);
        $this->church->memberships()->create([
            'user_id' => $this->churchAdmin->id,
            'role' => 'church_admin',
            'status' => 'active',
        ]);
    }

    public function test_sidebar_navigation_hides_resource_when_module_is_disabled_for_regular_admin(): void
    {
        $this->actingAs($this->churchAdmin);

        // Initially enabled
        $this->assertTrue(FinancialTransactionResource::shouldRegisterNavigation());

        // Disable module
        $this->moduleService->disableModule($this->church, 'donations');
        $this->moduleService->disableModule($this->church, 'finance');

        // Navigation should now be hidden
        $this->assertFalse(FinancialTransactionResource::shouldRegisterNavigation());
    }

    public function test_sidebar_navigation_remains_visible_for_super_admin_even_when_module_disabled(): void
    {
        $this->actingAs($this->superAdmin);

        // Disable module for this church
        $this->moduleService->disableModule($this->church, 'donations');
        $this->moduleService->disableModule($this->church, 'finance');

        // Super Admin bypass (ADR 6.5) -> navigation still visible for administrative support
        $this->assertTrue(FinancialTransactionResource::shouldRegisterNavigation());
    }

    public function test_can_view_any_blocks_access_when_module_is_disabled_for_regular_admin(): void
    {
        $this->actingAs($this->churchAdmin);

        // Disable warta module
        $this->moduleService->disableModule($this->church, 'warta');

        // Direct URL access check fails (canViewAny returns false)
        $this->assertFalse(WartaResource::canViewAny());
    }

    public function test_can_view_any_allows_access_for_super_admin_even_when_module_disabled(): void
    {
        $this->actingAs($this->superAdmin);

        // Disable warta module
        $this->moduleService->disableModule($this->church, 'warta');

        // Super Admin bypass (ADR 6.5) -> canViewAny returns true
        $this->assertTrue(WartaResource::canViewAny());
    }

    public function test_super_admin_can_toggle_module_via_relation_manager(): void
    {
        $this->actingAs($this->superAdmin);

        $wartaChurchModule = ChurchModule::where('church_id', $this->church->id)
            ->whereHas('module', fn ($q) => $q->where('key', 'warta'))
            ->firstOrFail();

        $this->assertTrue($wartaChurchModule->is_enabled);

        // Mount relation manager and toggle status
        Livewire::test(ChurchModulesRelationManager::class, [
            'ownerRecord' => $this->church,
            'pageClass' => EditChurch::class,
        ])
            ->callTableAction('toggleStatus', $wartaChurchModule);

        // Verify module is now disabled
        $wartaChurchModule->refresh();
        $this->assertFalse($wartaChurchModule->is_enabled);
        $this->assertNotNull($wartaChurchModule->disabled_at);

        // Toggle back to enabled
        Livewire::test(ChurchModulesRelationManager::class, [
            'ownerRecord' => $this->church,
            'pageClass' => EditChurch::class,
        ])
            ->callTableAction('toggleStatus', $wartaChurchModule);

        $wartaChurchModule->refresh();
        $this->assertTrue($wartaChurchModule->is_enabled);
        $this->assertNull($wartaChurchModule->disabled_at);
    }

    public function test_super_admin_cannot_toggle_core_module_via_relation_manager(): void
    {
        $this->actingAs($this->superAdmin);

        $coreChurchModule = ChurchModule::where('church_id', $this->church->id)
            ->whereHas('module', fn ($q) => $q->where('key', 'announcements'))
            ->firstOrFail();

        // Action is disabled for core module
        Livewire::test(ChurchModulesRelationManager::class, [
            'ownerRecord' => $this->church,
            'pageClass' => EditChurch::class,
        ])
            ->assertTableActionDisabled('toggleStatus', $coreChurchModule);
    }

    public function test_relation_manager_handles_dependency_validation_with_notification(): void
    {
        $this->actingAs($this->superAdmin);

        $financeChurchModule = ChurchModule::where('church_id', $this->church->id)
            ->whereHas('module', fn ($q) => $q->where('key', 'finance'))
            ->firstOrFail();

        // Both finance and donations are active
        $this->assertTrue($this->moduleService->isModuleEnabled('donations', $this->church->id));

        // Attempting to toggle finance off while donations is active should trigger danger notification
        Livewire::test(ChurchModulesRelationManager::class, [
            'ownerRecord' => $this->church,
            'pageClass' => EditChurch::class,
        ])
            ->callTableAction('toggleStatus', $financeChurchModule)
            ->assertNotified('Gagal Mengubah Status Modul');

        // Finance remains enabled
        $financeChurchModule->refresh();
        $this->assertTrue($financeChurchModule->is_enabled);
    }
}
