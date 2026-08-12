<?php

namespace App\Filament\Resources;

use App\Enums\ChurchServantRole;
use App\Filament\Resources\ChurchServantResource\Pages;
use App\Models\ChurchServant;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;

class ChurchServantResource extends Resource
{
    protected static ?string $model = ChurchServant::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-academic-cap';

    protected static \UnitEnum|string|null $navigationGroup = 'Community & Ministry';

    protected static ?string $modelLabel = 'Church Servant / Pelayan Gereja';

    protected static ?string $pluralModelLabel = 'Church Servants';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\Select::make('member_id')
                    ->relationship('member', 'full_name')
                    ->searchable()
                    ->nullable()
                    ->label('Linked Church Member'),

                Forms\Components\TextInput::make('name')
                    ->required()
                    ->maxLength(255)
                    ->label('Servant Full Name'),

                Forms\Components\Select::make('role')
                    ->options([
                        'pdt_resort' => 'Pendeta Resort',
                        'sintua' => 'Sintua / Penatua',
                        'majelis' => 'Anggota Majelis',
                        'sector_leader' => 'Ketua Sektor/Wijk',
                        'fellowship_leader' => 'Pengurus Punguan',
                    ])
                    ->required()
                    ->label('Servant Ministry Role'),

                Forms\Components\TextInput::make('phone')
                    ->tel()
                    ->nullable()
                    ->maxLength(255)
                    ->label('Phone Number'),

                Forms\Components\TextInput::make('email')
                    ->email()
                    ->nullable()
                    ->maxLength(255)
                    ->label('Email Address'),

                Forms\Components\Select::make('resort_id')
                    ->relationship('resort', 'name')
                    ->nullable()
                    ->label('Resort Assignment'),

                Forms\Components\Select::make('sector_id')
                    ->relationship('sector', 'name')
                    ->nullable()
                    ->label('Sector Assignment'),

                Forms\Components\Select::make('fellowship_id')
                    ->relationship('fellowship', 'name')
                    ->nullable()
                    ->label('Fellowship Assignment'),

                Forms\Components\Textarea::make('description')
                    ->rows(3)
                    ->nullable()
                    ->columnSpanFull()
                    ->label('Notes / Ministry Description'),

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
                    ->label('Nama Pelayan'),

                Tables\Columns\BadgeColumn::make('role')
                    ->colors([
                        'primary' => ChurchServantRole::PdtResort,
                        'success' => ChurchServantRole::Sintua,
                        'info' => ChurchServantRole::Majelis,
                        'warning' => ChurchServantRole::SectorLeader,
                        'secondary' => ChurchServantRole::FellowshipLeader,
                    ])
                    ->label('Jabatan / Pelayanan'),

                Tables\Columns\TextColumn::make('phone')
                    ->searchable()
                    ->label('No. Telepon'),

                Tables\Columns\TextColumn::make('sector.name')
                    ->searchable()
                    ->label('Sektor'),

                Tables\Columns\IconColumn::make('active')
                    ->boolean()
                    ->label('Status Aktif'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('role')
                    ->options([
                        'pdt_resort' => 'Pendeta Resort',
                        'sintua' => 'Sintua',
                        'majelis' => 'Majelis',
                        'sector_leader' => 'Ketua Sektor',
                        'fellowship_leader' => 'Pengurus Punguan',
                    ]),
                Tables\Filters\SelectFilter::make('sector_id')
                    ->relationship('sector', 'name')
                    ->label('Filter Sektor'),
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
            'index' => Pages\ListChurchServants::route('/'),
            'create' => Pages\CreateChurchServant::route('/create'),
            'view' => Pages\ViewChurchServant::route('/{record}'),
            'edit' => Pages\EditChurchServant::route('/{record}/edit'),
        ];
    }
}
