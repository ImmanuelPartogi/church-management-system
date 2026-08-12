<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DailyVerseResource\Pages;
use App\Models\DailyVerse;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class DailyVerseResource extends Resource
{
    protected static ?string $model = DailyVerse::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-book-open';

    protected static \UnitEnum|string|null $navigationGroup = 'Content Management';

    protected static ?string $modelLabel = 'Daily Verse';

    protected static ?string $pluralModelLabel = 'Daily Verses';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('verse_reference')
                    ->required()
                    ->maxLength(255)
                    ->label('Verse Reference (e.g. Yohanes 3:16)'),

                Forms\Components\DatePicker::make('date')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->label('Target Date'),

                Forms\Components\Textarea::make('content')
                    ->required()
                    ->rows(4)
                    ->columnSpanFull()
                    ->label('Verse Content / Text'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('date')
                    ->date()
                    ->sortable()
                    ->label('Tanggal'),

                Tables\Columns\TextColumn::make('verse_reference')
                    ->searchable()
                    ->sortable()
                    ->label('Referensi Ayat'),

                Tables\Columns\TextColumn::make('content')
                    ->limit(60)
                    ->searchable()
                    ->label('Isi Ayat'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
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
            'index' => Pages\ListDailyVerses::route('/'),
            'create' => Pages\CreateDailyVerse::route('/create'),
            'view' => Pages\ViewDailyVerse::route('/{record}'),
            'edit' => Pages\EditDailyVerse::route('/{record}/edit'),
        ];
    }
}
