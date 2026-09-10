<?php

namespace App\Providers;

use App\Models\Church;
use App\Models\User;
use App\Services\Tenant\ChurchModuleService;
use Illuminate\Auth\Events\Login;
use Illuminate\Auth\Events\Logout;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Queue\Events\JobFailed;
use Illuminate\Queue\Events\JobProcessed;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->singleton(ChurchModuleService::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RateLimiter::for('firebase-auth', function (Request $request) {
            return Limit::perMinute(10)->by($request->ip());
        });

        // Session fixation defense (ADR 4): purge active_church_id on login and logout
        Event::listen(Logout::class, function () {
            if (request()->hasSession()) {
                session()->forget('active_church_id');
            }
        });

        Event::listen(Login::class, function () {
            if (request()->hasSession()) {
                session()->forget('active_church_id');
            }
        });

        // Super admin bypasses all Gate/Policy checks unconditionally,
        // EXCEPT deletion of Church tenants (which is permanently blocked to prevent catastrophic CASCADE data loss).
        // Does NOT cover direct hasAnyRole()/hasPermissionTo() — those bypass Gate.
        Gate::before(function (User $user, string $ability, array $arguments = []) {
            if (in_array($ability, ['delete', 'forceDelete'], true) && isset($arguments[0]) && ($arguments[0] instanceof Church || $arguments[0] === Church::class)) {
                return false;
            }

            if ($user->is_super_admin) {
                return true;
            }
        });

        // PERMANENT — Vendor model safety net (BelongsToChurch equivalent for non-modifiable Spatie models).
        // Spatie's Role model lives in vendor/ and cannot use the BelongsToChurch trait directly.
        // This listener ensures that any Role::create() or Role::firstOrCreate() without explicit church_id
        // automatically inherits the active tenant context (getPermissionsTeamId() or app('current_church_id')),
        // or fails loud with a RuntimeException if context is missing (no silent fallbacks or magic numbers).
        Role::creating(function (Role $role) {
            if (config('permission.teams') && empty($role->church_id)) {
                $teamId = getPermissionsTeamId() ?: (app()->bound('current_church_id') ? app('current_church_id') : null);
                if (! $teamId) {
                    throw new \RuntimeException('Tenant context is missing — cannot create Role without an active church context.');
                }

                $role->church_id = $teamId;
            }
        });

        // Worker context safety net (ADR 8.2): reset tenant context on queue worker daemon
        Queue::after(function (JobProcessed $event) {
            app()->forgetInstance('current_church_id');
            app()->forgetInstance('current_church');
            if (config('permission.teams')) {
                app(PermissionRegistrar::class)->setPermissionsTeamId(null);
            }
        });

        Queue::failing(function (JobFailed $event) {
            app()->forgetInstance('current_church_id');
            app()->forgetInstance('current_church');
            if (config('permission.teams')) {
                app(PermissionRegistrar::class)->setPermissionsTeamId(null);
            }
        });
    }
}
