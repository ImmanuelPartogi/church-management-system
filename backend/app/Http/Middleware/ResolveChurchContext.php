<?php

namespace App\Http\Middleware;

use App\Models\Church;
use App\Models\ChurchMember;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;
use Spatie\Permission\PermissionRegistrar;
use Symfony\Component\HttpFoundation\Response;

class ResolveChurchContext
{
    /**
     * Handle an incoming request.
     *
     * @param  Closure(Request): (Response)  $next
     * @param  string  $mode  'strict' (default) requires active membership for non-super-admins; 'optional' allows unassigned identity inspection.
     */
    public function handle(Request $request, Closure $next, string $mode = 'strict'): Response
    {
        // Bypass tenant context resolution for logout and login entry/exit routes
        if ($request->is('admin/logout', 'logout', '*/logout', 'admin/login', 'login', '*/login', 'preview/*')) {
            return $next($request);
        }

        if (! Schema::hasTable('churches')) {
            return $next($request);
        }

        // 1. Identify Target Church from request input (Header or Session)
        $targetChurch = null;
        $explicitHeaderProvided = false;

        $churchIdHeader = $request->header('X-Church-Id');
        $churchSlugHeader = $request->header('X-Church-Slug');

        if (! empty($churchIdHeader)) {
            $explicitHeaderProvided = true;
            $targetChurch = Church::find($churchIdHeader);
            if (! $targetChurch) {
                return response()->json([
                    'success' => false,
                    'message' => 'Church tenant not found.',
                ], 404);
            }
        } elseif (! empty($churchSlugHeader)) {
            $explicitHeaderProvided = true;
            $targetChurch = Church::where('slug', (string) $churchSlugHeader)->first();
            if (! $targetChurch) {
                return response()->json([
                    'success' => false,
                    'message' => 'Church tenant not found.',
                ], 404);
            }
        }

        // Validate suspension on explicitly requested church
        if ($targetChurch && $targetChurch->status === 'suspended') {
            return response()->json([
                'success' => false,
                'message' => 'Church tenant is suspended.',
            ], 403);
        }

        $resolvedChurch = null;

        // 2. Authenticated User Branch (supports both web/session and Sanctum token guards)
        $user = $request->user() ?: auth('sanctum')->user();
        if ($user) {
            if ($user->is_super_admin) {
                // Super Admin has full authority to select any church or defaults to default church
                if ($targetChurch) {
                    $resolvedChurch = $targetChurch;
                } elseif ($request->hasSession() && ($sessionId = $request->session()->get('active_church_id'))) {
                    $resolvedChurch = Church::find($sessionId);
                }

                if (! $resolvedChurch) {
                    $defaultSlug = (string) config('tenant.default_church_slug', 'default');
                    $resolvedChurch = Church::where('slug', $defaultSlug)->first();
                }
            } else {
                // Non-super-admin branch:
                // ANTI-SPOOFING CHECK: Explicit header check runs before missing membership guard.
                // Even in :optional mode, sending an explicit unauthorized header represents an intentional
                // cross-tenant spoofing attempt and must strictly be rejected with 403 Forbidden.
                if ($explicitHeaderProvided) {
                    $isMember = Schema::hasTable('church_user_memberships') && $user->memberships()
                        ->where('church_id', $targetChurch->id)
                        ->where('status', 'active')
                        ->exists();

                    if (! $isMember) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Unauthorized tenant access: You are not an active member of this church.',
                            'code' => 'TENANT_MEMBERSHIP_MISMATCH',
                            'errors' => null,
                        ], 403);
                    }

                    $resolvedChurch = $targetChurch;
                } else {
                    // Check session for active church selection (e.g. Filament panel)
                    if ($request->hasSession() && ($sessionId = $request->session()->get('active_church_id'))) {
                        $isSessionMember = Schema::hasTable('church_user_memberships') && $user->memberships()
                            ->where('church_id', $sessionId)
                            ->where('status', 'active')
                            ->exists();

                        if ($isSessionMember) {
                            $resolvedChurch = Church::find($sessionId);
                        } else {
                            // Defensive Self-Cleansing (ADR 4): Stale session from another user is purged
                            // rather than causing an availability lockout (DoS).
                            $request->session()->forget('active_church_id');
                        }
                    }

                    // Fallback to user's primary active membership
                    if (! $resolvedChurch && Schema::hasTable('church_user_memberships')) {
                        $activeMembership = $user->memberships()
                            ->where('status', 'active')
                            ->with('church')
                            ->first();

                        $resolvedChurch = $activeMembership?->church;
                    }

                    // Fallback to user's registered church member profile
                    if (! $resolvedChurch && Schema::hasTable('church_members')) {
                        $member = ChurchMember::withoutChurch()->where('user_id', $user->id)->first();
                        $resolvedChurch = $member?->church;
                    }

                    // Missing Membership Guard:
                    // If non-super-admin user has NO active church membership:
                    if (! $resolvedChurch) {
                        if ($mode === 'optional') {
                            // In optional mode (e.g. /auth/me, /profile), allow request through with context unbound
                            return $next($request);
                        }

                        // Return JSON for API requests
                        if ($request->expectsJson() || $request->is('api/*')) {
                            return response()->json([
                                'success' => false,
                                'message' => 'User has no active church membership.',
                                'code' => 'NO_ACTIVE_MEMBERSHIP',
                                'errors' => null,
                            ], 403);
                        }

                        // Return custom styled error view for browser / web navigation
                        return response()->view('errors.no-membership', [
                            'title' => 'Keanggotaan Gereja Belum Terdaftar',
                            'message' => 'Akun Anda saat ini belum terhubung dengan keanggotaan gereja aktif mana pun. Hubungi administrator gereja untuk mendapatkan akses.',
                            'code' => 'NO_ACTIVE_MEMBERSHIP',
                        ], 403);
                    }
                }
            }
        } else {
            // 3. Unauthenticated Branch (Public Endpoints, e.g. /auth/firebase, /wartas, /daily-verse)
            if ($targetChurch) {
                $resolvedChurch = $targetChurch;
            } else {
                $defaultSlug = (string) config('tenant.default_church_slug', 'default');
                $resolvedChurch = Church::where('slug', $defaultSlug)->first();
            }
        }

        // Validate resolved church status
        if ($resolvedChurch) {
            if ($resolvedChurch->status === 'suspended') {
                if ($request->expectsJson() || $request->is('api/*')) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Church tenant is suspended.',
                    ], 403);
                }

                return response()->view('errors.no-membership', [
                    'title' => 'Gereja Sedang Ditangguhkan',
                    'message' => 'Tenant gereja ini sedang dinonaktifkan / ditangguhkan (suspended).',
                    'code' => 'TENANT_SUSPENDED',
                ], 403);
            }

            // 4. Atomic Context Bindings (Single Source of Truth)
            app()->instance('current_church_id', $resolvedChurch->id);
            app()->instance('current_church', $resolvedChurch);

            if (config('permission.teams')) {
                app(PermissionRegistrar::class)->setPermissionsTeamId($resolvedChurch->id);
            }
        }

        return $next($request);
    }
}
