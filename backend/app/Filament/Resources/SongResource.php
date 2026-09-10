<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SongResource\Pages;
use App\Filament\Traits\HasModuleAccess;
use App\Models\Song;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class SongResource extends Resource
{
    use HasModuleAccess;

    public static function getModuleKey(): string
    {
        return 'hymns';
    }

    protected static ?string $model = Song::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-musical-note';

    protected static \UnitEnum|string|null $navigationGroup = 'Sermons & Media';

    protected static ?string $modelLabel = 'Hymn Song';

    protected static ?string $pluralModelLabel = 'Hymn Songs';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\Select::make('songbook_id')
                    ->relationship('songbook', 'name')
                    ->required()
                    ->label('Hymn Songbook'),

                Forms\Components\TextInput::make('number')
                    ->numeric()
                    ->required()
                    ->label('Song Number (No. Lagu)'),

                Forms\Components\TextInput::make('title')
                    ->required()
                    ->maxLength(255)
                    ->label('Song Title'),

                Forms\Components\Textarea::make('lyrics')
                    ->rows(8)
                    ->required()
                    ->columnSpanFull()
                    ->label('Song Lyrics / Verses'),

                Forms\Components\Toggle::make('active')
                    ->default(true)
                    ->required()
                    ->label('Active Status'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('songbook.code')
                    ->searchable()
                    ->sortable()
                    ->label('Buku'),

                Tables\Columns\TextColumn::make('number')
                    ->sortable()
                    ->label('No.'),

                Tables\Columns\TextColumn::make('title')
                    ->searchable()
                    ->sortable()
                    ->label('Judul Lagu'),

                Tables\Columns\IconColumn::make('active')
                    ->boolean()
                    ->label('Status Aktif'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('songbook_id')
                    ->relationship('songbook', 'name')
                    ->label('Filter Songbook'),

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
            'index' => Pages\ListSongs::route('/'),
            'create' => Pages\CreateSong::route('/create'),
            'view' => Pages\ViewSong::route('/{record}'),
            'edit' => Pages\EditSong::route('/{record}/edit'),
        ];
    }
}
