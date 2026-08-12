<?php

namespace App\Filament\Resources;

use App\Filament\Resources\FellowshipResource\Pages;
use App\Models\Fellowship;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class FellowshipResource extends Resource
{
    protected static ?string $model = Fellowship::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-user-group';

    protected static \UnitEnum|string|null $navigationGroup = 'Community & Ministry';

    protected static ?string $modelLabel = 'Fellowship / Punguan Kategori';

    protected static ?string $pluralModelLabel = 'Fellowships / Punguan';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->maxLength(255)
                    ->label('Fellowship Name (e.g. Ama, Ina, Remaja, Naposobulung)'),

                Forms\Components\TextInput::make('code')
                    ->nullable()
                    ->unique(ignoreRecord: true)
                    ->maxLength(255)
                    ->label('Fellowship Code'),

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
                    ->label('Nama Kategori'),

                Tables\Columns\TextColumn::make('code')
                    ->searchable()
                    ->sortable()
                    ->label('Kode'),

                Tables\Columns\TextColumn::make('members_count')
                    ->counts('members')
                    ->label('Jumlah Jemaat'),

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
            'index' => Pages\ListFellowships::route('/'),
            'create' => Pages\CreateFellowship::route('/create'),
            'view' => Pages\ViewFellowship::route('/{record}'),
            'edit' => Pages\EditFellowship::route('/{record}/edit'),
        ];
    }
}
