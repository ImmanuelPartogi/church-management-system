<?php

namespace App\Services\Search;

use App\Http\Resources\Api\AnnouncementResource;
use App\Http\Resources\Api\ChurchServantResource;
use App\Http\Resources\Api\MemberDirectoryResource;
use App\Http\Resources\Api\SermonResource;
use App\Http\Resources\Api\SongResource;
use App\Http\Resources\Api\WartaResource;
use App\Models\Announcement;
use App\Models\ChurchMember;
use App\Models\ChurchServant;
use App\Models\Sermon;
use App\Models\Song;
use App\Models\User;
use App\Models\Warta;

class GlobalSearchService
{
    /**
     * Perform cross-module global search.
     *
     * @return array<string, mixed>
     */
    public function search(string $query, ?User $currentUser = null, int $limit = 5): array
    {
        $q = trim($query);

        // 1. Members (Only for authenticated users to respect UU PDP privacy)
        $members = [];
        if ($currentUser) {
            $memberModels = ChurchMember::query()
                ->where('status', 'active')
                ->where('full_name', 'like', "%{$q}%")
                ->take($limit)
                ->get();
            $members = MemberDirectoryResource::collection($memberModels)->resolve();
        }

        // 2. Servants
        $servantModels = ChurchServant::query()
            ->where('active', true)
            ->where(function ($builder) use ($q) {
                $builder->where('name', 'like', "%{$q}%")
                    ->orWhere('role', 'like', "%{$q}%");
            })
            ->take($limit)
            ->get();
        $servants = ChurchServantResource::collection($servantModels)->resolve();

        // 3. Sermons
        $sermonModels = Sermon::query()
            ->where('is_published', true)
            ->where('published_at', '<=', now())
            ->where(function ($builder) use ($q) {
                $builder->where('title', 'like', "%{$q}%")
                    ->orWhere('preacher_name', 'like', "%{$q}%")
                    ->orWhere('description', 'like', "%{$q}%");
            })
            ->orderBy('published_at', 'desc')
            ->take($limit)
            ->get();
        $sermons = SermonResource::collection($sermonModels)->resolve();

        // 4. Songs / Hymns
        $songQuery = Song::query()->where('active', true);
        if (is_numeric($q)) {
            $songQuery->where(function ($builder) use ($q) {
                $builder->where('number', (int) $q)
                    ->orWhere('title', 'like', "%{$q}%");
            });
        } else {
            $songQuery->where(function ($builder) use ($q) {
                $builder->where('title', 'like', "%{$q}%")
                    ->orWhere('lyrics', 'like', "%{$q}%");
            });
        }
        $songModels = $songQuery->take($limit)->get();
        $hymns = SongResource::collection($songModels)->resolve();

        // 5. Warta
        $wartaModels = Warta::query()
            ->where('is_published', true)
            ->where('published_at', '<=', now())
            ->where(function ($builder) use ($q) {
                $builder->where('title', 'like', "%{$q}%")
                    ->orWhere('description', 'like', "%{$q}%");
            })
            ->orderBy('published_at', 'desc')
            ->take($limit)
            ->get();
        $wartas = WartaResource::collection($wartaModels)->resolve();

        // 6. Announcements
        $announcementModels = Announcement::query()
            ->where('status', 'published')
            ->where('published_at', '<=', now())
            ->where(function ($builder) use ($q) {
                $builder->where('title', 'like', "%{$q}%")
                    ->orWhere('content', 'like', "%{$q}%");
            })
            ->orderBy('published_at', 'desc')
            ->take($limit)
            ->get();
        $announcements = AnnouncementResource::collection($announcementModels)->resolve();

        $memberCount = count($members);
        $servantCount = count($servants);
        $sermonCount = count($sermons);
        $hymnCount = count($hymns);
        $wartaCount = count($wartas);
        $announcementCount = count($announcements);

        $totalCount = $memberCount + $servantCount + $sermonCount + $hymnCount + $wartaCount + $announcementCount;

        return [
            'query' => $q,
            'results' => [
                'members' => $members,
                'servants' => $servants,
                'sermons' => $sermons,
                'hymns' => $hymns,
                'wartas' => $wartas,
                'announcements' => $announcements,
            ],
            'meta' => [
                'total' => $totalCount,
                'counts' => [
                    'members' => $memberCount,
                    'servants' => $servantCount,
                    'sermons' => $sermonCount,
                    'hymns' => $hymnCount,
                    'wartas' => $wartaCount,
                    'announcements' => $announcementCount,
                ],
            ],
        ];
    }
}
