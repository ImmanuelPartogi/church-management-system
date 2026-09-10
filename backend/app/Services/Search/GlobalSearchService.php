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
use App\Services\Tenant\ChurchModuleService;

class GlobalSearchService
{
    public function __construct(
        protected ChurchModuleService $moduleService
    ) {}

    /**
     * Perform cross-module global search.
     *
     * @return array<string, mixed>
     */
    public function search(string $query, ?User $currentUser = null, int $limit = 5): array
    {
        $q = trim($query);
        $isSuperAdmin = $currentUser?->is_super_admin === true;

        // 1. Members (Only for authenticated users to respect UU PDP privacy, and if membership module is enabled)
        $members = [];
        if ($currentUser && ($isSuperAdmin || $this->moduleService->isModuleEnabled('membership'))) {
            $memberModels = ChurchMember::query()
                ->where('status', 'active')
                ->where('full_name', 'like', "%{$q}%")
                ->take($limit)
                ->get();
            $members = MemberDirectoryResource::collection($memberModels)->resolve();
        }

        // 2. Servants (community module)
        $servants = [];
        if ($isSuperAdmin || $this->moduleService->isModuleEnabled('community')) {
            $servantModels = ChurchServant::query()
                ->where('active', true)
                ->where(function ($builder) use ($q) {
                    $builder->where('name', 'like', "%{$q}%")
                        ->orWhere('role', 'like', "%{$q}%");
                })
                ->take($limit)
                ->get();
            $servants = ChurchServantResource::collection($servantModels)->resolve();
        }

        // 3. Sermons (sermons module)
        $sermons = [];
        if ($isSuperAdmin || $this->moduleService->isModuleEnabled('sermons')) {
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
        }

        // 4. Songs / Hymns (hymns module)
        $hymns = [];
        if ($isSuperAdmin || $this->moduleService->isModuleEnabled('hymns')) {
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
        }

        // 5. Warta (warta module)
        $wartas = [];
        if ($isSuperAdmin || $this->moduleService->isModuleEnabled('warta')) {
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
        }

        // 6. Announcements (announcements module)
        $announcements = [];
        if ($isSuperAdmin || $this->moduleService->isModuleEnabled('announcements')) {
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
        }

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
