<?php

namespace Tests\Feature\Api;

use App\Models\Announcement;
use App\Models\Church;
use App\Models\User;
use App\Models\Warta;
use App\Services\Tenant\ChurchModuleService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class ChurchModuleApiTest extends TestCase
{
    use RefreshDatabase;

    protected Church $church;

    protected User $regularUser;

    protected User $superAdmin;

    protected ChurchModuleService $moduleService;

    protected function setUp(): void
    {
        parent::setUp();

        $this->church = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Test Api Tenant',
            'slug' => 'hkbp-test-api',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
        ]);

        $this->moduleService = app(ChurchModuleService::class);
        $this->moduleService->provisionDefaults($this->church);

        // Bind tenant context
        app()->instance('current_church_id', $this->church->id);
        app()->instance('current_church', $this->church);

        // Create regular user with membership in this church
        $this->regularUser = User::create([
            'name' => 'Regular User',
            'email' => 'regular@test.org',
            'password' => bcrypt('password'),
            'is_super_admin' => false,
        ]);
        $this->church->memberships()->create([
            'user_id' => $this->regularUser->id,
            'role' => 'member',
            'status' => 'active',
        ]);

        // Create super admin
        $this->superAdmin = User::create([
            'name' => 'Super Admin',
            'email' => 'superadmin@test.org',
            'password' => bcrypt('password'),
            'is_super_admin' => true,
        ]);
    }

    public function test_public_endpoint_returns_200_when_module_is_enabled(): void
    {
        $response = $this->withHeaders([
            'X-Church-Id' => (string) $this->church->id,
        ])->getJson('/api/v1/wartas');

        $response->assertStatus(200);
    }

    public function test_public_endpoint_returns_403_with_module_disabled_code_when_module_is_disabled(): void
    {
        // Disable warta module for this church
        $this->moduleService->disableModule($this->church, 'warta');

        $response = $this->withHeaders([
            'X-Church-Id' => (string) $this->church->id,
        ])->getJson('/api/v1/wartas');

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'Fitur ini tidak diaktifkan untuk gereja yang dipilih.',
                'code' => 'MODULE_DISABLED',
                'module' => 'warta',
                'errors' => null,
            ]);
    }

    public function test_protected_endpoint_returns_403_when_module_is_disabled(): void
    {
        // Disable donations module for this church
        $this->moduleService->disableModule($this->church, 'donations');

        $response = $this->actingAs($this->regularUser, 'sanctum')
            ->withHeaders([
                'X-Church-Id' => (string) $this->church->id,
            ])->getJson('/api/v1/donations/my-donations');

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'code' => 'MODULE_DISABLED',
                'module' => 'donations',
            ]);
    }

    public function test_super_admin_bypasses_module_disabled_check_on_api(): void
    {
        // Disable warta module for this church
        $this->moduleService->disableModule($this->church, 'warta');
        $this->assertFalse($this->moduleService->isModuleEnabled('warta', $this->church->id));

        // Regular user receives 403 MODULE_DISABLED
        $responseRegular = $this->actingAs($this->regularUser, 'sanctum')
            ->withHeaders(['X-Church-Id' => (string) $this->church->id])
            ->getJson('/api/v1/wartas');
        $responseRegular->assertStatus(403);

        // Super Admin is bypassed completely (ADR 6.5) -> receives 200 OK
        $responseSuper = $this->actingAs($this->superAdmin, 'sanctum')
            ->withHeaders(['X-Church-Id' => (string) $this->church->id])
            ->getJson('/api/v1/wartas');
        $responseSuper->assertStatus(200);
    }

    public function test_search_endpoint_dynamically_excludes_disabled_modules(): void
    {
        // Create an announcement (announcements module)
        Announcement::create([
            'church_id' => $this->church->id,
            'title' => 'Worship Special Event',
            'content' => 'Annual gathering event',
            'status' => 'published',
            'published_at' => now()->subDay(),
        ]);

        // Create a warta (warta module)
        Warta::create([
            'church_id' => $this->church->id,
            'title' => 'Special Warta Edition',
            'description' => 'Weekly warta details',
            'publish_date' => now()->toDateString(),
            'file_path' => 'wartas/test.pdf',
            'is_published' => true,
            'published_at' => now()->subDay(),
        ]);

        // 1. Both enabled: search returns both
        $res1 = $this->withHeaders(['X-Church-Id' => (string) $this->church->id])
            ->getJson('/api/v1/search?q=Special');
        $res1->assertStatus(200);
        $this->assertGreaterThan(0, count($res1->json('data.results.announcements')));
        $this->assertGreaterThan(0, count($res1->json('data.results.wartas')));

        // 2. Disable warta module: search excludes wartas
        $this->moduleService->disableModule($this->church, 'warta');

        $res2 = $this->withHeaders(['X-Church-Id' => (string) $this->church->id])
            ->getJson('/api/v1/search?q=Special');
        $res2->assertStatus(200);
        $this->assertGreaterThan(0, count($res2->json('data.results.announcements')));
        $this->assertCount(0, $res2->json('data.results.wartas'));

        // 3. Super Admin searching still includes wartas even if module is disabled for tenant
        $res3 = $this->actingAs($this->superAdmin, 'sanctum')
            ->withHeaders(['X-Church-Id' => (string) $this->church->id])
            ->getJson('/api/v1/search?q=Special');
        $res3->assertStatus(200);
        $this->assertGreaterThan(0, count($res3->json('data.results.wartas')));
    }
}
