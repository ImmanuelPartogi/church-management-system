<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FinancialTransparencyResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'period' => [
                'from' => $this['period']['from'],
                'to' => $this['period']['to'],
            ],
            'summary' => [
                'total_income' => (float) $this['summary']['total_income'],
                'total_expense' => (float) $this['summary']['total_expense'],
                'net_balance' => (float) $this['summary']['net_balance'],
            ],
            'income_breakdown' => $this['income_breakdown'],
            'expense_breakdown' => $this['expense_breakdown'],
        ];
    }
}
