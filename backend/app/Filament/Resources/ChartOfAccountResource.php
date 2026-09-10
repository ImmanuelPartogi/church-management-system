<?php

namespace App\Filament\Resources;

use App\Enums\FinanceAccountType;
use App\Filament\Resources\ChartOfAccountResource\Pages;
use App\Filament\Traits\HasModuleAccess;
use App\Models\ChartOfAccount;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class ChartOfAccountResource extends Resource
{
    use HasModuleAccess;

    public static function getModuleKey(): string
    {
        return 'finance';
    }

    protected static ?string $model = ChartOfAccount::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-bars-3-center-left';

    protected static \UnitEnum|string|null $navigationGroup = 'Finance & Ledger';

    protected static ?string $modelLabel = 'Chart of Account';

    protected static ?string $pluralModelLabel = 'Chart of Accounts';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('code')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->maxLength(255)
                    ->label('Account Code (e.g. 401, 502)'),

                Forms\Components\TextInput::make('name')
                    ->required()
                    ->maxLength(255)
                    ->label('Account Name'),

                Forms\Components\Select::make('type')
                    ->options([
                        'income' => 'Income (Pemasukan)',
                        'expense' => 'Expense (Pengeluaran)',
                    ])
                    ->required()
                    ->label('Account Type'),

                Forms\Components\Select::make('parent_id')
                    ->relationship('parent', 'name')
                    ->nullable()
                    ->label('Parent Account'),

                Forms\Components\Textarea::make('description')
                    ->rows(3)
                    ->nullable()
                    ->columnSpanFull()
                    ->label('Description'),

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
                Tables\Columns\TextColumn::make('code')
                    ->searchable()
                    ->sortable()
                    ->label('Kode Akun'),

                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable()
                    ->label('Nama Akun'),

                Tables\Columns\BadgeColumn::make('type')
                    ->colors([
                        'success' => FinanceAccountType::Income,
                        'danger' => FinanceAccountType::Expense,
                    ])
                    ->label('Tipe Akun'),

                Tables\Columns\TextColumn::make('parent.name')
                    ->searchable()
                    ->label('Akun Induk'),

                Tables\Columns\IconColumn::make('is_active')
                    ->boolean()
                    ->label('Aktif'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->options([
                        'income' => 'Income',
                        'expense' => 'Expense',
                    ]),
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
            'index' => Pages\ListChartOfAccounts::route('/'),
            'create' => Pages\CreateChartOfAccount::route('/create'),
            'view' => Pages\ViewChartOfAccount::route('/{record}'),
            'edit' => Pages\EditChartOfAccount::route('/{record}/edit'),
        ];
    }
}
