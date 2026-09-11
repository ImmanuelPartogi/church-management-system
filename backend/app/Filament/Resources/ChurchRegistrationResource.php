<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ChurchRegistrationResource\Pages;
use App\Models\ChurchRegistration;
use App\Services\Registration\ChurchRegistrationService;
use Filament\Actions\Action;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;

class ChurchRegistrationResource extends Resource
{
    protected static ?string $model = ChurchRegistration::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-clipboard-document-check';

    protected static \UnitEnum|string|null $navigationGroup = 'Pengaturan Gereja';

    protected static ?string $modelLabel = 'Pendaftaran Gereja';

    protected static ?string $pluralModelLabel = 'Pendaftaran Gereja Baru';

    protected static ?int $navigationSort = 15;

    public static function canViewAny(): bool
    {
        return (bool) auth()->user()?->is_super_admin;
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(Model $record): bool
    {
        return false;
    }

    public static function canDelete(Model $record): bool
    {
        return false;
    }

    public static function getNavigationBadge(): ?string
    {
        $count = ChurchRegistration::pendingReview()->count();

        return $count > 0 ? (string) $count : null;
    }

    public static function getNavigationBadgeColor(): string|array|null
    {
        return 'warning';
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('church_name')
                    ->label('Nama Gereja')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('slug')
                    ->label('Slug')
                    ->searchable()
                    ->copyable()
                    ->color('gray'),

                Tables\Columns\TextColumn::make('applicant_name')
                    ->label('Pemohon')
                    ->searchable(),

                Tables\Columns\TextColumn::make('applicant_email')
                    ->label('Email Pemohon')
                    ->searchable()
                    ->copyable(),

                Tables\Columns\TextColumn::make('existing_user_id')
                    ->label('Tipe Akun')
                    ->badge()
                    ->colors([
                        'info' => fn ($state): bool => $state !== null,
                        'gray' => fn ($state): bool => $state === null,
                    ])
                    ->icons([
                        'heroicon-o-user-check' => fn ($state): bool => $state !== null,
                        'heroicon-o-user-plus' => fn ($state): bool => $state === null,
                    ])
                    ->formatStateUsing(fn ($state): string => $state !== null ? 'User Terdaftar' : 'Pendaftar Baru')
                    ->tooltip(fn (ChurchRegistration $record): string => $record->existing_user_id
                        ? "Pemohon sudah memiliki akun terdaftar (User ID #{$record->existing_user_id})"
                        : 'Pemohon belum memiliki akun (akan dibuatkan akun baru saat approval)'
                    ),

                Tables\Columns\TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->colors([
                        'warning' => 'pending_email_verification',
                        'primary' => 'pending_review',
                        'success' => 'approved',
                        'danger' => 'rejected',
                    ])
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending_email_verification' => 'Verifikasi Email',
                        'pending_review' => 'Menunggu Review',
                        'approved' => 'Disetujui',
                        'rejected' => 'Ditolak',
                        default => $state,
                    }),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Diajukan Pada')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Filter Status')
                    ->options([
                        'pending_email_verification' => 'Menunggu Verifikasi Email',
                        'pending_review' => 'Menunggu Review Sinode',
                        'approved' => 'Disetujui',
                        'rejected' => 'Ditolak',
                    ]),
            ])
            ->actions([
                Action::make('approve')
                    ->label('Setujui')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->modalHeading('Setujui Pendaftaran Gereja')
                    ->modalDescription(fn (ChurchRegistration $record): string => "Apakah Anda yakin ingin menyetujui pendaftaran {$record->church_name}? Sistem akan otomatis membuat gereja baru, mem-provisioning modul, dan mengangkat {$record->applicant_name} sebagai admin.")
                    ->visible(fn (ChurchRegistration $record): bool => $record->status === 'pending_review')
                    ->action(function (ChurchRegistration $record) {
                        $service = app(ChurchRegistrationService::class);
                        $church = $service->approve($record, auth()->user());

                        Notification::make()
                            ->title("Pendaftaran {$church->name} berhasil disetujui!")
                            ->body('Gereja baru telah aktif dan modul telah di-provisioning.')
                            ->success()
                            ->send();
                    }),

                Action::make('reject')
                    ->label('Tolak')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->modalHeading('Tolak Permohonan Pendaftaran')
                    ->form([
                        Forms\Components\Textarea::make('reason')
                            ->label('Alasan Penolakan')
                            ->placeholder('Jelaskan alasan penolakan secara administratif...')
                            ->required()
                            ->rows(3),
                    ])
                    ->visible(fn (ChurchRegistration $record): bool => in_array($record->status, ['pending_review', 'pending_email_verification'], true))
                    ->action(function (ChurchRegistration $record, array $data) {
                        $service = app(ChurchRegistrationService::class);
                        $service->reject($record, auth()->user(), $data['reason']);

                        Notification::make()
                            ->title("Permohonan {$record->church_name} telah ditolak.")
                            ->danger()
                            ->send();
                    }),
            ])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListChurchRegistrations::route('/'),
        ];
    }
}
