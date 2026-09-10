<?php

namespace App\Models;

use App\Traits\BelongsToChurch;
use Database\Factories\ServiceFormTypeFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable([
    'name',
    'slug',
    'description',
    'fee_amount',
    'active',
])]
class ServiceFormType extends Model
{
    /** @use HasFactory<ServiceFormTypeFactory> */
    use BelongsToChurch, HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'fee_amount' => 'decimal:2',
            'active' => 'boolean',
        ];
    }

    /**
     * Get the service form applications associated with this form type.
     *
     * @return HasMany<ServiceFormApplication, $this>
     */
    public function applications(): HasMany
    {
        return $this->hasMany(ServiceFormApplication::class);
    }
}
