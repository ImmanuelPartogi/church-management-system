<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SectorResource\Pages;
use App\Models\Sector;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class SectorResource extends Resource
{
    protected static ?string $model = Sector::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-map-pin';

    protected static \UnitEnum|string|null $navigationGroup = 'Community & Ministry';

    protected static ?string $modelLabel = 'Sector / Wijk';

    protected static ?string $pluralModelLabel = 'Sectors / Wijk';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\Select::make('resort_id')
                    ->relationship('resort', 'name')
                    ->nullable()
                    ->label('Resort / Pagaran'),

                Forms\Components\TextInput::make('name')
                    ->required()
                    ->maxLength(255)
                    ->label('Sector Name (e.g. Sektor I, Wijk II)'),

                Forms\Components\TextInput::make('code')
                    ->nullable()
                    ->maxLength(255)
                    ->label('Sector Code'),

                Forms\Components\Textarea::make('description')
                    ->rows(3)
                    ->nullable()
                    ->columnSpanFull()
                    ->label('Description'),

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
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable()
                    ->label('Nama Sektor'),

                Tables\Columns\TextColumn::make('code')
                    ->searchable()
                    ->sortable()
                    ->label('Kode'),

                Tables\Columns\TextColumn::make('resort.name')
                    ->searchable()
                    ->sortable()
                    ->label('Resort'),

                Tables\Columns\TextColumn::make('servants_count')
                    ->counts('servants')
                    ->label('Jumlah Pelayan'),

                Tables\Columns\IconColumn::make('active')
                    ->boolean()
                    ->label('Status Aktif'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('resort_id')
                    ->relationship('resort', 'name')
                    ->label('Filter Resort'),

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
            'index' => Pages\ListSectors::route('/'),
            'create' => Pages\CreateSector::route('/create'),
            'view' => Pages\ViewSector::route('/{record}'),
            'edit' => Pages\EditSector::route('/{record}/edit'),
        ];
    }
}
