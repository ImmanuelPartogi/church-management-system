<?php

namespace App\Models;

use App\Enums\PaymentStatus;
use App\Enums\ServiceFormStatus;
use App\Traits\BelongsToChurch;
use Database\Factories\ServiceFormApplicationFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @property ServiceFormStatus $status
 * @property PaymentStatus $payment_status
 */
#[Fillable([
    'application_number',
    'user_id',
    'member_id',
    'service_form_type_id',
    'status',
    'applicant_notes',
    'rejection_reason',
    'payment_status',
    'payment_notes',
    'reviewed_by',
    'reviewed_at',
    'sector_reviewed_by',
    'sector_reviewed_at',
    'pastor_reviewed_by',
    'pastor_reviewed_at',
    'scheduled_worship_id',
    'sacrament_completed_at',
])]
class ServiceFormApplication extends Model
{
    /** @use HasFactory<ServiceFormApplicationFactory> */
    use BelongsToChurch, HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'status' => ServiceFormStatus::class,
            'payment_status' => PaymentStatus::class,
            'reviewed_at' => 'datetime',
            'sector_reviewed_at' => 'datetime',
            'pastor_reviewed_at' => 'datetime',
            'sacrament_completed_at' => 'datetime',
        ];
    }

    /**
     * Get the user that submitted the application.
     *
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the church member associated with the application.
     *
     * @return BelongsTo<ChurchMember, $this>
     */
    public function member(): BelongsTo
    {
        return $this->belongsTo(ChurchMember::class, 'member_id');
    }

    /**
     * Get the service form type associated with the application.
     *
     * @return BelongsTo<ServiceFormType, $this>
     */
    public function serviceFormType(): BelongsTo
    {
        return $this->belongsTo(ServiceFormType::class);
    }

    /**
     * Get the user that reviewed the application.
     *
     * @return BelongsTo<User, $this>
     */
    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }

    /**
     * Get the supporting documents uploaded for the application.
     *
     * @return HasMany<ServiceFormDocument, $this>
     */
    public function documents(): HasMany
    {
        return $this->hasMany(ServiceFormDocument::class);
    }

    /**
     * Get the sector reviewer (Sintua) who verified this application.
     *
     * @return BelongsTo<User, $this>
     */
    public function sectorReviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sector_reviewed_by');
    }

    /**
     * Get the pastoral reviewer (Lead Pastor) who approved this application.
     *
     * @return BelongsTo<User, $this>
     */
    public function pastoralReviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'pastor_reviewed_by');
    }

    /**
     * Get the worship schedule assigned for this sacrament service.
     *
     * @return BelongsTo<WorshipSchedule, $this>
     */
    public function scheduledWorship(): BelongsTo
    {
        return $this->belongsTo(WorshipSchedule::class, 'scheduled_worship_id');
    }

    /**
     * Determine if this application is for a liturgical sacrament.
     */
    public function isSacrament(): bool
    {
        return (bool) ($this->serviceFormType?->is_sacrament ?? false);
    }

    /**
     * Scope a query to only include sacrament applications.
     *
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeSacraments(Builder $query): Builder
    {
        return $query->whereHas('serviceFormType', fn ($q) => $q->where('is_sacrament', true));
    }

    /**
     * Scope a query to only include standard non-sacrament form applications.
     *
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeNonSacraments(Builder $query): Builder
    {
        return $query->whereHas('serviceFormType', fn ($q) => $q->where('is_sacrament', false));
    }
}
