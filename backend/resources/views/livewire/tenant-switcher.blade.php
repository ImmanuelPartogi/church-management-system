<div class="fi-topbar-item" style="display: flex; align-items: center; margin-right: 0.5rem;">
    @if ($isSuperAdmin)
        <x-filament::dropdown placement="bottom-end">
            <x-slot name="trigger">
                <button 
                    type="button" 
                    class="fi-btn fi-size-sm fi-color-gray"
                    style="display: inline-flex; align-items: center; gap: 0.375rem; padding: 0.35rem 0.65rem; border-radius: 0.5rem; border: 1px solid #d1d5db; background-color: #ffffff; color: #374151; font-size: 0.75rem; font-weight: 500; line-height: 1.25; cursor: pointer; box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);"
                    id="tenant-switcher-button"
                    title="Ganti Tenant Gereja"
                >
                    <x-filament::icon 
                        icon="heroicon-m-building-office-2" 
                        class="fi-size-sm" 
                        style="width: 16px; height: 16px; min-width: 16px; max-width: 16px; color: #2563eb;" 
                    />
                    <span style="max-width: 160px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-weight: 600; color: #1e293b;">
                        {{ $currentChurch ? $currentChurch->name : 'Pilih Gereja' }}
                    </span>
                    <span style="display: inline-flex; align-items: center; padding: 0.125rem 0.375rem; border-radius: 0.25rem; font-size: 9px; font-weight: 700; background-color: #fef3c7; color: #92400e; letter-spacing: 0.025em;">
                        TENANT
                    </span>
                    <x-filament::icon 
                        icon="heroicon-m-chevron-down" 
                        class="fi-size-sm" 
                        style="width: 14px; height: 14px; min-width: 14px; max-width: 14px; color: #9ca3af;" 
                    />
                </button>
            </x-slot>

            <x-filament::dropdown.header>
                Pilih Gereja (Super Admin)
            </x-filament::dropdown.header>

            <x-filament::dropdown.list>
                @foreach ($churches as $church)
                    <x-filament::dropdown.list.item 
                        wire:click="switchTenant({{ $church->id }})"
                        :icon="($currentChurch && $currentChurch->id === $church->id) ? 'heroicon-m-check-circle' : 'heroicon-m-building-office'"
                        :color="($currentChurch && $currentChurch->id === $church->id) ? 'primary' : 'gray'"
                    >
                        {{ $church->name }}
                    </x-filament::dropdown.list.item>
                @endforeach
            </x-filament::dropdown.list>
        </x-filament::dropdown>
    @elseif ($currentChurch)
        <div 
            style="display: inline-flex; align-items: center; gap: 0.375rem; padding: 0.35rem 0.65rem; border-radius: 0.5rem; border: 1px solid #e5e7eb; background-color: #f9fafb; color: #4b5563; font-size: 0.75rem; font-weight: 500;"
        >
            <x-filament::icon 
                icon="heroicon-m-building-office-2" 
                class="fi-size-sm" 
                style="width: 16px; height: 16px; min-width: 16px; max-width: 16px; color: #6b7280;" 
            />
            <span style="max-width: 160px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: #374151;">
                {{ $currentChurch->name }}
            </span>
        </div>
    @endif
</div>
