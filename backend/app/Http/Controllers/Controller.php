<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

abstract class Controller
{
    /**
     * Return a standardized success JSON response.
     */
    protected function jsonSuccess(mixed $data = null, string $message = 'Success', int $code = 200): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data,
        ], $code);
    }

    /**
     * Return a standardized error JSON response.
     */
    protected function jsonError(string $message = 'Error', mixed $errors = null, int $code = 400): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors' => $errors,
        ], $code);
    }

    /**
     * Return a standardized paginated success JSON response.
     */
    protected function jsonPaginated(AnonymousResourceCollection $resourceCollection, string $message = 'Success', int $code = 200): JsonResponse
    {
        $response = $resourceCollection->response()->getData(true);

        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $response['data'] ?? [],
            'links' => $response['links'] ?? null,
            'meta' => $response['meta'] ?? null,
        ], $code);
    }
}
