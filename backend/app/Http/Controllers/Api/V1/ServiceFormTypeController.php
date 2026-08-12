<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\ServiceFormTypeResource;
use App\Models\ServiceFormType;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ServiceFormTypeController extends Controller
{
    /**
     * Display a listing of active service form types.
     */
    public function index(Request $request): JsonResponse
    {
        $types = ServiceFormType::where('active', true)
            ->orderBy('name')
            ->paginate(10);

        return $this->jsonPaginated(ServiceFormTypeResource::collection($types), 'Service form types retrieved successfully.');
    }

    /**
     * Display the specified active service form type details.
     */
    public function show(int $id): JsonResponse
    {
        $type = ServiceFormType::where('active', true)->find($id);

        if (! $type) {
            return $this->jsonError('Service form type not found.', null, 404);
        }

        return $this->jsonSuccess(new ServiceFormTypeResource($type), 'Service form type details retrieved successfully.');
    }
}
