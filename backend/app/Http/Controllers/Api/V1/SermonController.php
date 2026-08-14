<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\SermonResource;
use App\Models\Sermon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

class SermonController extends Controller
{
    /**
     * Display a listing of published sermons.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Sermon::query()
            ->with(['servant'])
            ->latestPublished();

        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                    ->orWhere('preacher_name', 'like', "%{$search}%");
            });
        }

        $sermons = $query->paginate(15);

        return SermonResource::collection($sermons);
    }

    /**
     * Display the specified sermon.
     */
    public function show(int $id): JsonResponse
    {
        $sermon = Sermon::query()
            ->with(['servant'])
            ->published()
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Sermon retrieved successfully.',
            'data' => new SermonResource($sermon),
        ]);
    }

    /**
     * Download or stream the sermon file and increment download count.
     */
    public function download(int $id): StreamedResponse|JsonResponse
    {
        $sermon = Sermon::query()
            ->published()
            ->findOrFail($id);

        $sermon->increment('download_count');

        if ($sermon->file_path && Storage::disk('public')->exists($sermon->file_path)) {
            return Storage::disk('public')->download(
                $sermon->file_path,
                $sermon->file_name ?? 'sermon-'.$sermon->id.'.pdf'
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Download counter recorded.',
            'data' => [
                'id' => $sermon->id,
                'download_count' => $sermon->download_count,
            ],
        ]);
    }
}
