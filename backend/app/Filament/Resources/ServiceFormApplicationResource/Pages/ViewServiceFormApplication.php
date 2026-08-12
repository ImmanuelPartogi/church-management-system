<?php

namespace App\Filament\Resources\ServiceFormApplicationResource\Pages;

use App\Enums\ServiceFormStatus;
use App\Filament\Resources\ServiceFormApplicationResource;
use App\Models\ServiceFormApplication;
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
            Actions\Action::make('process')
                ->label('Start Processing')
                ->icon('heroicon-o-play')
                ->color('info')
                ->visible(function (): bool {
                    $record = $this->getRecord();

                    return $record instanceof ServiceFormApplication && $record->status === ServiceFormStatus::Pending;
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

                    return $record instanceof ServiceFormApplication && $record->status === ServiceFormStatus::Processing;
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

                    return $record instanceof ServiceFormApplication && $record->status === ServiceFormStatus::Processing;
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

            Actions\EditAction::make(),
        ];
    }
}
