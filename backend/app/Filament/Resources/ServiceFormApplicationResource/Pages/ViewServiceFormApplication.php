<?php

namespace App\Filament\Resources\ServiceFormApplicationResource\Pages;

use App\Enums\ServiceFormStatus;
use App\Filament\Resources\ServiceFormApplicationResource;
use App\Models\ServiceFormApplication;
use App\Services\Sacrament\SacramentWorkflowService;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ViewRecord;
use Illuminate\Support\Facades\Auth;

class ViewServiceFormApplication extends ViewRecord
{
    protected static string $resource = ServiceFormApplicationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            // Non-Sacrament Actions
            Actions\Action::make('process')
                ->label('Start Processing')
                ->icon('heroicon-o-play')
                ->color('info')
                ->visible(function (): bool {
                    $record = $this->getRecord();

                    return $record instanceof ServiceFormApplication && ! $record->isSacrament() && $record->status === ServiceFormStatus::Pending;
                })
                ->requiresConfirmation()
                ->action(function (): void {
                    /** @var ServiceFormApplication $record */
                    $record = $this->getRecord();
                    $record->update([
                        'status' => ServiceFormStatus::Processing,
                    ]);
                    Notification::make()
                        ->title('Application Status: Processing')
                        ->info()
                        ->send();
                }),

            Actions\Action::make('approve')
                ->label('Approve Application')
                ->icon('heroicon-o-check-circle')
                ->color('success')
                ->visible(function (): bool {
                    $record = $this->getRecord();

                    return $record instanceof ServiceFormApplication && ! $record->isSacrament() && $record->status === ServiceFormStatus::Processing;
                })
                ->requiresConfirmation()
                ->action(function (): void {
                    /** @var ServiceFormApplication $record */
                    $record = $this->getRecord();
                    $record->update([
                        'status' => ServiceFormStatus::Approved,
                        'reviewed_by' => Auth::id(),
                        'reviewed_at' => now(),
                    ]);
                    Notification::make()
                        ->title('Application Approved Successfully')
                        ->success()
                        ->send();
                }),

            Actions\Action::make('reject')
                ->label('Reject Application')
                ->icon('heroicon-o-x-circle')
                ->color('danger')
                ->visible(function (): bool {
                    $record = $this->getRecord();

                    return $record instanceof ServiceFormApplication && ! $record->isSacrament() && $record->status === ServiceFormStatus::Processing;
                })
                ->form([
                    Forms\Components\Textarea::make('rejection_reason')
                        ->required()
                        ->label('Rejection Reason'),
                ])
                ->action(function (array $data): void {
                    /** @var ServiceFormApplication $record */
                    $record = $this->getRecord();
                    $record->update([
                        'status' => ServiceFormStatus::Rejected,
                        'rejection_reason' => $data['rejection_reason'],
                        'reviewed_by' => Auth::id(),
                        'reviewed_at' => now(),
                    ]);
                    Notification::make()
                        ->title('Application Rejected')
                        ->danger()
                        ->send();
                }),

            // Sacrament Approval Hierarchy Actions
            Actions\Action::make('verify_sector')
                ->label('Verifikasi Sektor')
                ->icon('heroicon-o-shield-check')
                ->color('primary')
                ->requiresConfirmation()
                ->modalHeading('Verifikasi Domisili Sektor')
                ->modalDescription('Apakah Anda yakin data domisili dan keanggotaan jemaat di sektor ini telah valid?')
                ->visible(function (): bool {
                    $record = $this->getRecord();

                    return $record instanceof ServiceFormApplication
                        && $record->isSacrament()
                        && $record->status === ServiceFormStatus::Pending
                        && Auth::user()?->can('verifySector', $record);
                })
                ->action(function (): void {
                    /** @var ServiceFormApplication $record */
                    $record = $this->getRecord();
                    try {
                        app(SacramentWorkflowService::class)->verifySector($record, Auth::user());
                        Notification::make()
                            ->title('Permohonan berhasil diverifikasi oleh Sintua Sektor')
                            ->success()
                            ->send();
                    } catch (\Throwable $e) {
                        Notification::make()
                            ->title('Gagal verifikasi sektor: '.$e->getMessage())
                            ->danger()
                            ->send();
                    }
                }),

