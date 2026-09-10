<?php

namespace App\Filament\Resources;

use App\Filament\Resources\WartaResource\Pages;
use App\Filament\Traits\HasModuleAccess;
use App\Models\Warta;
use App\Support\TenantStorage;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class WartaResource extends Resource
{
    use HasModuleAccess;

    public static function getModuleKey(): string
    {
        return 'warta';
    }

    protected static ?string $model = Warta::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-document-text';

    protected static \UnitEnum|string|null $navigationGroup = 'Content Management';

    protected static ?string $modelLabel = 'Digital Warta';

    protected static ?string $pluralModelLabel = 'Digital Warta Archive';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('title')
                    ->required()
                    ->maxLength(255)
                    ->label('Title / Edition'),

                Forms\Components\Textarea::make('description')
                    ->rows(3)
                    ->nullable()
                    ->columnSpanFull()
                    ->label('Description / Summary'),

                Forms\Components\FileUpload::make('file_path')
                    ->required()
                    ->acceptedFileTypes(['application/pdf'])
                    ->maxSize(10240) // 10MB
                    ->directory(fn () => TenantStorage::path('wartas'))
                    ->preserveFilenames()
                    ->columnSpanFull()
                    ->label('Warta PDF Document (PDF only, max 10MB)'),

                Forms\Components\DateTimePicker::make('published_at')
                    ->nullable()
                    ->default(now())
                    ->label('Publish Date & Time'),

                Forms\Components\Toggle::make('is_published')
                    ->default(true)
                    ->required()
                    ->label('Is Published'),

                Forms\Components\TextInput::make('download_count')
                    ->numeric()
                    ->disabled()
                    ->default(0)
                    ->label('Download Count'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->searchable()
                    ->sortable()
                    ->label('Edisi Warta'),

                Tables\Columns\IconColumn::make('is_published')
                    ->boolean()
                    ->label('Published'),

                Tables\Columns\TextColumn::make('published_at')
                    ->dateTime()
                    ->sortable()
                    ->label('Tanggal Terbit'),

                Tables\Columns\TextColumn::make('download_count')
                    ->numeric()
                    ->sortable()
                    ->label('Unduhan'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_published')
                    ->label('Publication Status'),
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
            'index' => Pages\ListWartas::route('/'),
            'create' => Pages\CreateWarta::route('/create'),
            'view' => Pages\ViewWarta::route('/{record}'),
            'edit' => Pages\EditWarta::route('/{record}/edit'),
        ];
    }
}
