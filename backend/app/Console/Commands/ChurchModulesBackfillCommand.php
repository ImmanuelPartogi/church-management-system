<?php

namespace App\Console\Commands;

use App\Models\Church;
use App\Models\ChurchModule;
use App\Models\Module;
use App\Services\Tenant\ChurchModuleService;
use Database\Seeders\ModuleSeeder;
use Illuminate\Console\Command;

class ChurchModulesBackfillCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'churches:backfill-modules
                            {--dry-run : Preview missing modules without making database changes}
                            {--church= : Backfill a specific church by ID or slug}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Idempotently provision default modules for existing churches created before Phase 4B';

    /**
     * Execute the console command.
     */
    public function handle(ChurchModuleService $moduleService): int
    {
        $isDryRun = (bool) $this->option('dry-run');
        $churchFilter = $this->option('church');

        $this->info($isDryRun ? '=== CHURCH MODULES BACKFILL (DRY RUN) ===' : '=== CHURCH MODULES BACKFILL (REAL RUN) ===');
        $this->newLine();

        // 1. Ensure Module Catalog is populated
        if (Module::count() === 0) {
            $this->warn('Module catalog table is empty. Seeding official modules first...');
            if (! $isDryRun) {
                $seeder = new ModuleSeeder;
                $seeder->run();
                $this->info('Module catalog successfully seeded with '.Module::count().' modules.');
            } else {
                $this->line('  [DRY-RUN] Would seed ModuleSeeder (12 modules).');
            }
        }

        $allModules = Module::all();
        $totalCatalogCount = $allModules->count();

        // 2. Query target churches
        $churchQuery = Church::withTrashed();
        if ($churchFilter) {
            $churchQuery->where(function ($q) use ($churchFilter) {
                if (is_numeric($churchFilter)) {
                    $q->where('id', (int) $churchFilter);
                }
                $q->orWhere('slug', $churchFilter);
            });
        }

        $churches = $churchQuery->orderBy('id')->get();

        if ($churches->isEmpty()) {
            $this->warn('No churches found matching the criteria.');

            return self::SUCCESS;
        }

        $rows = [];
        $totalProvisionedChurches = 0;
        $totalModulesAdded = 0;

        foreach ($churches as $church) {
            $existingModuleIds = ChurchModule::where('church_id', $church->id)->pluck('module_id')->toArray();
            $missingModules = $allModules->whereNotIn('id', $existingModuleIds);
            $missingCount = $missingModules->count();

            if ($missingCount === 0) {
                $status = '<info>Complete (12/12)</info>';
                $action = 'None needed';
            } else {
                if ($isDryRun) {
                    $status = "<comment>Missing {$missingCount} modules</comment>";
                    $action = "Would provision: {$missingModules->pluck('key')->implode(', ')}";
                } else {
                    $moduleService->provisionDefaults($church);
                    $status = "<info>Provisioned ({$missingCount} added)</info>";
                    $action = "Added: {$missingModules->pluck('key')->implode(', ')}";
                    $totalProvisionedChurches++;
                    $totalModulesAdded += $missingCount;
                }
            }

            $rows[] = [
                'ID' => $church->id,
                'Name' => $church->name,
                'Slug' => $church->slug,
                'Existing' => count($existingModuleIds).' / '.$totalCatalogCount,
                'Status' => $status,
                'Action' => $action,
            ];
        }

        $this->table(['ID', 'Name', 'Slug', 'Modules Count', 'Status', 'Action'], $rows);
        $this->newLine();

        if ($isDryRun) {
            $this->info('Dry-run complete. Run without --dry-run to apply provisioning changes.');
        } else {
            $this->info("Backfill complete! Updated {$totalProvisionedChurches} churches with {$totalModulesAdded} module configurations.");
        }

        return self::SUCCESS;
    }
}
