<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SermonResource\Pages;
use App\Models\Sermon;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class SermonResource extends Resource
{
    protected static ?string $model = Sermon::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-microphone';

    protected static \UnitEnum|string|null $navigationGroup = 'Sermons & Media';

    protected static ?string $modelLabel = 'Sermon Archive';

    protected static ?string $pluralModelLabel = 'Sermon Archives';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('title')
                    ->required()
                    ->maxLength(255)
                    ->label('Sermon Title'),

                Forms\Components\TextInput::make('preacher_name')
                    ->nullable()
                    ->maxLength(255)
                    ->label('Preacher Name (Pengkhotbah)'),

                Forms\Components\Select::make('servant_id')
                    ->relationship('servant', 'name')
                    ->searchable()
                    ->nullable()
                    ->label('Church Servant (If member pelayan)'),

                Forms\Components\FileUpload::make('file_path')
                    ->acceptedFileTypes(['audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/m4a', 'audio/aac', 'application/pdf'])
                    ->directory('sermons')
                    ->maxSize(51200) // Max 50MB
                    ->required()
                    ->columnSpanFull()
                    ->label('Sermon Audio / Recording File (MP3, WAV, M4A, AAC, or PDF)'),

                Forms\Components\DateTimePicker::make('published_at')
                    ->default(now())
                    ->nullable()
                    ->label('Published Datetime'),

                Forms\Components\Toggle::make('is_published')
                    ->default(true)
                    ->required()
                    ->label('Published Status'),

                Forms\Components\TextInput::make('download_count')
                    ->numeric()
                    ->default(0)
                    ->disabled()
                    ->label('Download Counter'),

                Forms\Components\Textarea::make('description')
                    ->rows(4)
                    ->nullable()
                    ->columnSpanFull()
                    ->label('Sermon Summary / Scripture References'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->searchable()
                    ->sortable()
                    ->label('Judul Khotbah'),

                Tables\Columns\TextColumn::make('preacher_name')
                    ->searchable()
                    ->sortable()
                    ->label('Pengkhotbah'),

                Tables\Columns\TextColumn::make('published_at')
                    ->dateTime()
                    ->sortable()
                    ->label('Tanggal Khotbah'),

                Tables\Columns\IconColumn::make('is_published')
                    ->boolean()
                    ->label('Dipublikasi'),

                Tables\Columns\TextColumn::make('download_count')
                    ->sortable()
                    ->label('Jumlah Unduhan'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_published')
                    ->label('Published Status'),
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
            'index' => Pages\ListSermons::route('/'),
            'create' => Pages\CreateSermon::route('/create'),
            'view' => Pages\ViewSermon::route('/{record}'),
            'edit' => Pages\EditSermon::route('/{record}/edit'),
        ];
    }
}
