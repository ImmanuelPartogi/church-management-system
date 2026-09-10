<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\ChurchResource;
use App\Models\Church;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChurchController extends Controller
{
    /**
     * Display a listing of active church tenants.
     * Public endpoint intended for mobile client onboarding and church selection.
     */
    public function index(Request $request): JsonResponse
    {
        $churches = Church::query()
            ->where('status', 'active')
            ->orderBy('name')
            ->get();

        return $this->jsonSuccess(
            ChurchResource::collection($churches),
            'Active churches retrieved successfully.'
        );
    }
}
