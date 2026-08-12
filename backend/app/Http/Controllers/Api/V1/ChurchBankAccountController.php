<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\ChurchBankAccountResource;
use App\Models\ChurchBankAccount;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChurchBankAccountController extends Controller
{
    /**
     * Display a listing of active church bank accounts.
     */
    public function index(Request $request): JsonResponse
    {
        $accounts = ChurchBankAccount::active()->get();

        return $this->jsonSuccess(ChurchBankAccountResource::collection($accounts), 'Church bank accounts retrieved successfully.');
    }
}
