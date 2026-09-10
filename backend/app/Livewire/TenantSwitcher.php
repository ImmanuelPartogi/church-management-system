<?php

namespace App\Livewire;

use App\Models\Church;
use Filament\Notifications\Notification;
use Illuminate\Contracts\View\View;
use Livewire\Component;

class TenantSwitcher extends Component
{
    /**
     * Switch the active tenant context for super admin.
     */
    public function switchTenant(int $churchId): void
    {
        $user = auth()->user();
        if (! $user || ! $user->is_super_admin) {
            abort(403, 'Hanya super admin yang berwenang mengganti tenant.');
        }

        $church = Church::where('id', $churchId)
            ->where('status', 'active')
            ->firstOrFail();

        session(['active_church_id' => $church->id]);

        Notification::make()
            ->title("Tenant dialihkan ke {$church->name}")
            ->success()
            ->send();

        $this->redirect(request()->header('Referer') ?: '/admin', navigate: false);
    }

    public function render(): View
    {
        $user = auth()->user();
        $isSuperAdmin = (bool) ($user && $user->is_super_admin);
        $currentChurch = app()->bound('current_church') ? app('current_church') : null;
        $churches = $isSuperAdmin ? Church::where('status', 'active')->orderBy('name')->get() : collect();

        return view('livewire.tenant-switcher', [
            'isSuperAdmin' => $isSuperAdmin,
            'currentChurch' => $currentChurch,
            'churches' => $churches,
        ]);
    }
}
