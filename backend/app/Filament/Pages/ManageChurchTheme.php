<?php

namespace App\Filament\Pages;

use App\Models\Church;
use Filament\Forms\Components\ColorPicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Illuminate\Support\Facades\Gate;

class ManageChurchTheme extends Page implements HasForms
{
    use InteractsWithForms;

    protected static string $routePath = '/church-theme';

    protected static ?string $title = 'Identitas & Tema Gereja';

    protected static ?string $navigationLabel = 'Tema & Branding';

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-paint-brush';

    protected static string|\UnitEnum|null $navigationGroup = 'Pengaturan Gereja';

    protected static ?int $navigationSort = 50;

    protected string $view = 'filament.pages.manage-church-theme';

    public ?Church $church = null;

    /**
     * @var array<string, mixed> | null
     */
    public ?array $data = [];

    /**
     * Determine access permission for navigation and routing.
     */
    public static function canAccess(): bool
    {
        $user = auth()->user();
        if (! $user) {
            return false;
        }

        if ($user->is_super_admin) {
            return true;
        }

        return $user->hasRole('church_admin')
            && app()->bound('current_church_id')
            && app('current_church_id') !== null
            && $user->memberships()
                ->where('church_id', app('current_church_id'))
                ->where('status', 'active')
                ->exists();
    }

    /**
     * Deterministic mount:
     * 1. Resolution Layer: Record is resolved strictly from app('current_church_id').
     *    Zero route or query parameter dependencies.
     * 2. Authorization Layer: Gate::authorize('updateTheme', $church).
     */
    public function mount(): void
    {
        if (! app()->bound('current_church_id') || ! app('current_church_id')) {
            abort(403, 'Tidak ada konteks gereja aktif yang teresolusi.');
        }

        $churchId = (int) app('current_church_id');
        $church = Church::find($churchId);

        if (! $church) {
            abort(404, 'Gereja aktif tidak ditemukan.');
        }

        Gate::authorize('updateTheme', $church);

        $this->church = $church;

        $this->form->fill([
            'theme_primary_color' => $church->theme_primary_color,
            'theme_secondary_color' => $church->theme_secondary_color,
            'logo_path' => $church->logo_path,
        ]);
    }

    /**
     * Form schema definition.
     */
    public function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Section::make('Warna Identitas Visual')
                    ->description('Warna ini akan otomatis menjadi palet tema aplikasi mobile jemaat.')
                    ->schema([
                        ColorPicker::make('theme_primary_color')
                            ->label('Warna Primer (Brand Utama)')
                            ->required()
                            ->default('#1B4B66'),

                        ColorPicker::make('theme_secondary_color')
                            ->label('Warna Sekunder (Aksen & Tombol)')
                            ->required()
                            ->default('#F5A623'),

                        FileUpload::make('logo_path')
                            ->label('Logo Resmi Gereja')
                            ->image()
                            ->directory('church-logos')
                            ->maxSize(2048)
                            ->nullable()
                            ->columnSpanFull(),
                    ])->columns(2),
            ])
            ->statePath('data');
    }

    /**
     * Save action with zero-trust payload filtering and WCAG contrast check.
     */
    public function save(): void
    {
        Gate::authorize('updateTheme', $this->church);

        $state = $this->form->getState();

        $primaryColor = $state['theme_primary_color'] ?? '#1B4B66';
        $secondaryColor = $state['theme_secondary_color'] ?? '#F5A623';

        // Validasi Kontras WCAG terhadap teks putih (#FFFFFF)
        $this->validateWcagContrast($primaryColor, 'Warna Primer');
        $this->validateWcagContrast($secondaryColor, 'Warna Sekunder');

        // Zero-Trust Payload Filtering: Hanya memutasi kolom tema yang diizinkan
        $this->church->update([
            'theme_primary_color' => $primaryColor,
            'theme_secondary_color' => $secondaryColor,
            'logo_path' => $state['logo_path'] ?? null,
        ]);

        Notification::make()
            ->title('Tema gereja berhasil diperbarui')
            ->success()
            ->send();
    }

    /**
     * Validate WCAG relative luminance contrast ratio against white (#FFFFFF).
     */
    public function validateWcagContrast(string $hexColor, string $label): void
    {
        $lum = $this->calculateRelativeLuminance($hexColor);
        $ratio = (1.0 + 0.05) / ($lum + 0.05);

        if ($ratio < 4.5) {
            Notification::make()
                ->warning()
                ->title("Peringatan Kontras Rendah: {$label}")
                ->body(sprintf('Rasio kontras %s (%s) terhadap teks putih adalah %.2f:1 (di bawah standar WCAG AA 4.5:1). Teks putih di atas warna ini mungkin sulit dibaca oleh jemaat.', $label, $hexColor, $ratio))
                ->persistent()
                ->send();
        }
    }

    /**
     * Calculate relative luminance according to WCAG 2.1 specifications.
     */
    public function calculateRelativeLuminance(string $hexColor): float
    {
        $hex = ltrim($hexColor, '#');
        if (strlen($hex) === 3) {
            $hex = $hex[0].$hex[0].$hex[1].$hex[1].$hex[2].$hex[2];
        }

        $r = hexdec(substr($hex, 0, 2)) / 255.0;
        $g = hexdec(substr($hex, 2, 2)) / 255.0;
        $b = hexdec(substr($hex, 4, 2)) / 255.0;

        $rLin = ($r <= 0.03928) ? $r / 12.92 : pow(($r + 0.055) / 1.055, 2.4);
        $gLin = ($g <= 0.03928) ? $g / 12.92 : pow(($g + 0.055) / 1.055, 2.4);
        $bLin = ($b <= 0.03928) ? $b / 12.92 : pow(($b + 0.055) / 1.055, 2.4);

        return 0.2126 * $rLin + 0.7152 * $gLin + 0.0722 * $bLin;
    }
}
