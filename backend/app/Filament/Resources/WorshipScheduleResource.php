<?php

namespace App\Filament\Resources;

use App\Filament\Resources\WorshipScheduleResource\Pages;
use App\Filament\Traits\HasModuleAccess;
use App\Models\WorshipSchedule;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class WorshipScheduleResource extends Resource
{
    use HasModuleAccess;

    public static function getModuleKey(): string
    {
        return 'schedules';
    }

    protected static ?string $model = WorshipSchedule::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-calendar';

    protected static \UnitEnum|string|null $navigationGroup = 'Worship & Events';

    protected static ?string $modelLabel = 'Worship Schedule';

    protected static ?string $pluralModelLabel = 'Worship Schedules';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('title')
                    ->required()
                    ->maxLength(255)
                    ->label('Title'),

                Forms\Components\Textarea::make('description')
                    ->required()
                    ->rows(3)
                    ->columnSpanFull()
                    ->label('Description'),

                Forms\Components\Select::make('day')
                    ->options([
                        'Sunday' => 'Sunday',
                        'Monday' => 'Monday',
                        'Tuesday' => 'Tuesday',
                        'Wednesday' => 'Wednesday',
                        'Thursday' => 'Thursday',
                        'Friday' => 'Friday',
                        'Saturday' => 'Saturday',
                    ])
                    ->required()
                    ->label('Day of Week'),

                Forms\Components\TimePicker::make('start_time')
                    ->required()
                    ->label('Start Time'),

                Forms\Components\TimePicker::make('end_time')
                    ->required()
                    ->label('End Time'),

                Forms\Components\TextInput::make('location')
                    ->required()
                    ->maxLength(255)
                    ->label('Location'),

                Forms\Components\Toggle::make('active')
                    ->default(true)
                    ->required()
                    ->label('Is Active'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->searchable()
                    ->sortable()
                    ->label('Judul Ibadah'),

                Tables\Columns\TextColumn::make('day')
                    ->sortable()
                    ->label('Hari'),

                Tables\Columns\TextColumn::make('start_time')
                    ->time('H:i')
                    ->sortable()
                    ->label('Jam Mulai'),

                Tables\Columns\TextColumn::make('end_time')
                    ->time('H:i')
                    ->sortable()
                    ->label('Jam Selesai'),

                Tables\Columns\TextColumn::make('location')
                    ->searchable()
                    ->label('Lokasi'),

                Tables\Columns\IconColumn::make('active')
                    ->boolean()
                    ->label('Status Active'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('day')
                    ->options([
                        'Sunday' => 'Sunday',
                        'Saturday' => 'Saturday',
                    ]),
                Tables\Filters\TernaryFilter::make('active')
                    ->label('Active Status'),
            ])
            ->actions([
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
            'index' => Pages\ListWorshipSchedules::route('/'),
            'create' => Pages\CreateWorshipSchedule::route('/create'),
            'view' => Pages\ViewWorshipSchedule::route('/{record}'),
            'edit' => Pages\EditWorshipSchedule::route('/{record}/edit'),
        ];
    }
}
