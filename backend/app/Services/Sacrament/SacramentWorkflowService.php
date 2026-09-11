<?php

namespace App\Services\Sacrament;

use App\Enums\ServiceFormStatus;
use App\Models\ServiceFormApplication;
use App\Models\User;
use DomainException;
use Illuminate\Support\Facades\DB;

class SacramentWorkflowService
{
    /**
     * Submit an application into the sacrament approval workflow.
     *
     * @throws DomainException
     */
    public function submit(ServiceFormApplication $application, User $user): void
    {
        DB::transaction(function () use ($application, $user) {
            if (! $application->isSacrament()) {
                throw new DomainException('Alur persetujuan berjenjang hanya berlaku untuk formulir sakramen.');
            }

            // Guard: Self-registered users without linked ChurchMember profile must be rejected fail-loud
            if (! $user->member) {
                throw new DomainException('Akun Anda belum tertaut ke profil keanggotaan jemaat. Hubungi admin gereja untuk penautan sebelum mengajukan sakramen.');
            }

            $member = $user->member;
            $church = $member->church ?? $user->church;
            $requiresSector = $church?->requires_sector_verification ?? true;

            // Guard: When church requires sector verification, member must have an assigned sector
            if ($requiresSector && empty($member->sector_id)) {
                throw new DomainException('Profil keanggotaan Anda belum terdaftar dalam sektor manapun. Hubungi admin gereja untuk pembaruan sektor sebelum mengajukan sakramen.');
            }

            // If church deliberately disabled sector verification, bypass directly to SectorVerified
            $targetStatus = $requiresSector
                ? ServiceFormStatus::Pending
                : ServiceFormStatus::SectorVerified;

            $application->update([
                'user_id' => $user->id,
                'member_id' => $member->id,
                'status' => $targetStatus,
            ]);
        });
    }

    /**
     * Verify the sacrament application by the sectoral elder (Sintua).
     *
     * @throws DomainException
     */
    public function verifySector(ServiceFormApplication $application, User $verifier): void
    {
        DB::transaction(function () use ($application, $verifier) {
            if (! $application->isSacrament()) {
                throw new DomainException('Alur persetujuan berjenjang hanya berlaku untuk formulir sakramen.');
            }

            if ($application->status !== ServiceFormStatus::Pending) {
                throw new DomainException('Permohonan hanya dapat diverifikasi sektor saat berstatus menunggu verifikasi (Pending).');
            }

            $servant = $verifier->member?->servantProfile;
            if (! $servant || ! $servant->active) {
                throw new DomainException('Hanya Sintua aktif yang berwenang memverifikasi permohonan sektor.');
            }

            $applicantSectorId = $application->member?->sector_id;
            $assignedSectorIds = $servant->assignedSectors->pluck('id')->all();

            if (! $applicantSectorId || ! in_array($applicantSectorId, $assignedSectorIds, true)) {
                throw new DomainException('Sintua hanya dapat memverifikasi permohonan sakramen jemaat di sektor binaannya.');
            }

            $application->update([
                'status' => ServiceFormStatus::SectorVerified,
                'sector_reviewed_by' => $verifier->id,
                'sector_reviewed_at' => now(),
            ]);
        });
    }

    /**
     * Approve the sacrament application by the Lead Pastor (Pendeta Ressort).
     *
     * @throws DomainException
     */
    public function approvePastoral(ServiceFormApplication $application, User $pastor, ?int $worshipScheduleId = null): void
    {
        DB::transaction(function () use ($application, $pastor, $worshipScheduleId) {
            if (! $application->isSacrament()) {
                throw new DomainException('Alur persetujuan berjenjang hanya berlaku untuk formulir sakramen.');
            }

            $church = $application->church ?? $pastor->church;
            $requiresSector = $church?->requires_sector_verification ?? true;

            $allowedStatuses = $requiresSector
                ? [ServiceFormStatus::SectorVerified]
                : [ServiceFormStatus::SectorVerified, ServiceFormStatus::Pending];

            if (! in_array($application->status, $allowedStatuses, true)) {
                throw new DomainException('Permohonan sakramen harus diverifikasi oleh Sintua Sektor terlebih dahulu sebelum persetujuan pastoral.');
            }

            $servant = $pastor->member?->servantProfile;
            if (! $servant || ! $servant->active || ! $servant->is_lead_pastor) {
                throw new DomainException('Hanya Pendeta Ressort / Pimpinan Jemaat yang berwenang mengesahkan sakramen.');
            }

            $application->update([
                'status' => ServiceFormStatus::PastorApproved,
                'pastor_reviewed_by' => $pastor->id,
                'pastor_reviewed_at' => now(),
                'scheduled_worship_id' => $worshipScheduleId,
            ]);
        });
    }

    /**
     * Reject the sacrament application with a mandatory rejection reason.
     *
     * @throws DomainException
     */
    public function reject(ServiceFormApplication $application, User $reviewer, string $reason): void
    {
        DB::transaction(function () use ($application, $reviewer, $reason) {
            if (! $application->isSacrament()) {
                throw new DomainException('Alur persetujuan berjenjang hanya berlaku untuk formulir sakramen.');
            }

            if (! in_array($application->status, [ServiceFormStatus::Pending, ServiceFormStatus::SectorVerified], true)) {
                throw new DomainException('Permohonan sakramen yang sudah disetujui atau dibatalkan tidak dapat ditolak.');
            }

            if (trim($reason) === '') {
                throw new DomainException('Alasan penolakan permohonan sakramen wajib diisi.');
            }

            $application->update([
                'status' => ServiceFormStatus::Rejected,
                'rejection_reason' => trim($reason),
                'reviewed_by' => $reviewer->id,
                'reviewed_at' => now(),
            ]);
        });
    }

    /**
     * Mark the sacrament as completed and update the member's sacrament record.
     *
     * @throws DomainException
     */
    public function complete(ServiceFormApplication $application): void
    {
        DB::transaction(function () use ($application) {
            if (! $application->isSacrament()) {
                throw new DomainException('Alur persetujuan berjenjang hanya berlaku untuk formulir sakramen.');
            }

            if ($application->status !== ServiceFormStatus::PastorApproved) {
                throw new DomainException('Hanya permohonan yang telah disetujui pastoral yang dapat diselesaikan.');
            }

            $member = $application->member;
            if ($member) {
                $slug = $application->serviceFormType?->slug;
                $today = now()->toDateString();

                if ($slug === 'baptis') {
                    $member->update(['baptism_date' => $today]);
                } elseif ($slug === 'sidi') {
                    $member->update(['sidi_date' => $today]);
                }
            }

            $application->update([
                'status' => ServiceFormStatus::Completed,
                'sacrament_completed_at' => now(),
            ]);
        });
    }
}
