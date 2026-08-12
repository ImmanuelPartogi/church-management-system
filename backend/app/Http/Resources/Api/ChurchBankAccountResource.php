<?php

namespace App\Http\Resources\Api;

use App\Models\ChurchBankAccount;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin ChurchBankAccount
 */
class ChurchBankAccountResource extends JsonResource
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
            'bank_name' => $this->bank_name,
            'account_number' => $this->account_number,
            'account_holder_name' => $this->account_holder_name,
            'is_active' => $this->is_active,
            'display_order' => $this->display_order,
        ];
    }
}
