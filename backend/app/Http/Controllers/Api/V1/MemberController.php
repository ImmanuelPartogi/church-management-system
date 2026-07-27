<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\ChurchMemberResource;
use App\Models\ChurchMember;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MemberController extends Controller
{
    /**
     * Display a listing of the members.
     */
    public function index(Request $request): JsonResponse
    {
        $query = ChurchMember::query();

        // Optional search by name
        if ($request->has('search')) {
            $search = $request->input('search');
            $query->where('full_name', 'like', '%'.$search.'%');
        }

        // Optional filter by status
        if ($request->has('status')) {
            $query->where('status', $request->input('status'));
        }

        $members = $query->paginate(15);

        return $this->jsonPaginated(ChurchMemberResource::collection($members), 'Members retrieved successfully.');
    }

    /**
     * Display the specified member.
     */
    public function show(string $id): JsonResponse
    {
        $member = ChurchMember::find($id);

        if (! $member) {
            return $this->jsonError('Member not found.', null, 404);
        }

        return $this->jsonSuccess(new ChurchMemberResource($member), 'Member retrieved successfully.');
    }
}
