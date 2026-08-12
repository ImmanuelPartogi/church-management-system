<?php

namespace App\Models;

use App\Enums\PaymentStatus;
use App\Enums\ServiceFormStatus;
use Database\Factories\ServiceFormApplicationFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

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
])]
class ServiceFormApplication extends Model
{
    /** @use HasFactory<ServiceFormApplicationFactory> */
    use HasFactory;

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
}
