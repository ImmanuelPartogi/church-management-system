<?php

namespace App\Models;

use App\Enums\DonationStatus;
use Database\Factories\DonationConfirmationFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Support\Carbon;

/**
 * @property DonationStatus $status
 * @property Carbon $transfer_date
 */
#[Fillable([
    'donation_number',
    'user_id',
    'member_id',
    'chart_of_account_id',
    'amount',
    'transfer_date',
    'sender_bank',
    'depositor_phone',
    'proof_file_path',
    'status',
    'notes',
    'rejection_reason',
    'reviewed_by',
    'reviewed_at',
])]
class DonationConfirmation extends Model
{
    /** @use HasFactory<DonationConfirmationFactory> */
    use HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'transfer_date' => 'date',
            'status' => DonationStatus::class,
            'reviewed_at' => 'datetime',
        ];
    }

    /**
     * Get the user that submitted the donation confirmation.
     *
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the church member associated with the donation.
     *
     * @return BelongsTo<ChurchMember, $this>
     */
    public function member(): BelongsTo
    {
        return $this->belongsTo(ChurchMember::class, 'member_id');
    }

    /**
     * Get the chart of account category for this donation.
     *
     * @return BelongsTo<ChartOfAccount, $this>
     */
    public function chartOfAccount(): BelongsTo
    {
        return $this->belongsTo(ChartOfAccount::class);
    }

    /**
     * Get the user/treasurer that reviewed the donation.
     *
     * @return BelongsTo<User, $this>
     */
    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }

    /**
     * Get the resulting financial transaction for this donation.
     *
     * @return HasOne<FinancialTransaction, $this>
     */
    public function financialTransaction(): HasOne
    {
        return $this->hasOne(FinancialTransaction::class, 'donation_confirmation_id');
    }
}
