<?php

namespace App\Http\Resources\Api;

use App\Models\DonationConfirmation;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

/**
 * @mixin DonationConfirmation
 */
class DonationConfirmationResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'donation_number' => $this->donation_number,
            'user_id' => $this->user_id,
            'member_id' => $this->member_id,
            'category' => new ChartOfAccountResource($this->whenLoaded('chartOfAccount', fn () => $this->chartOfAccount, fn () => ChartOfAccountResource::make($this->chartOfAccount))),
            'amount' => $this->amount,
            'transfer_date' => $this->transfer_date->format('Y-m-d'),
            'sender_bank' => $this->sender_bank,
            'depositor_phone' => $this->depositor_phone,
            'proof_file_url' => $this->proof_file_path ? Storage::disk('public')->url($this->proof_file_path) : null,
            'status' => $this->status,
            'notes' => $this->notes,
            'rejection_reason' => $this->rejection_reason,
            'reviewed_at' => $this->reviewed_at,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
