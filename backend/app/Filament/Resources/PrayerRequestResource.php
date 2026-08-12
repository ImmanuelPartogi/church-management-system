<?php

namespace App\Filament\Resources;

use App\Enums\PrayerRequestStatus;
use App\Filament\Resources\PrayerRequestResource\Pages;
use App\Models\PrayerRequest;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;

class PrayerRequestResource extends Resource
{
    protected static ?string $model = PrayerRequest::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-heart';

    protected static \UnitEnum|string|null $navigationGroup = 'Pastoral Care';

    protected static ?string $modelLabel = 'Prayer Request';

    protected static ?string $pluralModelLabel = 'Prayer Requests';

    public static function getEloquentQuery(): Builder
    {
        $query = parent::getEloquentQuery();
        $user = Auth::user();

        if ($user && ! $user->hasPermissionTo('view private prayer requests') && ! $user->hasPermissionTo('manage prayer requests')) {
            $query->where(function (Builder $sub) use ($user) {
                $sub->where('is_private', false)
                    ->orWhere('user_id', $user->id);
            });
        }

        return $query;
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\Select::make('user_id')
                    ->relationship('user', 'name')
                    ->disabled()
                    ->label('Submitted By Account'),

                Forms\Components\Select::make('member_id')
                    ->relationship('member', 'full_name')
                    ->disabled()
                    ->label('Church Member'),

                Forms\Components\TextInput::make('title')
                    ->required()
                    ->maxLength(255)
                    ->label('Prayer Title'),

                Forms\Components\TextInput::make('category')
                    ->nullable()
                    ->maxLength(255)
                    ->label('Category (e.g. Health, Family, Healing)'),

                Forms\Components\Toggle::make('is_private')
                    ->disabled()
                    ->label('Is Private (Pastoral Only)'),

                Forms\Components\Select::make('status')
                    ->options([
                        'submitted' => 'Submitted',
                        'prayed' => 'Prayed',
                        'followed_up' => 'Followed Up',
                    ])
                    ->required()
                    ->label('Pastoral Status'),

                Forms\Components\Textarea::make('content')
                    ->required()
                    ->rows(4)
                    ->columnSpanFull()
                    ->label('Prayer Request Content'),

                Forms\Components\Textarea::make('follow_up_notes')
                    ->rows(3)
                    ->nullable()
                    ->columnSpanFull()
                    ->label('Pastoral Follow-Up Notes'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->searchable()
                    ->sortable()
                    ->label('Judul Pokok Doa'),

                Tables\Columns\TextColumn::make('member.full_name')
                    ->searchable()
                    ->label('Jemaat'),

                Tables\Columns\TextColumn::make('category')
                    ->searchable()
                    ->label('Kategori'),

                Tables\Columns\IconColumn::make('is_private')
                    ->boolean()
                    ->label('Privat'),

                Tables\Columns\BadgeColumn::make('status')
                    ->colors([
                        'warning' => PrayerRequestStatus::Submitted,
                        'info' => PrayerRequestStatus::Prayed,
                        'success' => PrayerRequestStatus::FollowedUp,
                    ])
                    ->label('Status Pastoral'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->label('Tanggal Masuk'),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'submitted' => 'Submitted',
                        'prayed' => 'Prayed',
                        'followed_up' => 'Followed Up',
                    ]),
                Tables\Filters\TernaryFilter::make('is_private')
                    ->label('Privacy Filter'),
            ])
            ->actions([
                Actions\Action::make('markPrayed')
                    ->label('Mark as Prayed')
                    ->icon('heroicon-o-check')
                    ->color('info')
                    ->visible(fn (PrayerRequest $record) => $record->status === PrayerRequestStatus::Submitted)
                    ->action(function (PrayerRequest $record) {
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
                    ->visible(fn (PrayerRequest $record) => $record->status !== PrayerRequestStatus::FollowedUp)
                    ->form([
                        Forms\Components\Textarea::make('follow_up_notes')
                            ->required()
                            ->label('Pastoral Follow-up Notes'),
                    ])
                    ->action(function (PrayerRequest $record, array $data) {
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
            'index' => Pages\ListPrayerRequests::route('/'),
            'view' => Pages\ViewPrayerRequest::route('/{record}'),
            'edit' => Pages\EditPrayerRequest::route('/{record}/edit'),
        ];
    }
}
