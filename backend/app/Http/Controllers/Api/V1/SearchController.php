<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\Search\GlobalSearchService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SearchController extends Controller
{
    public function __construct(
        protected GlobalSearchService $searchService
    ) {}

    /**
     * Perform global cross-module search.
     */
    public function search(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'q' => 'required|string|min:2|max:255',
            'limit' => 'nullable|integer|min:1|max:20',
        ]);

        $query = $validated['q'];
        $limit = isset($validated['limit']) ? (int) $validated['limit'] : 5;
        $user = $request->user();

        $data = $this->searchService->search($query, $user, $limit);

        return $this->jsonSuccess($data, 'Global search results retrieved successfully.');
    }
}
