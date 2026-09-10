<?php

namespace App\Support;

/**
 * Provides deterministic tenant-partitioned directory paths for file & media storage.
 */
class TenantStorage
{
    /**
     * Generate a tenant-partitioned storage path for file uploads.
     *
     * @param  string  $directory  Relative feature directory (e.g. 'announcements', 'sermons', 'wartas')
     * @param  int|null  $churchId  Explicit church ID, or defaults to active current_church_id
     * @return string e.g. "tenants/1/announcements" or "tenants/global/announcements"
     */
    public static function path(string $directory, ?int $churchId = null): string
    {
        $churchId ??= app()->bound('current_church_id') ? app('current_church_id') : null;
        $prefix = $churchId ? "tenants/{$churchId}" : 'tenants/global';

        return $prefix.'/'.trim($directory, '/');
    }
}
