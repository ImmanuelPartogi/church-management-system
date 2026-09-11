<?php

namespace Tests\Feature\Theme;

use App\Models\Church;
use Database\Seeders\ModuleSeeder;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class ChurchApiThemeTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndPermissionsSeeder::class);
        $this->seed(ModuleSeeder::class);
    }

    /**
     * Test GET /api/v1/churches returns additive theme contract with backward compatibility.
     */
    public function test_get_churches_returns_theme_attributes_backward_compatibly(): void
    {
        // Church with default theme
        $churchA = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Default Church',
            'slug' => 'hkbp-default-church',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'address' => 'Jl. Merdeka No. 10',
            'phone' => '0811111111',
            'logo_path' => 'logos/church-a.png',
        ]);

        // Church with custom theme
        $churchB = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Custom Themed Church',
            'slug' => 'hkbp-custom-church',
            'status' => 'active',
            'timezone' => 'Asia/Jakarta',
            'address' => 'Jl. Sudirman No. 20',
            'phone' => '0822222222',
            'logo_path' => 'logos/church-b.png',
            'theme_primary_color' => '#2E7D32',
            'theme_secondary_color' => '#FFC107',
            'theme_version' => 5,
        ]);

        // Suspended church (must not appear)
        Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Suspended Church',
            'slug' => 'hkbp-suspended-church',
            'status' => 'suspended',
            'timezone' => 'Asia/Jakarta',
        ]);

        $response = $this->getJson('/api/v1/churches');

        $response->assertOk()
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'uuid',
                        'name',
                        'slug',
                        'timezone',
                        'address',
                        'phone',
                        'logo_url',
                        'theme_primary_color',
                        'theme_secondary_color',
                        'theme_version',
                    ],
                ],
            ]);

        $data = $response->json('data');

        // Locate churchA and churchB in response (ignoring seeded default church)
        $recordA = collect($data)->firstWhere('slug', 'hkbp-default-church');
        $this->assertNotNull($recordA);
        $this->assertSame('#1B4B66', $recordA['theme_primary_color']);
        $this->assertSame('#F5A623', $recordA['theme_secondary_color']);
        $this->assertSame(1, $recordA['theme_version']);
        $this->assertStringContainsString('logos/church-a.png', $recordA['logo_url']);

        $recordB = collect($data)->firstWhere('slug', 'hkbp-custom-church');
        $this->assertNotNull($recordB);
        $this->assertSame('#2E7D32', $recordB['theme_primary_color']);
        $this->assertSame('#FFC107', $recordB['theme_secondary_color']);
        $this->assertSame(5, $recordB['theme_version']);
        $this->assertStringContainsString('logos/church-b.png', $recordB['logo_url']);

        // Assert suspended church is not present
        $this->assertNull(collect($data)->firstWhere('slug', 'hkbp-suspended-church'));
    }
}
