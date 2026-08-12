<?php

namespace App\Http\Resources\Api;

use App\Models\ServiceFormApplication;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin ServiceFormApplication
 */
class ServiceFormApplicationResource extends JsonResource
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
            'application_number' => $this->application_number,
            'user_id' => $this->user_id,
            'member_id' => $this->member_id,
            'service_form_type' => new ServiceFormTypeResource($this->whenLoaded('serviceFormType', fn () => $this->serviceFormType, fn () => ServiceFormTypeResource::make($this->serviceFormType))),
            'status' => $this->status,
            'applicant_notes' => $this->applicant_notes,
            'rejection_reason' => $this->rejection_reason,
            'payment_status' => $this->payment_status,
            'payment_notes' => $this->payment_notes,
            'reviewed_at' => $this->reviewed_at,
            'documents' => ServiceFormDocumentResource::collection($this->whenLoaded('documents')),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
