<?php

namespace App\Models;

use App\Enums\FinanceAccountType;
use Database\Factories\FinancialTransactionFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property FinanceAccountType $type
 */
#[Fillable([
    'transaction_number',
    'transaction_date',
    'chart_of_account_id',
    'type',
    'amount',
    'description',
    'reference',
    'donation_confirmation_id',
    'created_by',
])]
class FinancialTransaction extends Model
{
    /** @use HasFactory<FinancialTransactionFactory> */
    use HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'transaction_date' => 'date',
            'type' => FinanceAccountType::class,
            'amount' => 'decimal:2',
        ];
    }

    /**
     * Get the chart of account category for this transaction.
     *
     * @return BelongsTo<ChartOfAccount, $this>
     */
    public function chartOfAccount(): BelongsTo
    {
        return $this->belongsTo(ChartOfAccount::class);
    }

    /**
     * Get the user that recorded the transaction.
     *
     * @return BelongsTo<User, $this>
     */
    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    /**
     * Get the donation confirmation that originated this transaction.
     *
     * @return BelongsTo<DonationConfirmation, $this>
     */
    public function donationConfirmation(): BelongsTo
    {
        return $this->belongsTo(DonationConfirmation::class, 'donation_confirmation_id');
    }
}
