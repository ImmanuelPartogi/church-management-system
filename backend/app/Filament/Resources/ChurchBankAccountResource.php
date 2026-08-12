<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ChurchBankAccountResource\Pages;
use App\Models\ChurchBankAccount;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class ChurchBankAccountResource extends Resource
{
    protected static ?string $model = ChurchBankAccount::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-building-library';

    protected static \UnitEnum|string|null $navigationGroup = 'Finance & Ledger';

    protected static ?string $modelLabel = 'Church Bank Account';

    protected static ?string $pluralModelLabel = 'Bank Accounts';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('bank_name')
                    ->required()
                    ->maxLength(255)
                    ->label('Bank Name (e.g. Bank Mandiri, BCA)'),

                Forms\Components\TextInput::make('account_number')
                    ->required()
                    ->maxLength(255)
                    ->label('Account Number'),

                Forms\Components\TextInput::make('account_holder_name')
                    ->required()
                    ->maxLength(255)
                    ->label('Account Holder Name'),

                Forms\Components\TextInput::make('display_order')
                    ->numeric()
                    ->default(0)
                    ->required()
                    ->label('Display Order'),

                Forms\Components\Toggle::make('is_active')
                    ->default(true)
                    ->required()
                    ->label('Active Status'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('bank_name')
                    ->searchable()
                    ->sortable()
                    ->label('Nama Bank'),

                Tables\Columns\TextColumn::make('account_number')
                    ->searchable()
                    ->sortable()
                    ->label('No. Rekening'),

                Tables\Columns\TextColumn::make('account_holder_name')
                    ->searchable()
                    ->label('Atas Nama'),

                Tables\Columns\TextColumn::make('display_order')
                    ->sortable()
                    ->label('Urutan'),

                Tables\Columns\IconColumn::make('is_active')
                    ->boolean()
                    ->label('Status Aktif'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
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
            'index' => Pages\ListChurchBankAccounts::route('/'),
            'create' => Pages\CreateChurchBankAccount::route('/create'),
            'view' => Pages\ViewChurchBankAccount::route('/{record}'),
            'edit' => Pages\EditChurchBankAccount::route('/{record}/edit'),
        ];
    }
}
