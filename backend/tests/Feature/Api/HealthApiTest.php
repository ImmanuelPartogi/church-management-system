<?php

namespace Tests\Feature\Api;

use Tests\TestCase;

class HealthApiTest extends TestCase
{
    /**
     * Test health check API endpoint.
     */
    public function test_health_check_returns_running_status(): void
    {
        $response = $this->getJson('/api/v1/health');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'API is running',
                'data' => [
                    'version' => '1.0.0',
                    'environment' => 'testing',
                ],
            ]);
    }
}
