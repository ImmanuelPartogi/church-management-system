<?php

namespace App\Http\Requests\Registration;

use App\Models\Church;
use App\Models\ChurchRegistration;
use App\Services\Registration\ChurchRegistrationService;
use Closure;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Str;

class RegisterChurchRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'church_name' => ['required', 'string', 'max:255'],
            'slug' => [
                'nullable',
                'string',
                'max:100',
                'regex:/^[a-z0-9]+(?:-[a-z0-9]+)*$/',
                function (string $attribute, mixed $value, Closure $fail) {
                    $slug = Str::slug((string) $value);

                    if (in_array($slug, ChurchRegistrationService::RESERVED_SLUGS, true)) {
                        $fail('Slug "'.$slug.'" merupakan reserved keyword sistem dan tidak dapat digunakan.');

                        return;
                    }

                    if (Church::where('slug', $slug)->exists()) {
                        $fail('Slug "'.$slug.'" sudah terdaftar untuk gereja lain.');

                        return;
                    }

                    if (ChurchRegistration::where('slug', $slug)->where('status', '!=', 'rejected')->exists()) {
                        $fail('Slug "'.$slug.'" sedang dalam proses peninjauan pendaftaran.');
                    }
                },
            ],
            'city' => ['nullable', 'string', 'max:100'],
            'address' => ['nullable', 'string', 'max:500'],
            'phone' => ['nullable', 'string', 'max:50'],
            'timezone' => ['nullable', 'string', 'in:Asia/Jakarta,Asia/Makassar,Asia/Jayapura'],
            'applicant_name' => ['required', 'string', 'max:255'],
            'applicant_email' => ['required', 'string', 'email', 'max:255'],
            'applicant_phone' => ['nullable', 'string', 'max:50'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ];
    }

    public function messages(): array
    {
        return [
            'church_name.required' => 'Nama gereja wajib diisi.',
            'slug.regex' => 'Format slug hanya boleh berisi huruf kecil, angka, dan tanda hubung (-).',
            'applicant_name.required' => 'Nama pemohon wajib diisi.',
            'applicant_email.required' => 'Email pemohon wajib diisi.',
            'applicant_email.email' => 'Format email tidak valid.',
            'password.required' => 'Kata sandi wajib diisi.',
            'password.min' => 'Kata sandi minimal 8 karakter.',
            'password.confirmed' => 'Konfirmasi kata sandi tidak cocok.',
        ];
    }
}
