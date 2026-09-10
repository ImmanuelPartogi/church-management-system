<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ResortResource\Pages;
use App\Filament\Traits\HasModuleAccess;
use App\Models\Resort;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class ResortResource extends Resource
{
    use HasModuleAccess;

    public static function getModuleKey(): string
    {
        return 'community';
    }

    protected static ?string $model = Resort::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-home-modern';

    protected static \UnitEnum|string|null $navigationGroup = 'Community & Ministry';

    protected static ?string $modelLabel = 'Resort / Pagaran';

    protected static ?string $pluralModelLabel = 'Resorts / Pagaran';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->maxLength(255)
                    ->label('Resort Name'),

                Forms\Components\TextInput::make('code')
                    ->nullable()
                    ->unique(ignoreRecord: true)
                    ->maxLength(255)
                    ->label('Resort Code'),

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
                    ->label('Nama Resort'),

                Tables\Columns\TextColumn::make('code')
                    ->searchable()
                    ->sortable()
                    ->label('Kode'),

                Tables\Columns\TextColumn::make('sectors_count')
                    ->counts('sectors')
                    ->label('Jumlah Sektor'),

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
            'index' => Pages\ListResorts::route('/'),
            'create' => Pages\CreateResort::route('/create'),
            'view' => Pages\ViewResort::route('/{record}'),
            'edit' => Pages\EditResort::route('/{record}/edit'),
        ];
    }
}