            Actions\Action::make('approve_pastoral')
                ->label('Pengesahan Pastoral')
                ->icon('heroicon-o-check-badge')
                ->color('success')
                ->form([
                    Forms\Components\Select::make('scheduled_worship_id')
                        ->label('Jadwal Ibadah Sakramen (Opsional)')
                        ->relationship('scheduledWorship', 'title')
                        ->searchable()
                        ->preload()
                        ->nullable(),
                ])
                ->visible(function (): bool {
                    $record = $this->getRecord();

                    return $record instanceof ServiceFormApplication
                        && $record->isSacrament()
                        && in_array($record->status, [ServiceFormStatus::SectorVerified, ServiceFormStatus::Pending])
                        && Auth::user()?->can('approvePastoral', $record);
                })
                ->action(function (array $data): void {
                    /** @var ServiceFormApplication $record */
                    $record = $this->getRecord();
                    try {
                        app(SacramentWorkflowService::class)->approvePastoral(
                            $record,
                            Auth::user(),
                            $data['scheduled_worship_id'] ?? null
                        );
                        Notification::make()
                            ->title('Permohonan sakramen telah disahkan secara pastoral')
                            ->success()
                            ->send();
                    } catch (\Throwable $e) {
                        Notification::make()
                            ->title('Gagal pengesahan pastoral: '.$e->getMessage())
                            ->danger()
                            ->send();
                    }
                }),

            Actions\Action::make('reject_sacrament')
                ->label('Tolak Sakramen')
                ->icon('heroicon-o-x-circle')
                ->color('danger')
                ->form([
                    Forms\Components\Textarea::make('rejection_reason')
                        ->required()
                        ->label('Alasan Penolakan Sakramen'),
                ])
                ->visible(function (): bool {
                    $record = $this->getRecord();

                    return $record instanceof ServiceFormApplication
                        && $record->isSacrament()
                        && in_array($record->status, [ServiceFormStatus::Pending, ServiceFormStatus::SectorVerified])
                        && Auth::user()?->can('rejectSacrament', $record);
                })
                ->action(function (array $data): void {
                    /** @var ServiceFormApplication $record */
                    $record = $this->getRecord();
                    try {
                        app(SacramentWorkflowService::class)->reject(
                            $record,
                            Auth::user(),
                            $data['rejection_reason']
                        );
                        Notification::make()
                            ->title('Permohonan sakramen ditolak')
                            ->warning()
                            ->send();
                    } catch (\Throwable $e) {
                        Notification::make()
                            ->title('Gagal menolak sakramen: '.$e->getMessage())
                            ->danger()
                            ->send();
                    }
                }),

            Actions\Action::make('complete_sacrament')
                ->label('Selesaikan Sakramen')
                ->icon('heroicon-o-academic-cap')
                ->color('success')
                ->requiresConfirmation()
                ->modalHeading('Konfirmasi Pelaksanaan Sakramen')
                ->modalDescription('Tindakan ini akan menandai sakramen selesai dan memperbarui tanggal sakramen pada profil anggota jemaat.')
                ->visible(function (): bool {
                    $record = $this->getRecord();

                    return $record instanceof ServiceFormApplication
                        && $record->isSacrament()
                        && $record->status === ServiceFormStatus::PastorApproved
                        && Auth::user()?->can('complete', $record);
                })
                ->action(function (): void {
                    /** @var ServiceFormApplication $record */
                    $record = $this->getRecord();
                    try {
                        app(SacramentWorkflowService::class)->complete($record);
                        Notification::make()
                            ->title('Sakramen selesai dan profil jemaat diperbarui')
                            ->success()
                            ->send();
                    } catch (\Throwable $e) {
                        Notification::make()
                            ->title('Gagal menyelesaikan sakramen: '.$e->getMessage())
                            ->danger()
                            ->send();
                    }
                }),

            Actions\EditAction::make(),
        ];
    }
}
