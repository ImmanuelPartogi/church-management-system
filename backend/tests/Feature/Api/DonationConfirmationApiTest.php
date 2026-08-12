<?php

namespace Tests\Feature\Api;

use App\Enums\DonationStatus;
use App\Enums\FinanceAccountType;
use App\Models\ChartOfAccount;
use App\Models\ChurchBankAccount;
use App\Models\ChurchMember;
use App\Models\DonationConfirmation;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DonationConfirmationApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_active_church_bank_accounts(): void
    {
        ChurchBankAccount::factory()->create([
            'bank_name' => 'BCA',
            'account_number' => '1234567890',
            'is_active' => true,
        ]);

        ChurchBankAccount::factory()->create([
            'bank_name' => 'Bank Inactive',
            'is_active' => false,
        ]);

        $response = $this->getJson('/api/v1/church-bank-accounts');

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonFragment(['bank_name' => 'BCA'])
            ->assertJsonMissing(['bank_name' => 'Bank Inactive']);
    }

    public function test_guest_cannot_submit_donation_confirmation(): void
    {
        $account = ChartOfAccount::factory()->create([
            'type' => FinanceAccountType::Income,
            'is_active' => true,
        ]);

        $response = $this->postJson('/api/v1/donations/confirm', [
            'chart_of_account_id' => $account->id,
            'amount' => 500000,
            'transfer_date' => now()->format('Y-m-d'),
            'sender_bank' => 'Bank Mandiri',
        ]);

        $response->assertStatus(401);
    }

    public function test_authenticated_member_can_submit_donation_confirmation_with_proof(): void
    {
        Storage::fake('public');

        $user = User::factory()->create();
        $member = ChurchMember::factory()->create(['user_id' => $user->id]);

        $account = ChartOfAccount::factory()->create([
            'type' => FinanceAccountType::Income,
            'is_active' => true,
        ]);

        Sanctum::actingAs($user);

        $proofFile = UploadedFile::fake()->create('receipt.jpg', 300, 'image/jpeg');

        $response = $this->postJson('/api/v1/donations/confirm', [
            'chart_of_account_id' => $account->id,
            'amount' => 1000000,
            'transfer_date' => now()->format('Y-m-d'),
            'sender_bank' => 'Bank Central Asia',
            'depositor_phone' => '081234567890',
            'notes' => 'Persembahan Perpuluhan Bulan Ini',
            'proof_file' => $proofFile,
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'user_id' => $user->id,
                    'member_id' => $member->id,
                    'amount' => '1000000.00',
                    'sender_bank' => 'Bank Central Asia',
                    'status' => 'pending',
                    'rejection_reason' => null,
                ],
            ]);

        $this->assertDatabaseHas('donation_confirmations', [
            'user_id' => $user->id,
            'member_id' => $member->id,
            'chart_of_account_id' => $account->id,
            'status' => DonationStatus::Pending->value,
            'reviewed_by' => null,
            'reviewed_at' => null,
        ]);
    }

    public function test_submitting_donation_with_inactive_category_is_rejected(): void
    {
        $user = User::factory()->create();
        $account = ChartOfAccount::factory()->create(['is_active' => false]);

        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/donations/confirm', [
            'chart_of_account_id' => $account->id,
            'amount' => 100000,
            'transfer_date' => now()->format('Y-m-d'),
            'sender_bank' => 'BCA',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['chart_of_account_id']);
    }

    public function test_invalid_amount_is_rejected(): void
    {
        $user = User::factory()->create();
        $account = ChartOfAccount::factory()->create(['is_active' => true]);

        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/donations/confirm', [
            'chart_of_account_id' => $account->id,
            'amount' => -5000,
            'transfer_date' => now()->format('Y-m-d'),
            'sender_bank' => 'BCA',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['amount']);
    }

    public function test_authenticated_user_can_list_their_own_donations(): void
    {
        $userA = User::factory()->create();
        $userB = User::factory()->create();

        $account = ChartOfAccount::factory()->create(['is_active' => true]);

        $donationA = DonationConfirmation::factory()->create([
            'user_id' => $userA->id,
            'chart_of_account_id' => $account->id,
        ]);

        $donationB = DonationConfirmation::factory()->create([
            'user_id' => $userB->id,
            'chart_of_account_id' => $account->id,
        ]);

        Sanctum::actingAs($userA);

        $response = $this->getJson('/api/v1/donations/my-donations');

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonFragment(['id' => $donationA->id])
            ->assertJsonMissing(['id' => $donationB->id]);
    }

    public function test_user_cannot_view_another_users_donation_detail(): void
    {
        $userA = User::factory()->create();
        $userB = User::factory()->create();

        $account = ChartOfAccount::factory()->create(['is_active' => true]);

        $donationB = DonationConfirmation::factory()->create([
            'user_id' => $userB->id,
            'chart_of_account_id' => $account->id,
        ]);

        Sanctum::actingAs($userA);

        $response = $this->getJson('/api/v1/donations/'.$donationB->id);

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'You are not authorized to view this donation confirmation.',
            ]);
    }
}
