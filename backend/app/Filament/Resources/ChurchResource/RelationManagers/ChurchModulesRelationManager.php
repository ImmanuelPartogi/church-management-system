<?php

namespace App\Filament\Resources\ChurchResource\RelationManagers;

use App\Models\ChurchModule;
use App\Services\Tenant\ChurchModuleService;
use Filament\Actions\Action;
use Filament\Notifications\Notification;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use InvalidArgumentException;

class ChurchModulesRelationManager extends RelationManager
{
    protected static string $relationship = 'churchModules';

    protected static ?string $title = 'Modul & Fitur Gereja';

    public function form(Schema $schema): Schema
    {
        return $schema->components([]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('id')
            ->columns([
                TextColumn::make('module.name')
                    ->label('Nama Modul')
                    ->searchable()
                    ->weight('medium'),

                TextColumn::make('module.key')
                    ->label('Identifier')
                    ->badge()
                    ->color('gray'),

                IconColumn::make('module.is_core')
                    ->label('Core Modul')
                    ->boolean()
                    ->trueIcon('heroicon-o-shield-check')
                    ->falseIcon('heroicon-o-minus')
                    ->trueColor('primary')
                    ->falseColor('gray'),

                TextColumn::make('module.parentModule.name')
                    ->label('Bergantung Pada')
                    ->placeholder('-'),

                IconColumn::make('is_enabled')
                    ->label('Status Aktif')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-x-circle')
                    ->trueColor('success')
                    ->falseColor('danger'),

                TextColumn::make('disabled_at')
                    ->label('Nonaktif Sejak')
                    ->dateTime()
                    ->placeholder('-')
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([])
            ->headerActions([])
            ->recordActions([
                Action::make('toggleStatus')
                    ->label(fn (ChurchModule $record): string => $record->is_enabled ? 'Nonaktifkan' : 'Aktifkan')
                    ->color(fn (ChurchModule $record): string => $record->is_enabled ? 'danger' : 'success')
                    ->icon(fn (ChurchModule $record): string => $record->is_enabled ? 'heroicon-o-x-circle' : 'heroicon-o-check-circle')
                    ->disabled(fn (ChurchModule $record): bool => (bool) $record->module?->is_core)
                    ->tooltip(fn (ChurchModule $record): ?string => $record->module?->is_core ? 'Modul inti tidak dapat dinonaktifkan.' : null)
                    ->requiresConfirmation()
                    ->modalHeading(fn (ChurchModule $record): string => ($record->is_enabled ? 'Nonaktifkan Modul ' : 'Aktifkan Modul ').$record->module?->name)
                    ->modalDescription(fn (ChurchModule $record): string => $record->is_enabled
                        ? "Apakah Anda yakin ingin menonaktifkan modul {$record->module?->name}? Data tidak akan dihapus, namun endpoint API dan antarmuka terkait akan ditutup untuk gereja ini."
                        : "Apakah Anda yakin ingin mengaktifkan modul {$record->module?->name} untuk gereja ini?")
                    ->action(function (ChurchModule $record): void {
                        $service = app(ChurchModuleService::class);
                        try {
                            if ($record->is_enabled) {
                                $service->disableModule($record->church, $record->module->key);
                                Notification::make()
                                    ->title("Modul '{$record->module->name}' berhasil dinonaktifkan.")
                                    ->success()
                                    ->send();
                            } else {
                                $service->enableModule($record->church, $record->module->key);
                                Notification::make()
                                    ->title("Modul '{$record->module->name}' berhasil diaktifkan.")
                                    ->success()
                                    ->send();
                            }
                        } catch (InvalidArgumentException $e) {
                            Notification::make()
                                ->title('Gagal Mengubah Status Modul')
                                ->body($e->getMessage())
                                ->danger()
                                ->send();
                        }
                    }),
            ])
            ->toolbarActions([]);
    }
}
