<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\PermissionRegistrar;
use Spatie\Permission\Traits\HasRoles;

#[Fillable(['name', 'email', 'phone', 'address', 'firebase_uid', 'password', 'is_super_admin'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable implements FilamentUser
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, HasRoles, Notifiable;

    /**
     * Determine if the user can access the given Filament panel.
     */
    public function canAccessPanel(Panel $panel): bool
    {
        // Super admin always has panel access regardless of team context.
        // Gate::before does NOT intercept hasAnyRole(), so this explicit check is needed.
        if ($this->is_super_admin) {
            return true;
        }

        $panelRoles = ['church_admin', 'pastor', 'staff', 'bendahara', 'sintua'];

        $teamId = app(PermissionRegistrar::class)->getPermissionsTeamId();

        if ($teamId !== null) {
            return $this->hasAnyRole($panelRoles);
        }

        // Multi-tenant fallback: during pre-auth / Livewire login before team context is set,
        // verify whether the user has a qualifying operational role in any church.
        return $this->memberships()
            ->whereIn('role', $panelRoles)
            ->where('status', 'active')
            ->exists()
            || DB::table('model_has_roles')
                ->join('roles', 'roles.id', '=', 'model_has_roles.role_id')
                ->where('model_has_roles.model_type', get_class($this))
                ->where('model_has_roles.model_id', $this->id)
                ->whereIn('roles.name', $panelRoles)
                ->exists();
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_super_admin' => 'boolean',
        ];
    }

    /**
     * Get the church member profile associated with this user.
     *
     * @return HasOne<ChurchMember, $this>
     */
    public function member(): HasOne
    {
        return $this->hasOne(ChurchMember::class);
    }

    /**
     * Get the device tokens registered for this user.
     *
     * @return HasMany<DeviceToken, $this>
     */
    public function deviceTokens(): HasMany
    {
        return $this->hasMany(DeviceToken::class);
    }

    /**
     * Get the church memberships for this user.
     *
     * @return HasMany<ChurchUserMembership, $this>
     */
    public function memberships(): HasMany
    {
        return $this->hasMany(ChurchUserMembership::class);
    }

    /**
     * Get all churches this user belongs to.
     *
     * @return BelongsToMany<Church, $this>
     */
    public function churches(): BelongsToMany
    {
        return $this->belongsToMany(Church::class, 'church_user_memberships')
            ->withPivot(['role', 'status', 'joined_at'])
            ->withTimestamps();
    }
}
