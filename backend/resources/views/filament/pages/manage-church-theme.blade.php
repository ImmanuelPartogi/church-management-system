<x-filament-panels::page>
    <form wire:submit="save">
        {{ $this->form }}

        <div class="mt-6 flex items-center gap-3">
            <x-filament::button type="submit">
                Simpan Perubahan Tema
            </x-filament::button>
        </div>
    </form>
</x-filament-panels::page>
