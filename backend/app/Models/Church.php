<?php

namespace App\Models;

use App\Services\Tenant\ChurchModuleService;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

#[Fillable([
    'uuid',
    'name',
    'slug',
    'status',
    'timezone',
    'address',
    'phone',
    'logo_path',
    'theme_primary_color',
    'theme_secondary_color',
    'theme_version',
    'requires_sector_verification',
])]
class Church extends Model
{
    /** @use HasFactory<Factory<self>> */
    use HasFactory, SoftDeletes;

    /**
     * The model's default values for attributes.
     *
     * @var array<string, mixed>
     */
    protected $attributes = [
        'theme_primary_color' => '#1B4B66',
        'theme_secondary_color' => '#F5A623',
        'theme_version' => 1,
        'requires_sector_verification' => true,
    ];

    /**
     * The attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'theme_version' => 'integer',
            'requires_sector_verification' => 'boolean',
        ];
    }

    /**
     * The "booted" method of the model.
     */
    protected static function booted(): void
    {
        static::created(function (Church $church) {
            app(ChurchModuleService::class)->provisionDefaults($church);
        });

        static::updating(function (Church $church) {
            if ($church->isDirty(['theme_primary_color', 'theme_secondary_color', 'logo_path'])) {
                $church->theme_version = ((int) ($church->theme_version ?? 1)) + 1;
            }
        });
    }

    /**
     * Get the user memberships associated with this church.
     *
     * @return HasMany<ChurchUserMembership, $this>
     */
    public function memberships(): HasMany
    {
        return $this->hasMany(ChurchUserMembership::class, 'church_id');
    }

    /**
     * Get the modules enabled or configured for this church.
     *
     * @return BelongsToMany<Module, $this>
     */
    public function modules(): BelongsToMany
    {
        return $this->belongsToMany(Module::class, 'church_modules')
            ->withPivot(['is_enabled', 'settings', 'enabled_at', 'disabled_at'])
            ->withTimestamps();
    }

    /**
     * Get the module configurations directly.
     *
     * @return HasMany<ChurchModule, $this>
     */
    public function churchModules(): HasMany
    {
        return $this->hasMany(ChurchModule::class, 'church_id');
    }
}
