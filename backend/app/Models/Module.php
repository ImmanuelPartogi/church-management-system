<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable([
    'key',
    'name',
    'description',
    'is_core',
    'depends_on',
])]
class Module extends Model
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
            'is_core' => 'boolean',
        ];
    }

    /**
     * Get the churches that have configured this module.
     *
     * @return BelongsToMany<Church, $this>
     */
    public function churches(): BelongsToMany
    {
        return $this->belongsToMany(Church::class, 'church_modules')
            ->withPivot(['is_enabled', 'settings', 'enabled_at', 'disabled_at'])
            ->withTimestamps();
    }

    /**
     * Get the church module pivot entries.
     *
     * @return HasMany<ChurchModule, $this>
     */
    public function churchModules(): HasMany
    {
        return $this->hasMany(ChurchModule::class, 'module_id');
    }

    /**
     * Get the parent module that this module depends on.
     *
     * @return BelongsTo<Module, $this>
     */
    public function parentModule(): BelongsTo
    {
        return $this->belongsTo(Module::class, 'depends_on');
    }

    /**
     * Get the child modules that depend on this module.
     *
     * @return HasMany<Module, $this>
     */
    public function dependentModules(): HasMany
    {
        return $this->hasMany(Module::class, 'depends_on');
    }
}
