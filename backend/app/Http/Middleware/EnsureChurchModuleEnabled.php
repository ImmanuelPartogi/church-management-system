<?php

namespace App\Http\Middleware;

use App\Services\Tenant\ChurchModuleService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureChurchModuleEnabled
{
    public function __construct(
        protected ChurchModuleService $moduleService
    ) {}

    /**
     * Handle an incoming request.
     *
     * @param  Closure(Request): (Response)  $next
     */
    public function handle(Request $request, Closure $next, string $moduleKey): Response
    {
        // ADR 6.5: Super Admins are completely bypassed for support/audit purposes
        $user = $request->user() ?: auth('sanctum')->user();
        if ($user?->is_super_admin === true) {
            return $next($request);
        }

        $churchId = app()->has('current_church_id') ? app('current_church_id') : null;

        // If church context is resolved and module is not enabled for this church
        if ($churchId && ! $this->moduleService->isModuleEnabled($moduleKey, $churchId)) {
            return response()->json([
                'success' => false,
                'message' => 'Fitur ini tidak diaktifkan untuk gereja yang dipilih.',
                'code' => 'MODULE_DISABLED',
                'module' => $moduleKey,
                'errors' => null,
            ], 403);
        }

        return $next($request);
    }
}
