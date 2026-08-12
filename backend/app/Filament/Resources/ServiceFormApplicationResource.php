<?php

namespace App\Filament\Resources;

use App\Enums\PaymentStatus;
use App\Enums\ServiceFormStatus;
use App\Filament\Resources\ServiceFormApplicationResource\Pages;
use App\Models\ServiceFormApplication;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Auth;

class ServiceFormApplicationResource extends Resource
{
    protected static ?string $model = ServiceFormApplication::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-clipboard-document-check';

    protected static \UnitEnum|string|null $navigationGroup = 'Service Forms';

    protected static ?string $modelLabel = 'Service Form Application';

    protected static ?string $pluralModelLabel = 'Form Applications';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('application_number')
                    ->disabled()
                    ->label('Application Number'),

                Forms\Components\Select::make('user_id')
                    ->relationship('user', 'name')
                    ->disabled()
                    ->label('Applicant Account'),

                Forms\Components\Select::make('member_id')
                    ->relationship('member', 'full_name')
                    ->disabled()
                    ->label('Church Member'),

                Forms\Components\Select::make('service_form_type_id')
                    ->relationship('serviceFormType', 'name')
                    ->disabled()
                    ->label('Form Type'),

                Forms\Components\Select::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'processing' => 'Processing',
                        'approved' => 'Approved',
                        'rejected' => 'Rejected',
                    ])
                    ->required()
                    ->label('Status'),

                Forms\Components\Select::make('payment_status')
                    ->options([
                        'unpaid' => 'Unpaid',
                        'paid' => 'Paid',
                    ])
                    ->required()
                    ->label('Payment Status'),

                Forms\Components\Textarea::make('applicant_notes')
                    ->rows(3)
                    ->disabled()
                    ->columnSpanFull()
                    ->label('Applicant Notes'),

                Forms\Components\Textarea::make('rejection_reason')
                    ->rows(3)
                    ->nullable()
                    ->columnSpanFull()
                    ->label('Rejection Reason (Required when rejecting)'),

                Forms\Components\Textarea::make('payment_notes')
                    ->rows(2)
                    ->nullable()
                    ->columnSpanFull()
                    ->label('Payment Notes'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('application_number')
                    ->searchable()
                    ->sortable()
                    ->label('No. Pengajuan'),

                Tables\Columns\TextColumn::make('member.full_name')
                    ->searchable()
                    ->sortable()
                    ->label('Pemohon'),

                Tables\Columns\TextColumn::make('serviceFormType.name')
                    ->sortable()
                    ->label('Jenis Layanan'),

                Tables\Columns\BadgeColumn::make('status')
                    ->colors([
                        'warning' => ServiceFormStatus::Pending,
                        'info' => ServiceFormStatus::Processing,
                        'success' => ServiceFormStatus::Approved,
                        'danger' => ServiceFormStatus::Rejected,
                    ])
                    ->label('Status Workflow'),

                Tables\Columns\BadgeColumn::make('payment_status')
                    ->colors([
                        'danger' => PaymentStatus::Unpaid,
                        'success' => PaymentStatus::Paid,
                    ])
                    ->label('Status Bayar'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->label('Tanggal Pengajuan'),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'processing' => 'Processing',
                        'approved' => 'Approved',
                        'rejected' => 'Rejected',
                    ]),
                Tables\Filters\SelectFilter::make('payment_status')
                    ->options([
                        'unpaid' => 'Unpaid',
                        'paid' => 'Paid',
                    ]),
            ])
            ->actions([
                Actions\Action::make('process')
                    ->label('Process')
                    ->icon('heroicon-o-play')
                    ->color('info')
                    ->visible(fn (ServiceFormApplication $record) => $record->status === ServiceFormStatus::Pending)
                    ->requiresConfirmation()
                    ->action(function (ServiceFormApplication $record) {
                        $record->update([
                            'status' => ServiceFormStatus::Processing,
                        ]);
                        Notification::make()
                            ->title('Application marked as Processing')
                            ->success()
                            ->send();
                    }),

                Actions\Action::make('approve')
                    ->label('Approve')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn (ServiceFormApplication $record) => $record->status === ServiceFormStatus::Processing)
                    ->requiresConfirmation()
                    ->action(function (ServiceFormApplication $record) {
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
                    ->label('Reject')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->visible(fn (ServiceFormApplication $record) => $record->status === ServiceFormStatus::Processing)
                    ->form([
                        Forms\Components\Textarea::make('rejection_reason')
                            ->required()
                            ->label('Rejection Reason'),
                    ])
                    ->action(function (ServiceFormApplication $record, array $data) {
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
            'index' => Pages\ListServiceFormApplications::route('/'),
            'view' => Pages\ViewServiceFormApplication::route('/{record}'),
            'edit' => Pages\EditServiceFormApplication::route('/{record}/edit'),
        ];
    }
}
