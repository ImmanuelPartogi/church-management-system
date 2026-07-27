<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ChurchMemberResource;
use App\Models\ChurchMember;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class MemberController extends Controller
{
    /**
     * Display a listing of the members.
     */
    public function index(Request $request): AnonymousResourceCollection
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

        return ChurchMemberResource::collection($members);
    }

    /**
     * Display the specified member.
     */
    public function show(string $id): JsonResponse|ChurchMemberResource
    {
        $member = ChurchMember::find($id);

        if (! $member) {
            return response()->json([
                'message' => 'Member not found.',
            ], 404);
        }

        return new ChurchMemberResource($member);
    }
}
