<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ChurchResource\Pages;
use App\Filament\Resources\ChurchResource\RelationManagers;
use App\Models\Church;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;

class ChurchResource extends Resource
{
    protected static ?string $model = Church::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-building-library';

    protected static \UnitEnum|string|null $navigationGroup = 'Pengaturan Gereja';

    protected static ?string $modelLabel = 'Gereja / Tenant';

    protected static ?string $pluralModelLabel = 'Daftar Gereja / Tenant';

    /**
     * Strict Authorization: Only Super Admins can view and access the tenant registry.
     */
    public static function canViewAny(): bool
    {
        return (bool) auth()->user()?->is_super_admin;
    }

    /**
     * Permanent safety constraint: UI deletion is completely forbidden.
     * Prevents accidental trigger of foreign key cascades across 11 operational tables.
     */
    public static function canDelete(Model $record): bool
    {
        return false;
    }

    public static function canDeleteAny(): bool
    {
        return false;
    }

    public static function canForceDelete(Model $record): bool
    {
        return false;
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->required()
                    ->maxLength(255)
                    ->label('Nama Gereja'),

                Forms\Components\TextInput::make('slug')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->maxLength(255)
                    ->label('Slug URL / Identifier')
                    ->disabled(fn (string $operation): bool => $operation === 'edit')
                    ->helperText('Slug bersifat permanen setelah dibuat dan digunakan sebagai identifier routing / mobile client.'),

                Forms\Components\Select::make('status')
                    ->options([
                        'active' => 'Active',
                        'suspended' => 'Suspended',
                    ])
                    ->default('active')
                    ->required()
                    ->label('Status Operasional')
                    ->helperText('Status Suspended akan memblokir akses ke tenant tanpa menghapus data.'),

                Forms\Components\Select::make('timezone')
                    ->options([
                        'Asia/Jakarta' => 'WIB (Asia/Jakarta)',
                        'Asia/Makassar' => 'WITA (Asia/Makassar)',
                        'Asia/Jayapura' => 'WIT (Asia/Jayapura)',
                    ])
                    ->default('Asia/Jakarta')
                    ->required()
                    ->label('Zona Waktu'),

                Forms\Components\TextInput::make('phone')
                    ->tel()
                    ->nullable()
                    ->maxLength(50)
                    ->label('Nomor Telepon'),

                Forms\Components\Textarea::make('address')
                    ->rows(3)
                    ->nullable()
                    ->columnSpanFull()
                    ->label('Alamat Lengkap'),

                Forms\Components\FileUpload::make('logo_path')
                    ->image()
                    ->directory('church-logos')
                    ->nullable()
                    ->label('Logo Gereja'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable()
                    ->label('Nama Gereja'),

                Tables\Columns\TextColumn::make('slug')
                    ->badge()
                    ->color('gray')
                    ->searchable()
                    ->label('Slug Identifier'),

                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->colors([
                        'success' => 'active',
                        'danger' => 'suspended',
                    ])
                    ->label('Status'),

                Tables\Columns\TextColumn::make('timezone')
                    ->label('Zona Waktu'),

                Tables\Columns\TextColumn::make('phone')
                    ->label('Telepon')
                    ->default('-'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true)
                    ->label('Dibuat Pada'),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'active' => 'Active',
                        'suspended' => 'Suspended',
                    ])
                    ->label('Filter Status'),
            ])
            ->actions([
                Actions\Action::make('toggleStatus')
                    ->label(fn (Church $record) => $record->status === 'active' ? 'Tangguhkan' : 'Aktifkan')
                    ->icon(fn (Church $record) => $record->status === 'active' ? 'heroicon-o-no-symbol' : 'heroicon-o-check-circle')
                    ->color(fn (Church $record) => $record->status === 'active' ? 'danger' : 'success')
                    ->requiresConfirmation()
                    ->modalHeading(fn (Church $record) => $record->status === 'active' ? 'Tangguhkan Gereja Tenant' : 'Aktifkan Gereja Tenant')
                    ->modalDescription(fn (Church $record) => $record->status === 'active'
                        ? 'Menangguhkan gereja ini akan memblokir akses seluruh pengurus dan jemaat ke tenant ini (HTTP 403) tanpa menghapus data apa pun.'
                        : 'Mengaktifkan kembali gereja ini akan memulihkan akses pengurus dan jemaat.')
                    ->action(function (Church $record) {
                        $newStatus = $record->status === 'active' ? 'suspended' : 'active';
                        $record->update(['status' => $newStatus]);
                        Notification::make()
                            ->title("Status gereja {$record->name} diubah menjadi {$newStatus}.")
                            ->success()
                            ->send();
                    }),

                Actions\EditAction::make(),
            ])
            ->bulkActions([
                // Permanently empty: No bulk deletion allowed
            ]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\ChurchModulesRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListChurches::route('/'),
            'create' => Pages\CreateChurch::route('/create'),
            'edit' => Pages\EditChurch::route('/{record}/edit'),
        ];
    }
}
