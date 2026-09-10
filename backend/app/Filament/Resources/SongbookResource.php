<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SongbookResource\Pages;
use App\Filament\Traits\HasModuleAccess;
use App\Models\Songbook;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class SongbookResource extends Resource
{
    use HasModuleAccess;

    public static function getModuleKey(): string
    {
        return 'hymns';
    }

    protected static ?string $model = Songbook::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-book-open';

    protected static \UnitEnum|string|null $navigationGroup = 'Sermons & Media';

    protected static ?string $modelLabel = 'Hymn Songbook';

    protected static ?string $pluralModelLabel = 'Hymn Songbooks';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->required()
                    ->maxLength(255)
                    ->label('Songbook Name (e.g. Buku Ende, BE, Kidung Jemaat)'),

                Forms\Components\TextInput::make('code')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->maxLength(255)
                    ->label('Songbook Code (e.g. BE, BN, KJ)'),

                Forms\Components\Textarea::make('description')
                    ->rows(3)
                    ->nullable()
                    ->columnSpanFull()
                    ->label('Description & Copyright Status Notes'),

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
                Tables\Columns\TextColumn::make('code')
                    ->searchable()
                    ->sortable()
                    ->label('Kode Buku'),

                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable()
                    ->label('Nama Buku Lagu'),

                Tables\Columns\TextColumn::make('songs_count')
                    ->counts('songs')
                    ->label('Jumlah Lagu'),

                Tables\Columns\IconColumn::make('active')
                    ->boolean()
                    ->label('Status Aktif'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
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
            'index' => Pages\ListSongbooks::route('/'),
            'create' => Pages\CreateSongbook::route('/create'),
            'view' => Pages\ViewSongbook::route('/{record}'),
            'edit' => Pages\EditSongbook::route('/{record}/edit'),
        ];
    }
}
