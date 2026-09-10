<?php

namespace App\Filament\Resources;

use App\Enums\FinanceAccountType;
use App\Filament\Resources\FinancialTransactionResource\Pages;
use App\Filament\Traits\HasModuleAccess;
use App\Models\FinancialTransaction;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Auth;

class FinancialTransactionResource extends Resource
{
    use HasModuleAccess;

    public static function getModuleKey(): string
    {
        return 'finance';
    }

    protected static ?string $model = FinancialTransaction::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-calculator';

    protected static \UnitEnum|string|null $navigationGroup = 'Finance & Ledger';

    protected static ?string $modelLabel = 'Financial Ledger Entry';

    protected static ?string $pluralModelLabel = 'Financial Ledger';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('transaction_number')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->maxLength(255)
                    ->label('Transaction Reference No.'),

                Forms\Components\DatePicker::make('transaction_date')
                    ->required()
                    ->default(now())
                    ->label('Transaction Date'),

                Forms\Components\Select::make('chart_of_account_id')
                    ->relationship('chartOfAccount', 'name')
                    ->required()
                    ->label('Chart of Account Category'),

                Forms\Components\Select::make('type')
                    ->options([
                        'income' => 'Income (Pemasukan)',
                        'expense' => 'Expense (Pengeluaran)',
                    ])
                    ->required()
                    ->label('Transaction Type'),

                Forms\Components\TextInput::make('amount')
                    ->numeric()
                    ->minValue(0)
                    ->prefix('Rp')
                    ->required()
                    ->label('Amount (Rp)'),

                Forms\Components\TextInput::make('reference')
                    ->nullable()
                    ->maxLength(255)
                    ->label('External Reference / Receipt No.'),

                Forms\Components\Textarea::make('description')
                    ->required()
                    ->rows(3)
                    ->columnSpanFull()
                    ->label('Transaction Description / Notes'),

                Forms\Components\Hidden::make('created_by')
                    ->default(fn () => Auth::id()),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('transaction_number')
                    ->searchable()
                    ->sortable()
                    ->label('No. Transaksi'),

                Tables\Columns\TextColumn::make('transaction_date')
                    ->date()
                    ->sortable()
                    ->label('Tanggal'),

                Tables\Columns\TextColumn::make('chartOfAccount.name')
                    ->searchable()
                    ->sortable()
                    ->label('Kategori Akun'),

                Tables\Columns\BadgeColumn::make('type')
                    ->colors([
                        'success' => FinanceAccountType::Income,
                        'danger' => FinanceAccountType::Expense,
                    ])
                    ->label('Tipe Transaksi'),

                Tables\Columns\TextColumn::make('amount')
                    ->money('IDR')
                    ->sortable()
                    ->label('Jumlah'),

                Tables\Columns\TextColumn::make('reference')
                    ->searchable()
                    ->label('Referensi'),

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
            'index' => Pages\ListFinancialTransactions::route('/'),
            'create' => Pages\CreateFinancialTransaction::route('/create'),
            'view' => Pages\ViewFinancialTransaction::route('/{record}'),
            'edit' => Pages\EditFinancialTransaction::route('/{record}/edit'),
        ];
    }
}
