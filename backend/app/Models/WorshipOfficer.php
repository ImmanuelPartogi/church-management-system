<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'worship_schedule_id',
    'member_id',
    'role',
])]
class WorshipOfficer extends Model
{
    /** @use HasFactory<Factory<self>> */
    use HasFactory;

    /**
     * Get the worship schedule associated with this officer.
     *
     * @return BelongsTo<WorshipSchedule, $this>
     */
    public function worshipSchedule(): BelongsTo
    {
        return $this->belongsTo(WorshipSchedule::class);
    }

    /**
     * Get the church member associated with this officer.
     *
     * @return BelongsTo<ChurchMember, $this>
     */
    public function member(): BelongsTo
    {
        return $this->belongsTo(ChurchMember::class);
    }
}
