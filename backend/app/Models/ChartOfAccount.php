<?php

namespace App\Models;

use App\Enums\FinanceAccountType;
use App\Traits\BelongsToChurch;
use Database\Factories\ChartOfAccountFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable([
    'code',
    'name',
    'type',
    'description',
    'is_active',
    'parent_id',
])]
class ChartOfAccount extends Model
{
    /** @use HasFactory<ChartOfAccountFactory> */
    use BelongsToChurch, HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'type' => FinanceAccountType::class,
            'is_active' => 'boolean',
        ];
    }

    /**
     * Get the parent account.
     *
     * @return BelongsTo<self, $this>
     */
    public function parent(): BelongsTo
    {
        return $this->belongsTo(self::class, 'parent_id');
    }

    /**
     * Get the child accounts.
     *
     * @return HasMany<self, $this>
     */
    public function children(): HasMany
    {
        return $this->hasMany(self::class, 'parent_id');
    }

    /**
     * Get the financial transactions for this account.
     *
     * @return HasMany<FinancialTransaction, $this>
     */
    public function transactions(): HasMany
    {
        return $this->hasMany(FinancialTransaction::class);
    }

    /**
     * Get the donation confirmations for this account.
     *
     * @return HasMany<DonationConfirmation, $this>
     */
    public function donations(): HasMany
    {
        return $this->hasMany(DonationConfirmation::class);
    }

    /**
     * Scope a query to only include active accounts.
     *
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }

    /**
     * Scope a query to only include income accounts.
     *
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeIncome(Builder $query): Builder
    {
        return $query->where('type', FinanceAccountType::Income);
    }

    /**
     * Scope a query to only include expense accounts.
     *
     * @param  Builder<self>  $query
     * @return Builder<self>
     */
    public function scopeExpense(Builder $query): Builder
    {
        return $query->where('type', FinanceAccountType::Expense);
    }
}
