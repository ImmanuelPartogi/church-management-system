<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\ChurchServantResource;
use App\Models\ChurchServant;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class ServantController extends Controller
{
    /**
     * Display a listing of active church servants.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = ChurchServant::query()
            ->with(['resort', 'sector', 'fellowship'])
            ->active();

        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where('name', 'like', "%{$search}%");
        }

        if ($request->filled('role')) {
            $query->where('role', $request->input('role'));
        }

        if ($request->filled('sector_id')) {
            $query->where('sector_id', $request->input('sector_id'));
        }

        $servants = $query->orderBy('name')->paginate(15);

        return ChurchServantResource::collection($servants);
    }

    /**
     * Display the specified church servant.
     */
    public function show(int $id): JsonResponse
    {
        $servant = ChurchServant::query()
            ->with(['resort', 'sector', 'fellowship'])
            ->active()
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Church servant details retrieved successfully.',
            'data' => new ChurchServantResource($servant),
        ]);
    }
}
