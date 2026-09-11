<?php

namespace App\Services\Registration;

use App\Models\Church;
use App\Models\ChurchRegistration;
use App\Models\User;
use App\Notifications\Registration\ChurchRegistrationApprovedNotification;
use App\Notifications\Registration\ChurchRegistrationRejectedNotification;
use App\Notifications\Registration\ChurchRegistrationVerifyNotification;
use DomainException;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class ChurchRegistrationService
{
    /**
     * Reserved keyword slugs that cannot be claimed by public registrations.
     */
    public const RESERVED_SLUGS = [
        'admin', 'administrator', 'api', 'app', 'assets', 'backend', 'billing',
        'church', 'churches', 'dashboard', 'default', 'demo', 'dev', 'developer',
        'docs', 'help', 'login', 'logout', 'mail', 'master', 'mobile', 'null',
        'onboarding', 'panel', 'portal', 'register', 'root', 'sinode', 'superadmin',
        'support', 'synod', 'system', 'test', 'user', 'v1', 'v2', 'web',
    ];

    /**
     * Submit a new church registration request.
     *
     * @throws ValidationException
     */
    public function submit(array $data): ChurchRegistration
    {
        $slug = Str::slug($data['slug'] ?? $data['church_name']);

        if (in_array($slug, self::RESERVED_SLUGS, true)) {
            throw ValidationException::withMessages([
                'slug' => 'Slug "'.$slug.'" merupakan kata kunci terlarang sistem dan tidak dapat digunakan.',
            ]);
        }

        // Early existing user check (detected at submit-time for Super Admin review context)
        $existingUser = User::where('email', $data['applicant_email'])->first();

        try {
            $registration = ChurchRegistration::create([
                'church_name' => $data['church_name'],
                'slug' => $slug,
                'city' => $data['city'] ?? null,
                'address' => $data['address'] ?? null,
                'phone' => $data['phone'] ?? null,
                'timezone' => $data['timezone'] ?? 'Asia/Jakarta',
                'applicant_name' => $data['applicant_name'],
                'applicant_email' => $data['applicant_email'],
                'applicant_phone' => $data['applicant_phone'] ?? null,
                'applicant_password_hash' => Hash::make($data['password']),
                'existing_user_id' => $existingUser?->id,
                'status' => 'pending_email_verification',
            ]);
        } catch (QueryException $e) {
            // Catch race-condition on DB unique slug constraint and convert to clean 422
            if ($this->isUniqueConstraintViolation($e)) {
                throw ValidationException::withMessages([
                    'slug' => 'Slug "'.$slug.'" baru saja digunakan oleh pendaftar lain. Silakan pilih nama gereja atau slug lain.',
                ]);
            }

            throw $e;
        }

        // Send signed email verification notification
        Notification::route('mail', $registration->applicant_email)
            ->notify(new ChurchRegistrationVerifyNotification($registration));

        return $registration;
    }

    /**
     * Verify the applicant's email address via authoritative signed route.
     */
    public function verifyEmail(ChurchRegistration $registration): bool
    {
        if ($registration->status === 'pending_review') {
            return true; // Idempotent: already verified
        }

        if ($registration->status !== 'pending_email_verification') {
            return false;
        }

        $registration->update([
            'status' => 'pending_review',
            'verified_at' => now(),
        ]);

        return true;
    }

    /**
     * Approve registration: atomically creates Church, provisions modules,
     * assigns church_admin role, and sends confirmation email.
     *
     * @throws DomainException
     */
    public function approve(ChurchRegistration $registration, User $superAdmin): Church
    {
        if ($registration->status !== 'pending_review') {
            throw new DomainException('Hanya permohonan dengan status "pending_review" yang dapat disetujui.');
        }

        return DB::transaction(function () use ($registration, $superAdmin) {
            // 1. Create the Church entity (Triggers booted() auto-provisioning 12 modules)
            $church = Church::create([
                'uuid' => (string) Str::uuid(),
                'name' => $registration->church_name,
                'slug' => $registration->slug,
                'city' => $registration->city,
                'address' => $registration->address,
                'phone' => $registration->phone,
                'timezone' => $registration->timezone ?? 'Asia/Jakarta',
                'status' => 'active',
            ]);

            // 2. Resolve or create user
            if ($registration->existing_user_id) {
                $user = User::findOrFail($registration->existing_user_id);
            } else {
                $user = User::create([
                    'name' => $registration->applicant_name,
                    'email' => $registration->applicant_email,
                    'password' => $registration->applicant_password_hash,
                    'phone' => $registration->applicant_phone,
                    'is_super_admin' => false,
                ]);
            }

            // 3. Create church_admin membership
            $church->memberships()->create([
                'user_id' => $user->id,
                'role' => 'church_admin',
                'status' => 'active',
            ]);

            // 4. Ensure Spatie church_admin role exists for this new church team and assign
            app(PermissionRegistrar::class)->setPermissionsTeamId($church->id);

            $churchAdminRole = Role::firstOrCreate([
                'name' => 'church_admin',
                'guard_name' => 'web',
                'church_id' => $church->id,
            ]);
            $churchAdminRole->givePermissionTo(Permission::all());

            $user->assignRole('church_admin');

            // 5. Mark registration as approved
            $registration->update([
                'status' => 'approved',
                'church_id' => $church->id,
                'approved_by_user_id' => $superAdmin->id,
                'approved_at' => now(),
            ]);

            // 6. Send approval notification
            Notification::route('mail', $registration->applicant_email)
                ->notify(new ChurchRegistrationApprovedNotification($registration, $church));

            return $church;
        });
    }

    /**
     * Reject registration with an administrative reason.
     *
     * @throws DomainException
     */
    public function reject(ChurchRegistration $registration, User $superAdmin, string $reason): void
    {
        if (in_array($registration->status, ['approved', 'rejected'], true)) {
            throw new DomainException('Permohonan ini sudah diputuskan sebelumnya.');
        }

        $registration->update([
            'status' => 'rejected',
            'rejection_reason' => $reason,
            'approved_by_user_id' => $superAdmin->id,
        ]);

        Notification::route('mail', $registration->applicant_email)
            ->notify(new ChurchRegistrationRejectedNotification($registration, $reason));
    }

    /**
     * Hard-prune unverified church registrations older than the cutoff days.
     * Hard-delete is explicitly chosen over soft-expire to immediately release
     * the database-level unique slug constraint for legitimate future applicants.
     * Registrations with status pending_review (already verified) are never pruned.
     */
    public function pruneStaleUnverified(int $days = 7): int
    {
        $cutoff = now()->subDays($days);

        $staleQuery = ChurchRegistration::where('status', 'pending_email_verification')
            ->where('created_at', '<=', $cutoff);

        $count = $staleQuery->count();

        if ($count > 0) {
            $staleQuery->delete();

            Log::channel('single')->info('ChurchRegistrations.pruned_stale', [
                'count' => $count,
                'cutoff_days' => $days,
                'cutoff_timestamp' => $cutoff->toIso8601String(),
            ]);
        }

        return $count;
    }

    /**
     * Detect unique constraint violation across database drivers.
     */
    protected function isUniqueConstraintViolation(QueryException $e): bool
    {
        $message = strtolower($e->getMessage());
        $errorCode = (string) $e->getCode();

        // MySQL 1062, PostgreSQL 23505, SQLite 19 / constraint violation
        return str_contains($message, 'unique')
            || str_contains($message, 'duplicate')
            || in_array($errorCode, ['23000', '23505', '19'], true);
    }
}
