<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ChurchMemberResource\Pages;
use App\Filament\Traits\HasModuleAccess;
use App\Models\ChurchMember;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class ChurchMemberResource extends Resource
{
    use HasModuleAccess;

    public static function getModuleKey(): string
    {
        return 'membership';
    }

    protected static ?string $model = ChurchMember::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-user-group';

    protected static \UnitEnum|string|null $navigationGroup = 'Master Data';

    protected static ?string $modelLabel = 'Church Member';

    protected static ?string $pluralModelLabel = 'Church Members';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\Select::make('user_id')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->nullable()
                    ->label('Associated User Account'),

                Forms\Components\TextInput::make('membership_number')
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->maxLength(255)
                    ->label('Membership Number'),

                Forms\Components\TextInput::make('full_name')
                    ->required()
                    ->maxLength(255)
                    ->label('Full Name'),

                Forms\Components\Select::make('gender')
                    ->options([
                        'Male' => 'Male',
                        'Female' => 'Female',
                    ])
                    ->required()
                    ->label('Gender'),

                Forms\Components\DatePicker::make('birth_date')
                    ->required()
                    ->label('Birth Date'),

                Forms\Components\TextInput::make('phone')
                    ->tel()
                    ->required()
                    ->maxLength(255)
                    ->label('Phone Number'),

                Forms\Components\TextInput::make('email')
                    ->email()
                    ->required()
                    ->maxLength(255)
                    ->label('Email Address'),

                Forms\Components\Textarea::make('address')
                    ->required()
                    ->rows(3)
                    ->columnSpanFull()
                    ->label('Address'),

                Forms\Components\DatePicker::make('baptism_date')
                    ->nullable()
                    ->label('Baptism Date'),

                Forms\Components\Select::make('status')
                    ->options([
                        'active' => 'Active',
                        'inactive' => 'Inactive',
                        'moved' => 'Moved',
                        'deceased' => 'Deceased',
                    ])
                    ->default('active')
                    ->required()
                    ->label('Status'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('membership_number')
                    ->searchable()
                    ->sortable()
                    ->label('No. Anggota'),

                Tables\Columns\TextColumn::make('full_name')
                    ->searchable()
                    ->sortable()
                    ->label('Nama Lengkap'),

                Tables\Columns\TextColumn::make('gender')
                    ->sortable()
                    ->label('Gender'),

                Tables\Columns\TextColumn::make('phone')
                    ->searchable()
                    ->label('Telepon'),

                Tables\Columns\TextColumn::make('email')
                    ->searchable()
                    ->label('Email'),

                Tables\Columns\BadgeColumn::make('status')
                    ->colors([
                        'success' => 'active',
                        'warning' => 'inactive',
                        'gray' => 'moved',
                        'danger' => 'deceased',
                    ])
                    ->label('Status'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('gender')
                    ->options([
                        'Male' => 'Male',
                        'Female' => 'Female',
                    ]),
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'active' => 'Active',
                        'inactive' => 'Inactive',
                        'moved' => 'Moved',
                        'deceased' => 'Deceased',
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
            'index' => Pages\ListChurchMembers::route('/'),
            'create' => Pages\CreateChurchMember::route('/create'),
            'view' => Pages\ViewChurchMember::route('/{record}'),
            'edit' => Pages\EditChurchMember::route('/{record}/edit'),
        ];
    }
}
