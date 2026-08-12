<?php

namespace App\Http\Requests;

use App\Models\ServiceFormType;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Auth;

class StoreServiceFormApplicationRequest extends FormRequest
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
            'service_form_type_id' => [
                'required',
                'integer',
                'exists:service_form_types,id',
                function ($attribute, $value, $fail) {
                    $type = ServiceFormType::find($value);
                    if ($type && ! $type->active) {
                        $fail('The selected service form type is inactive and cannot accept applications.');
                    }
                },
            ],
            'applicant_notes' => ['nullable', 'string'],
            'documents' => ['nullable', 'array'],
            'documents.*.document_name' => ['required_with:documents', 'string', 'max:255'],
            'documents.*.file' => ['required_with:documents', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'],
        ];
    }
}
