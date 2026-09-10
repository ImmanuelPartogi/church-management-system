<?php

namespace App\Filament\Traits;

use App\Services\Tenant\ChurchModuleService;

trait HasModuleAccess
{
    /**
     * Get the module key that controls access to this resource.
     */
    abstract public static function getModuleKey(): string;

    /**
     * Determine if this resource should register in the navigation sidebar.
     */
    public static function shouldRegisterNavigation(): bool
    {
        if (auth()->user()?->is_super_admin) {
            return true;
        }

        return app(ChurchModuleService::class)->isModuleEnabled(static::getModuleKey());
    }

    /**
     * Determine whether the user can view any records for this resource.
     */
    public static function canViewAny(): bool
    {
        if (auth()->user()?->is_super_admin) {
            return true;
        }

        if (! app(ChurchModuleService::class)->isModuleEnabled(static::getModuleKey())) {
            return false;
        }

        return parent::canViewAny();
    }
}
