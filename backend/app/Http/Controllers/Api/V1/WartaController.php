<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\WartaResource;
use App\Models\Warta;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

class WartaController extends Controller
{
    /**
     * Display a listing of published digital wartas.
     */
    public function index(Request $request): JsonResponse
    {
        $wartas = Warta::latestPublished()->paginate(10);

        return $this->jsonPaginated(WartaResource::collection($wartas), 'Wartas retrieved successfully.');
    }

    /**
     * Display the specified published warta details.
     */
    public function show(int $id): JsonResponse
    {
        $warta = Warta::published()->find($id);

        if (! $warta) {
            return $this->jsonError('Warta not found.', null, 404);
        }

        return $this->jsonSuccess(new WartaResource($warta), 'Warta details retrieved successfully.');
    }

    /**
     * Download the specified published warta PDF file.
     */
    public function download(int $id): JsonResponse|StreamedResponse
    {
        $warta = Warta::published()->find($id);

        if (! $warta) {
            return $this->jsonError('Warta not found.', null, 404);
        }

        if (! Storage::disk('public')->exists($warta->file_path)) {
            return $this->jsonError('Warta file not found on server.', null, 404);
        }

        // Increment download count atomically
        $warta->increment('download_count');

        $fileName = $warta->file_name ?? basename($warta->file_path);

        return Storage::disk('public')->download($warta->file_path, $fileName);
    }
}
