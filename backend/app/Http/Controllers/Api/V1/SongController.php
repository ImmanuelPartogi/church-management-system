<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\SongbookResource;
use App\Http\Resources\Api\SongResource;
use App\Models\Song;
use App\Models\Songbook;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SongController extends Controller
{
    /**
     * Display a listing of active songbooks.
     */
    public function songbooks(): JsonResponse
    {
        $songbooks = Songbook::active()
            ->withCount(['songs' => fn ($query) => $query->where('active', true)])
            ->orderBy('id', 'asc')
            ->get();

        return $this->jsonSuccess(SongbookResource::collection($songbooks), 'Songbooks retrieved successfully.');
    }

    /**
     * Display a listing of active songs with optional search and songbook filtering.
     */
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'search' => ['nullable', 'string', 'max:255'],
            'songbook_id' => ['nullable', 'integer', 'exists:songbooks,id'],
        ]);

        $query = Song::active()
            ->whereHas('songbook', fn ($q) => $q->where('active', true))
            ->with('songbook');

        if ($request->filled('songbook_id')) {
            $query->where('songbook_id', $request->input('songbook_id'));
        }

        if ($request->filled('search')) {
            $search = trim((string) $request->input('search'));
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                    ->orWhere('lyrics', 'like', "%{$search}%");

                if (is_numeric($search)) {
                    $q->orWhere('number', (int) $search);
                }
            });
        }

        $songs = $query->orderBy('songbook_id', 'asc')
            ->orderBy('number', 'asc')
            ->paginate(15);

        return $this->jsonPaginated(SongResource::collection($songs), 'Songs retrieved successfully.');
    }

    /**
     * Display details of a specific active song.
     */
    public function show(int $id): JsonResponse
    {
        $song = Song::active()
            ->whereHas('songbook', fn ($q) => $q->where('active', true))
            ->with('songbook')
            ->find($id);

        if (! $song) {
            return $this->jsonError('Song not found.', null, 404);
        }

        return $this->jsonSuccess(new SongResource($song), 'Song details retrieved successfully.');
    }
}
