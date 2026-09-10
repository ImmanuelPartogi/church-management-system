<?php

namespace App\Filament\Resources;

use App\Enums\DonationStatus;
use App\Enums\FinanceAccountType;
use App\Filament\Resources\DonationConfirmationResource\Pages;
use App\Filament\Traits\HasModuleAccess;
use App\Models\DonationConfirmation;
use App\Models\FinancialTransaction;
use App\Support\TenantStorage;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class DonationConfirmationResource extends Resource
{
    use HasModuleAccess;

    public static function getModuleKey(): string
    {
        return 'donations';
    }

    protected static ?string $model = DonationConfirmation::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-banknotes';

    protected static \UnitEnum|string|null $navigationGroup = 'Finance & Ledger';

    protected static ?string $modelLabel = 'Donation Confirmation';

    protected static ?string $pluralModelLabel = 'Donations Verification';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('donation_number')
                    ->disabled()
                    ->label('Donation Number'),

                Forms\Components\Select::make('user_id')
                    ->relationship('user', 'name')
                    ->disabled()
                    ->label('Donor User Account'),

                Forms\Components\Select::make('member_id')
                    ->relationship('member', 'full_name')
                    ->disabled()
                    ->label('Church Member'),

                Forms\Components\Select::make('chart_of_account_id')
                    ->relationship('chartOfAccount', 'name')
                    ->required()
                    ->label('Donation Category / Chart of Account'),

                Forms\Components\TextInput::make('amount')
                    ->numeric()
                    ->prefix('Rp')
                    ->required()
                    ->label('Donation Amount'),

                Forms\Components\DatePicker::make('transfer_date')
                    ->required()
                    ->label('Transfer Date'),

                Forms\Components\TextInput::make('sender_bank')
                    ->required()
                    ->maxLength(255)
                    ->label('Sender Bank'),

                Forms\Components\TextInput::make('depositor_phone')
                    ->tel()
                    ->required()
                    ->maxLength(255)
                    ->label('Depositor Phone'),

                Forms\Components\FileUpload::make('proof_file_path')
                    ->acceptedFileTypes(['image/jpeg', 'image/png', 'application/pdf'])
                    ->directory(fn () => TenantStorage::path('donation_proofs'))
                    ->maxSize(5120) // 5MB
                    ->columnSpanFull()
                    ->label('Proof of Transfer Receipt'),

                Forms\Components\Select::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'processing' => 'Processing',
                        'approved' => 'Approved',
                        'rejected' => 'Rejected',
                    ])
                    ->required()
                    ->label('Verification Status'),

                Forms\Components\Textarea::make('notes')
                    ->rows(3)
                    ->nullable()
                    ->columnSpanFull()
                    ->label('Donor Notes'),

                Forms\Components\Textarea::make('rejection_reason')
                    ->rows(3)
                    ->nullable()
                    ->columnSpanFull()
                    ->label('Rejection Reason (Required when rejecting)'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('donation_number')
                    ->searchable()
                    ->sortable()
                    ->label('No. Donasi'),

                Tables\Columns\TextColumn::make('member.full_name')
                    ->searchable()
                    ->sortable()
                    ->label('Donatur'),

                Tables\Columns\TextColumn::make('chartOfAccount.name')
                    ->sortable()
                    ->label('Kategori'),

                Tables\Columns\TextColumn::make('amount')
                    ->money('IDR')
                    ->sortable()
                    ->label('Jumlah'),

                Tables\Columns\TextColumn::make('transfer_date')
                    ->date()
                    ->sortable()
                    ->label('Tgl Transfer'),

                Tables\Columns\BadgeColumn::make('status')
                    ->colors([
                        'warning' => DonationStatus::Pending,
                        'info' => DonationStatus::Processing,
                        'success' => DonationStatus::Approved,
                        'danger' => DonationStatus::Rejected,
                    ])
                    ->label('Status Verifikasi'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->label('Tanggal Masuk'),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'processing' => 'Processing',
                        'approved' => 'Approved',
                        'rejected' => 'Rejected',
                    ]),
            ])
            ->actions([
                Actions\Action::make('process')
                    ->label('Process')
                    ->icon('heroicon-o-play')
                    ->color('info')
                    ->visible(fn (DonationConfirmation $record) => $record->status === DonationStatus::Pending)
                    ->requiresConfirmation()
                    ->action(function (DonationConfirmation $record) {
                        $record->update([
                            'status' => DonationStatus::Processing,
                        ]);
                        Notification::make()
                            ->title('Donation Status: Processing')
                            ->info()
                            ->send();
                    }),

                Actions\Action::make('approve')
                    ->label('Approve & Post to Ledger')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn (DonationConfirmation $record) => $record->status === DonationStatus::Processing)
                    ->requiresConfirmation()
                    ->action(function (DonationConfirmation $record) {
                        DB::transaction(function () use ($record) {
                            $record->update([
                                'status' => DonationStatus::Approved,
                                'reviewed_by' => Auth::id(),
                                'reviewed_at' => now(),
                            ]);

                            // Atomic Duplicate Transaction Check
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
                            ->title('Donation Approved & Recorded to Financial Ledger')
                            ->success()
                            ->send();
                    }),

                Actions\Action::make('reject')
                    ->label('Reject')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->visible(fn (DonationConfirmation $record) => $record->status === DonationStatus::Processing)
                    ->form([
                        Forms\Components\Textarea::make('rejection_reason')
                            ->required()
                            ->label('Rejection Reason'),
                    ])
                    ->action(function (DonationConfirmation $record, array $data) {
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

                Actions\ViewAction::make(),
                Actions\EditAction::make(),
            ])
            ->bulkActions([
                Actions\BulkActionGroup::make([
                    Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListDonationConfirmations::route('/'),
            'view' => Pages\ViewDonationConfirmation::route('/{record}'),
            'edit' => Pages\EditDonationConfirmation::route('/{record}/edit'),
        ];
    }
}
