<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable([
    'title',
    'description',
    'day',
    'start_time',
    'end_time',
    'location',
    'active',
])]
class WorshipSchedule extends Model
{
    /** @use HasFactory<Factory<self>> */
    use HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'active' => 'boolean',
        ];
    }

    /**
     * Get the officers assigned to this worship schedule.
     *
     * @return HasMany<WorshipOfficer, $this>
     */
    public function officers(): HasMany
    {
        return $this->hasMany(WorshipOfficer::class);
    }
}
