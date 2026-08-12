<?php

namespace App\Http\Requests;

use App\Models\ChartOfAccount;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Auth;

class StoreDonationConfirmationRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return Auth::check();
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'chart_of_account_id' => [
                'required',
                'integer',
                'exists:chart_of_accounts,id',
                function ($attribute, $value, $fail) {
                    $account = ChartOfAccount::find($value);
                    if ($account && ! $account->is_active) {
                        $fail('The selected donation category account is inactive.');
                    }
                },
            ],
            'amount' => ['required', 'numeric', 'gt:0'],
            'transfer_date' => ['required', 'date', 'before_or_equal:today'],
            'sender_bank' => ['required', 'string', 'max:255'],
            'depositor_phone' => ['nullable', 'string', 'max:50'],
            'notes' => ['nullable', 'string', 'max:1000'],
            'proof_file' => ['nullable', 'file', 'mimes:jpg,jpeg,png,pdf', 'max:5120'],
        ];
    }
}
