<?php

namespace App\Filament\Resources\PrayerRequestResource\Pages;

use App\Enums\PrayerRequestStatus;
use App\Filament\Resources\PrayerRequestResource;
use App\Models\PrayerRequest;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ViewRecord;
use Illuminate\Support\Facades\Auth;

class ViewPrayerRequest extends ViewRecord
{
    protected static string $resource = PrayerRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('markPrayed')
                ->label('Mark as Prayed')
                ->icon('heroicon-o-check')
                ->color('info')
                ->visible(function (): bool {
                    $record = $this->getRecord();

                    return $record instanceof PrayerRequest && $record->status === PrayerRequestStatus::Submitted;
                })
                ->action(function (): void {
                    /** @var PrayerRequest $record */
                    $record = $this->getRecord();
                    $record->update([
                        'status' => PrayerRequestStatus::Prayed,
                    ]);
                    Notification::make()
                        ->title('Prayer request marked as Prayed')
                        ->info()
                        ->send();
                }),

            Actions\Action::make('markFollowedUp')
                ->label('Follow Up')
                ->icon('heroicon-o-check-circle')
                ->color('success')
                ->visible(function (): bool {
                    $record = $this->getRecord();

                    return $record instanceof PrayerRequest && $record->status !== PrayerRequestStatus::FollowedUp;
                })
                ->form([
                    Forms\Components\Textarea::make('follow_up_notes')
                        ->required()
                        ->label('Pastoral Follow-up Notes'),
                ])
                ->action(function (array $data): void {
                    /** @var PrayerRequest $record */
                    $record = $this->getRecord();
                    $record->update([
                        'status' => PrayerRequestStatus::FollowedUp,
                        'follow_up_notes' => $data['follow_up_notes'],
                        'followed_up_by' => Auth::id(),
                        'followed_up_at' => now(),
                    ]);
                    Notification::make()
                        ->title('Prayer request followed up successfully')
                        ->success()
                        ->send();
                }),

            Actions\EditAction::make(),
        ];
    }
}
