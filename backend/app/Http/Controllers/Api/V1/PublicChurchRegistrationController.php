<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Registration\RegisterChurchRequest;
use App\Models\Church;
use App\Models\ChurchRegistration;
use App\Services\Registration\ChurchRegistrationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PublicChurchRegistrationController extends Controller
{
    public function __construct(
        protected ChurchRegistrationService $registrationService
    ) {}

    /**
     * Submit a new church registration request.
     */
    public function submit(RegisterChurchRequest $request): JsonResponse
    {
        $registration = $this->registrationService->submit($request->validated());

        return response()->json([
            'message' => 'Pendaftaran gereja berhasil diajukan. Silakan periksa kotak masuk email Anda untuk melakukan verifikasi.',
            'data' => [
                'id' => $registration->id,
                'church_name' => $registration->church_name,
                'slug' => $registration->slug,
                'status' => $registration->status,
                'applicant_email' => $registration->applicant_email,
                'is_existing_user' => $registration->isExistingUser(),
            ],
        ], 201);
    }

    /**
     * Real-time slug availability check for onboarding form.
     */
    public function checkSlug(Request $request): JsonResponse
    {
        $request->validate([
            'slug' => ['required', 'string', 'max:100'],
        ]);

        $slug = Str::slug($request->query('slug'));

        if (empty($slug)) {
            return response()->json([
                'available' => false,
                'reason' => 'invalid_format',
                'message' => 'Format slug tidak valid.',
            ], 422);
        }

        if (in_array($slug, ChurchRegistrationService::RESERVED_SLUGS, true)) {
            return response()->json([
                'available' => false,
                'reason' => 'reserved',
                'message' => 'Slug ini merupakan reserved keyword sistem.',
            ]);
        }

        if (Church::where('slug', $slug)->exists()) {
            return response()->json([
                'available' => false,
                'reason' => 'church_exists',
                'message' => 'Slug ini sudah digunakan oleh gereja lain.',
            ]);
        }

        if (ChurchRegistration::where('slug', $slug)->where('status', '!=', 'rejected')->exists()) {
            return response()->json([
                'available' => false,
                'reason' => 'pending_registration',
                'message' => 'Slug ini sedang dalam proses peninjauan pendaftaran.',
            ]);
        }

        return response()->json([
            'available' => true,
            'slug' => $slug,
            'message' => 'Slug tersedia.',
        ]);
    }

    /**
     * Authoritative Email Verification endpoint.
     * Protected by the 'signed' middleware.
     */
    public function verify(Request $request, ChurchRegistration $registration): JsonResponse
    {
        $verified = $this->registrationService->verifyEmail($registration);

        if (! $verified) {
            return response()->json([
                'message' => 'Status pendaftaran tidak valid untuk diverifikasi atau sudah diproses sebelumnya.',
                'status' => $registration->status,
            ], 422);
        }

        return response()->json([
            'message' => 'Email pendaftaran berhasil diverifikasi. Permohonan Anda kini masuk antrean peninjauan Super Admin Sinode.',
            'status' => 'pending_review',
            'verified_at' => $registration->verified_at?->toIso8601String(),
        ]);
    }
}
