<?php

namespace App\Filament\Resources\DonationConfirmationResource\Pages;

use App\Enums\DonationStatus;
use App\Enums\FinanceAccountType;
use App\Filament\Resources\DonationConfirmationResource;
use App\Models\DonationConfirmation;
use App\Models\FinancialTransaction;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ViewRecord;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class ViewDonationConfirmation extends ViewRecord
{
    protected static string $resource = DonationConfirmationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('process')
                ->label('Start Verification')
                ->icon('heroicon-o-play')
                ->color('info')
                ->visible(function (): bool {
                    $record = $this->getRecord();

                    return $record instanceof DonationConfirmation && $record->status === DonationStatus::Pending;
                })
                ->requiresConfirmation()
                ->action(function (): void {
                    /** @var DonationConfirmation $record */
                    $record = $this->getRecord();
                    $record->update([
                        'status' => DonationStatus::Processing,
                    ]);
                    Notification::make()
                        ->title('Donation Verification: Processing')
                        ->info()
                        ->send();
                }),

            Actions\Action::make('approve')
                ->label('Approve & Post to Ledger')
                ->icon('heroicon-o-check-circle')
                ->color('success')
                ->visible(function (): bool {
                    $record = $this->getRecord();

                    return $record instanceof DonationConfirmation && $record->status === DonationStatus::Processing;
                })
                ->requiresConfirmation()
                ->action(function (): void {
                    /** @var DonationConfirmation $record */
                    $record = $this->getRecord();

                    DB::transaction(function () use ($record) {
                        $record->update([
                            'status' => DonationStatus::Approved,
                            'reviewed_by' => Auth::id(),
                            'reviewed_at' => now(),
                        ]);

                        $exists = FinancialTransaction::where('donation_confirmation_id', $record->id)->exists();

                        if (! $exists) {
                            FinancialTransaction::create([
                                'transaction_number' => 'TRX-DON-'.strtoupper(Str::random(8)),
                                'transaction_date' => $record->transfer_date,
                                'chart_of_account_id' => $record->chart_of_account_id,
                                'type' => FinanceAccountType::Income,
                                'amount' => $record->amount,
                                'description' => 'Donasi Terverifikasi: '.($record->notes ?? 'Donasi Manual'),
                                'reference' => $record->donation_number,
                                'donation_confirmation_id' => $record->id,
                                'created_by' => Auth::id(),
                            ]);
                        }
                    });

                    Notification::make()
                        ->title('Donation Approved & Posted to Ledger')
                        ->success()
                        ->send();
                }),

            Actions\Action::make('reject')
                ->label('Reject Donation')
                ->icon('heroicon-o-x-circle')
                ->color('danger')
                ->visible(function (): bool {
                    $record = $this->getRecord();

                    return $record instanceof DonationConfirmation && $record->status === DonationStatus::Processing;
                })
                ->form([
                    Forms\Components\Textarea::make('rejection_reason')
                        ->required()
                        ->label('Rejection Reason'),
                ])
                ->action(function (array $data): void {
                    /** @var DonationConfirmation $record */
                    $record = $this->getRecord();
                    $record->update([
                        'status' => DonationStatus::Rejected,
                        'rejection_reason' => $data['rejection_reason'],
                        'reviewed_by' => Auth::id(),
                        'reviewed_at' => now(),
                    ]);
                    Notification::make()
                        ->title('Donation Rejected')
                        ->danger()
                        ->send();
                }),

            Actions\EditAction::make(),
        ];
    }
}
