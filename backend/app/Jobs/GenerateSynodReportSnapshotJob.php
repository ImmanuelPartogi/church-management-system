<?php

namespace App\Jobs;

use App\Contracts\Queue\CrossTenantJob;
use App\Enums\DonationStatus;
use App\Models\Church;
use App\Models\ChurchMember;
use App\Models\ChurchModule;
use App\Models\DonationConfirmation;
use App\Models\Module;
use App\Models\ServiceFormApplication;
use App\Models\SynodReportSnapshot;
use App\Traits\Queue\CrossTenantJobTrait;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Cache\Repository as CacheRepository;
use Illuminate\Contracts\Queue\ShouldBeUnique;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Cache;

class GenerateSynodReportSnapshotJob implements CrossTenantJob, ShouldBeUnique, ShouldQueue
{
    use CrossTenantJobTrait, Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /**
     * The number of seconds after which the job's unique lock will be released.
     */
    public int $uniqueFor = 300;

    /**
     * Create a new job instance.
     */
    public function __construct(
        public ?string $periodDate = null
    ) {
        $this->initCrossTenantDispatcher();
    }

    /**
     * The unique ID of the job for queue-level deduplication.
     */
    public function uniqueId(): string
    {
        return 'synod_report_snapshot_generation';
    }

    /**
     * Get the cache store implementation for the job's unique lock.
     */
    public function uniqueVia(): CacheRepository
    {
        return Cache::store();
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        $allChurches = Church::orderBy('name', 'asc')->get();
        $totalChurches = $allChurches->count();
        $activeChurches = $allChurches->where('status', 'active');
        $activeChurchesCount = $activeChurches->count();
        $suspendedChurchesCount = $allChurches->where('status', 'suspended')->count();

        $activeChurchIds = $activeChurches->pluck('id')->all();

        // 1. Members
        $totalActiveMembers = ChurchMember::withoutChurch()
            ->whereHas('church', fn ($q) => $q->where('status', 'active'))
            ->count();

        $totalAllMembers = ChurchMember::withoutChurch()->count();

        // 2. Approved Donations
        $totalActiveDonations = (float) DonationConfirmation::withoutChurch()
            ->where('status', DonationStatus::Approved->value)
            ->whereHas('church', fn ($q) => $q->where('status', 'active'))
            ->sum('amount');

        $totalAllDonations = (float) DonationConfirmation::withoutChurch()
            ->where('status', DonationStatus::Approved->value)
            ->sum('amount');

        // 3. Sacraments
        $totalActiveSacraments = ServiceFormApplication::withoutChurch()
            ->whereHas('church', fn ($q) => $q->where('status', 'active'))
            ->count();

        $totalAllSacraments = ServiceFormApplication::withoutChurch()->count();

        // 4. Church Comparisons
        $churchComparisons = $allChurches->map(function ($church) {
            return [
                'id' => $church->id,
                'name' => $church->name,
                'slug' => $church->slug,
                'status' => $church->status,
                'member_count' => ChurchMember::withoutChurch()->where('church_id', $church->id)->count(),
                'active_modules_count' => ChurchModule::where('church_id', $church->id)->where('is_enabled', true)->count(),
                'total_donations' => (float) DonationConfirmation::withoutChurch()
                    ->where('church_id', $church->id)
                    ->where('status', DonationStatus::Approved->value)
                    ->sum('amount'),
            ];
        })->values()->all();

        // 5. Module Adoption
        $modules = Module::orderBy('id', 'asc')->get();
        $moduleAdoption = $modules->map(function ($module) use ($activeChurchesCount, $activeChurchIds) {
            $activeCount = ChurchModule::where('module_id', $module->id)
                ->where('is_enabled', true)
                ->whereIn('church_id', $activeChurchIds)
                ->count();

            $percentage = $activeChurchesCount > 0
                ? round(($activeCount / $activeChurchesCount) * 100, 1)
                : 0.0;

            return [
                'key' => $module->key,
                'name' => $module->name,
                'is_core' => (bool) $module->is_core,
                'active_count' => $activeCount,
                'total_active_churches' => $activeChurchesCount,
                'adoption_percentage' => $percentage,
            ];
        })->values()->all();

        // 6. Persist deterministic snapshot
        SynodReportSnapshot::create([
            'generated_by_user_id' => $this->dispatchedByUserId,
            'period_date' => $this->periodDate ?? now()->toDateString(),
            'total_churches' => $totalChurches,
            'active_churches' => $activeChurchesCount,
            'suspended_churches' => $suspendedChurchesCount,
            'total_active_members' => $totalActiveMembers,
            'total_all_members' => $totalAllMembers,
            'total_active_donations' => $totalActiveDonations,
            'total_all_donations' => $totalAllDonations,
            'total_active_sacraments' => $totalActiveSacraments,
            'total_all_sacraments' => $totalAllSacraments,
            'church_comparisons' => $churchComparisons,
            'module_adoption' => $moduleAdoption,
        ]);
    }
}
