<?php

namespace App\Services\Tenant;

use App\Models\Church;
use App\Models\ChurchModule;
use App\Models\Module;
use InvalidArgumentException;

class ChurchModuleService
{
    /**
     * In-memory cache for enabled modules per church: [church_id => [module_key => bool]]
     *
     * @var array<int, array<string, bool>>
     */
    protected array $cache = [];

    /**
     * Determine whether a specific module is enabled for a given church.
     */
    public function isModuleEnabled(string $moduleKey, ?int $churchId = null): bool
    {
        $churchId ??= app()->has('current_church_id') ? app('current_church_id') : null;

        if (! $churchId) {
            return false;
        }

        if (isset($this->cache[$churchId][$moduleKey])) {
            return $this->cache[$churchId][$moduleKey];
        }

        $isEnabled = (bool) ChurchModule::query()
            ->where('church_id', $churchId)
            ->whereHas('module', fn ($query) => $query->where('key', $moduleKey))
            ->where('is_enabled', true)
            ->exists();

        $this->cache[$churchId][$moduleKey] = $isEnabled;

        return $isEnabled;
    }

    /**
     * Provision default modules for a church (Batteries-Included / All-Active).
     */
    public function provisionDefaults(Church $church): void
    {
        $modules = Module::all();

        if ($modules->isEmpty()) {
            return;
        }

        $now = now();

        foreach ($modules as $module) {
            ChurchModule::updateOrCreate(
                [
                    'church_id' => $church->id,
                    'module_id' => $module->id,
                ],
                [
                    'is_enabled' => true,
                    'enabled_at' => $now,
                    'disabled_at' => null,
                ]
            );
        }

        $this->clearCache($church->id);
    }

    /**
     * Enable a module for a church with strict parent dependency precondition.
     *
     * @throws InvalidArgumentException
     */
    public function enableModule(Church $church, string $moduleKey): void
    {
        $module = Module::with('parentModule')->where('key', $moduleKey)->firstOrFail();

        // Strict Precondition: If module has a parent, parent must already be enabled
        if ($module->parentModule && ! $this->isModuleEnabled($module->parentModule->key, $church->id)) {
            throw new InvalidArgumentException(
                "Tidak dapat mengaktifkan modul '{$module->name}' karena modul induk '{$module->parentModule->name}' belum aktif. Aktifkan modul induk terlebih dahulu."
            );
        }

        ChurchModule::updateOrCreate(
            [
                'church_id' => $church->id,
                'module_id' => $module->id,
            ],
            [
                'is_enabled' => true,
                'enabled_at' => now(),
                'disabled_at' => null,
            ]
        );

        $this->clearCache($church->id);
    }

    /**
     * Disable a module for a church with strict core and child dependency checks.
     *
     * @throws InvalidArgumentException
     */
    public function disableModule(Church $church, string $moduleKey): void
    {
        $module = Module::with('dependentModules')->where('key', $moduleKey)->firstOrFail();

        // Core Module Invariance: Core modules cannot be disabled
        if ($module->is_core) {
            throw new InvalidArgumentException("Modul inti '{$module->name}' tidak dapat dinonaktifkan.");
        }

        // Strict Precondition: Check if any dependent module is currently active
        $activeDependents = $module->dependentModules()
            ->whereHas('churchModules', fn ($query) => $query->where('church_id', $church->id)->where('is_enabled', true))
            ->get();

        if ($activeDependents->isNotEmpty()) {
            $names = $activeDependents->pluck('name')->implode(', ');
            throw new InvalidArgumentException(
                "Tidak dapat menonaktifkan modul '{$module->name}' karena modul '{$names}' masih aktif dan bergantung padanya. Nonaktifkan modul turunannya terlebih dahulu."
            );
        }

        ChurchModule::updateOrCreate(
            [
                'church_id' => $church->id,
                'module_id' => $module->id,
            ],
            [
                'is_enabled' => false,
                'disabled_at' => now(),
            ]
        );

        $this->clearCache($church->id);
    }

    /**
     * Clear the in-memory cache for a church, or completely.
     */
    public function clearCache(?int $churchId = null): void
    {
        if ($churchId !== null) {
            unset($this->cache[$churchId]);
        } else {
            $this->cache = [];
        }
    }
}
