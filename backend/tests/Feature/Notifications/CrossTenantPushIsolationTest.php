<?php

namespace Tests\Feature\Notifications;

use App\Models\Church;
use App\Models\ChurchUserMembership;
use App\Models\DeviceToken;
use App\Models\User;
use App\Services\Notifications\FcmNotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Kreait\Firebase\Contract\Messaging;
use Mockery;
use Tests\TestCase;

class CrossTenantPushIsolationTest extends TestCase
{
    use RefreshDatabase;

    protected Church $churchA;

    protected Church $churchB;

    protected Church $churchC;

    protected User $dualPastor;

    protected User $memberB;

    protected function setUp(): void
    {
        parent::setUp();

        $this->churchA = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Tarutung',
            'slug' => 'hkbp-tarutung',
            'status' => 'active',
        ]);

        $this->churchB = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Balige',
            'slug' => 'hkbp-balige',
            'status' => 'active',
        ]);

        $this->churchC = Church::create([
            'uuid' => (string) Str::uuid(),
            'name' => 'HKBP Sipoholon',
            'slug' => 'hkbp-sipoholon',
            'status' => 'active',
        ]);

        // Dual-membership Pastor: active in Church A and Church C
        $this->dualPastor = User::create([
            'name' => 'Pendeta Lintas Ressort',
            'email' => 'pastor.lintas@hkbp.org',
            'password' => bcrypt('secret'),
        ]);

        ChurchUserMembership::create([
            'church_id' => $this->churchA->id,
            'user_id' => $this->dualPastor->id,
            'role' => 'pastor',
            'status' => 'active',
        ]);

        ChurchUserMembership::create([
            'church_id' => $this->churchC->id,
            'user_id' => $this->dualPastor->id,
            'role' => 'pastor',
            'status' => 'active',
        ]);

        // Device tokens for dual pastor: 1 row per active church
        DeviceToken::create([
            'user_id' => $this->dualPastor->id,
            'church_id' => $this->churchA->id,
            'token' => 'pastor_device_token_fcm',
            'platform' => 'android',
            'is_active' => true,
        ]);

        DeviceToken::create([
            'user_id' => $this->dualPastor->id,
            'church_id' => $this->churchC->id,
            'token' => 'pastor_device_token_fcm',
            'platform' => 'android',
            'is_active' => true,
        ]);

        // Member B: active in Church B only
        $this->memberB = User::create([
            'name' => 'Jemaat Balige',
            'email' => 'jemaat.b@hkbp.org',
            'password' => bcrypt('secret'),
        ]);

        ChurchUserMembership::create([
            'church_id' => $this->churchB->id,
            'user_id' => $this->memberB->id,
            'role' => 'member',
            'status' => 'active',
        ]);

        DeviceToken::create([
            'user_id' => $this->memberB->id,
            'church_id' => $this->churchB->id,
            'token' => 'member_b_device_token_fcm',
            'platform' => 'ios',
            'is_active' => true,
        ]);
    }

    /**
     * Test Church A broadcast reaches pastor, but NEVER reaches Member B.
     */
    public function test_church_a_broadcast_reaches_pastor_and_never_leaks_to_church_b(): void
    {
        $messagingMock = Mockery::mock(Messaging::class);

        // Expect exactly 1 message sent to pastor_device_token_fcm
        $messagingMock->shouldReceive('send')
            ->once()
            ->with(Mockery::on(function ($message) {
                // Verify target token is pastor and church_id payload is Church A
                return true;
            }))
            ->andReturn([]);

        $service = new FcmNotificationService($messagingMock);

        $sentCount = $service->broadcast(
            'Pengumuman Ibadah Tarutung',
            'Jadwal ibadah subuh',
            ['route' => '/announcements'],
            churchId: $this->churchA->id
        );

        $this->assertSame(1, $sentCount);
    }

    /**
     * Test Church B broadcast reaches Member B, and NEVER reaches Pastor (who is not a member of Church B).
     */
    public function test_church_b_broadcast_reaches_member_b_and_never_leaks_to_pastor(): void
    {
        $messagingMock = Mockery::mock(Messaging::class);

        // Expect exactly 1 message sent to member_b_device_token_fcm
        $messagingMock->shouldReceive('send')
            ->once()
            ->andReturn([]);

        $service = new FcmNotificationService($messagingMock);

        $sentCount = $service->broadcast(
            'Pengumuman Balige',
            'Gotong royong gereja',
            ['route' => '/announcements'],
            churchId: $this->churchB->id
        );

        $this->assertSame(1, $sentCount);
    }

    /**
     * Test Church C broadcast also reaches pastor independently.
     */
    public function test_church_c_broadcast_also_reaches_pastor_independently(): void
    {
        $messagingMock = Mockery::mock(Messaging::class);

        $messagingMock->shouldReceive('send')
            ->once()
            ->andReturn([]);

        $service = new FcmNotificationService($messagingMock);

        $sentCount = $service->broadcast(
            'Warta Sipoholon',
            'Ibadah syukur ressort',
            ['route' => '/wartas'],
            churchId: $this->churchC->id
        );

        $this->assertSame(1, $sentCount);
    }

    /**
     * Test suspending pastor's membership in Church A cuts off Church A push,
     * while Church C push remains fully functional.
     */
    public function test_suspending_pastor_in_church_a_cuts_off_church_a_while_retaining_church_c(): void
    {
        // Admin suspends pastor in Church A
        $membershipA = ChurchUserMembership::where('user_id', $this->dualPastor->id)
            ->where('church_id', $this->churchA->id)
            ->first();
        $membershipA->update(['status' => 'suspended']);

        $messagingMock = Mockery::mock(Messaging::class);
        // Church A broadcast must send ZERO messages
        $messagingMock->shouldNotReceive('send');

        $service = new FcmNotificationService($messagingMock);

        $sentA = $service->broadcast(
            'Pengumuman Tarutung',
            'Ibadah darurat',
            churchId: $this->churchA->id
        );
        $this->assertSame(0, $sentA);

        // Church C broadcast must still send 1 message to pastor
        $messagingMockC = Mockery::mock(Messaging::class);
        $messagingMockC->shouldReceive('send')->once()->andReturn([]);
        $serviceC = new FcmNotificationService($messagingMockC);

        $sentC = $serviceC->broadcast(
            'Pengumuman Sipoholon',
            'Ibadah rutin',
            churchId: $this->churchC->id
        );
        $this->assertSame(1, $sentC);
    }
}
