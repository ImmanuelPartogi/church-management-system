<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\PaymentStatus;
use App\Enums\ServiceFormStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\StoreServiceFormApplicationRequest;
use App\Http\Resources\Api\ServiceFormApplicationResource;
use App\Models\ServiceFormApplication;
use App\Models\ServiceFormDocument;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ServiceFormApplicationController extends Controller
{
    /**
     * Display a listing of applications submitted by the authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $applications = ServiceFormApplication::where('user_id', $user->id)
            ->with(['serviceFormType', 'documents'])
            ->latest()
            ->paginate(10);

        return $this->jsonPaginated(ServiceFormApplicationResource::collection($applications), 'Applications retrieved successfully.');
    }

    /**
     * Display the specified application details for the authenticated user.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $user = $request->user();

        $application = ServiceFormApplication::with(['serviceFormType', 'documents'])->find($id);

        if (! $application) {
            return $this->jsonError('Application not found.', null, 404);
        }

        // Strict ownership check
        if ($application->user_id !== $user->id) {
            return $this->jsonError('You are not authorized to view this application.', null, 403);
        }

        return $this->jsonSuccess(new ServiceFormApplicationResource($application), 'Application details retrieved successfully.');
    }

    /**
     * Submit a new service form application for the authenticated user.
     */
    public function store(StoreServiceFormApplicationRequest $request): JsonResponse
    {
        $user = $request->user();
        $member = $user->member;

        $validated = $request->validated();

        $application = DB::transaction(function () use ($user, $member, $validated, $request) {
            $app = ServiceFormApplication::create([
                'application_number' => 'APP-'.date('Ymd').'-'.strtoupper(Str::random(6)),
                'user_id' => $user->id,
                'member_id' => $member?->id,
                'service_form_type_id' => $validated['service_form_type_id'],
                'status' => ServiceFormStatus::Pending,
                'applicant_notes' => $validated['applicant_notes'] ?? null,
                'rejection_reason' => null,
                'payment_status' => PaymentStatus::Unpaid,
                'payment_notes' => null,
                'reviewed_by' => null,
                'reviewed_at' => null,
            ]);

            if ($request->has('documents') && is_array($request->input('documents'))) {
                foreach ($request->input('documents') as $index => $docData) {
                    if ($request->hasFile("documents.{$index}.file")) {
                        $file = $request->file("documents.{$index}.file");
                        $path = Storage::disk('public')->putFile('service_form_documents', $file);

                        ServiceFormDocument::create([
                            'service_form_application_id' => $app->id,
                            'document_name' => $docData['document_name'],
                            'file_path' => $path,
                            'file_name' => $file->getClientOriginalName(),
                            'mime_type' => $file->getClientMimeType(),
                            'file_size' => $file->getSize(),
                        ]);
                    }
                }
            }

            return $app;
        });

        $application->load(['serviceFormType', 'documents']);

        return $this->jsonSuccess(new ServiceFormApplicationResource($application), 'Service form application submitted successfully.', 201);
    }
}
