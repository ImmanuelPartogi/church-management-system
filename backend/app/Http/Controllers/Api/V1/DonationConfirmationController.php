<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\DonationStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\StoreDonationConfirmationRequest;
use App\Http\Resources\Api\DonationConfirmationResource;
use App\Models\DonationConfirmation;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class DonationConfirmationController extends Controller
{
    /**
     * Display a listing of donation confirmations submitted by the authenticated user.
     */
    public function myDonations(Request $request): JsonResponse
    {
        $user = $request->user();

        $donations = DonationConfirmation::where('user_id', $user->id)
            ->with(['chartOfAccount', 'reviewer'])
            ->latest('transfer_date')
            ->latest('id')
            ->paginate(10);

        return $this->jsonPaginated(DonationConfirmationResource::collection($donations), 'Donation history retrieved successfully.');
    }

    /**
     * Display the specified donation confirmation details for the authenticated user.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $user = $request->user();

        $donation = DonationConfirmation::with(['chartOfAccount', 'reviewer'])->find($id);

        if (! $donation) {
            return $this->jsonError('Donation confirmation not found.', null, 404);
        }

        // Strict ownership check
        if ($donation->user_id !== $user->id) {
            return $this->jsonError('You are not authorized to view this donation confirmation.', null, 403);
        }

        return $this->jsonSuccess(new DonationConfirmationResource($donation), 'Donation confirmation details retrieved successfully.');
    }

    /**
     * Submit a new donation confirmation for the authenticated user.
     */
    public function confirm(StoreDonationConfirmationRequest $request): JsonResponse
    {
        $user = $request->user();
        $member = $user->member;

        $validated = $request->validated();

        $donation = DB::transaction(function () use ($user, $member, $validated, $request) {
            $proofPath = null;
            if ($request->hasFile('proof_file')) {
                $file = $request->file('proof_file');
                $proofPath = Storage::disk('public')->putFile('donation_proofs', $file);
            }

            return DonationConfirmation::create([
                'donation_number' => 'DON-'.date('Ymd').'-'.strtoupper(Str::random(6)),
                'user_id' => $user->id,
                'member_id' => $member?->id,
                'chart_of_account_id' => $validated['chart_of_account_id'],
                'amount' => $validated['amount'],
                'transfer_date' => $validated['transfer_date'],
                'sender_bank' => $validated['sender_bank'],
                'depositor_phone' => $validated['depositor_phone'] ?? null,
                'proof_file_path' => $proofPath,
                'status' => DonationStatus::Pending,
                'notes' => $validated['notes'] ?? null,
                'rejection_reason' => null,
                'reviewed_by' => null,
                'reviewed_at' => null,
            ]);
        });

        $donation->load(['chartOfAccount']);

        return $this->jsonSuccess(new DonationConfirmationResource($donation), 'Donation confirmation submitted successfully.', 201);
    }
}
