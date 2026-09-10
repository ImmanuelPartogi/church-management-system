<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ServiceFormTypeResource\Pages;
use App\Filament\Traits\HasModuleAccess;
use App\Models\ServiceFormType;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class ServiceFormTypeResource extends Resource
{
    use HasModuleAccess;

    public static function getModuleKey(): string
    {
        return 'forms';
    }

    protected static ?string $model = ServiceFormType::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-rectangle-stack';

    protected static \UnitEnum|string|null $navigationGroup = 'Service Forms';

    protected static ?string $modelLabel = 'Service Form Type';

    protected static ?string $pluralModelLabel = 'Service Form Types';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->required()
                    ->maxLength(255)
                    ->label('Form Name'),

                Forms\Components\TextInput::make('slug')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->maxLength(255)
                    ->label('Slug Identifier'),

                Forms\Components\Textarea::make('description')
                    ->rows(3)
                    ->nullable()
                    ->columnSpanFull()
                    ->label('Description & Requirements'),

                Forms\Components\TextInput::make('fee_amount')
                    ->numeric()
                    ->minValue(0)
                    ->default(0)
                    ->prefix('Rp')
                    ->required()
                    ->label('Administrative Fee (Rp)'),

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
                    ->label('Nama Layanan'),

                Tables\Columns\TextColumn::make('slug')
                    ->searchable()
                    ->label('Slug'),

                Tables\Columns\TextColumn::make('fee_amount')
                    ->money('IDR')
                    ->sortable()
                    ->label('Biaya Admin'),

                Tables\Columns\IconColumn::make('active')
                    ->boolean()
                    ->label('Aktif'),

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
            'index' => Pages\ListServiceFormTypes::route('/'),
            'create' => Pages\CreateServiceFormType::route('/create'),
            'view' => Pages\ViewServiceFormType::route('/{record}'),
            'edit' => Pages\EditServiceFormType::route('/{record}/edit'),
        ];
    }
}
