<?php

namespace App\Filament\Resources;

use App\Filament\Resources\AnnouncementResource\Pages;
use App\Models\Announcement;
use App\Services\Notifications\FcmNotificationService;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Str;

class AnnouncementResource extends Resource
{
    protected static ?string $model = Announcement::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-megaphone';

    protected static \UnitEnum|string|null $navigationGroup = 'Content Management';

    protected static ?string $modelLabel = 'Announcement';

    protected static ?string $pluralModelLabel = 'Announcements';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->schema([
                Forms\Components\TextInput::make('title')
                    ->required()
                    ->maxLength(255)
                    ->label('Title'),

                Forms\Components\Textarea::make('content')
                    ->required()
                    ->rows(4)
                    ->columnSpanFull()
                    ->label('Content'),

                Forms\Components\FileUpload::make('image')
                    ->image()
                    ->directory('announcements')
                    ->nullable()
                    ->label('Cover Image'),

                Forms\Components\DateTimePicker::make('published_at')
                    ->nullable()
                    ->label('Published Date & Time'),

                Forms\Components\Select::make('status')
                    ->options([
                        'draft' => 'Draft',
                        'published' => 'Published',
                        'archived' => 'Archived',
                    ])
                    ->default('draft')
                    ->required()
                    ->label('Status'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->circular()
                    ->label('Gambar'),

                Tables\Columns\TextColumn::make('title')
                    ->searchable()
                    ->sortable()
                    ->label('Judul Pengumuman'),

                Tables\Columns\BadgeColumn::make('status')
                    ->colors([
                        'warning' => 'draft',
                        'success' => 'published',
                        'gray' => 'archived',
                    ])
                    ->label('Status'),

                Tables\Columns\TextColumn::make('published_at')
                    ->dateTime()
                    ->sortable()
                    ->label('Tanggal Terbit'),

                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'draft' => 'Draft',
                        'published' => 'Published',
                        'archived' => 'Archived',
                    ]),
            ])
            ->actions([
                Actions\ViewAction::make(),
                Actions\EditAction::make(),
                Actions\Action::make('sendNotification')
                    ->label('Kirim Push')
                    ->icon('heroicon-o-paper-airplane')
                    ->color('success')
                    ->form([
                        Forms\Components\TextInput::make('title')
                            ->default(fn (Announcement $record) => $record->title)
                            ->required(),
                        Forms\Components\Textarea::make('body')
                            ->default(fn (Announcement $record) => Str::limit(strip_tags($record->content), 100))
                            ->required(),
                        Forms\Components\TextInput::make('route')
                            ->default(fn (Announcement $record) => '/announcements')
                            ->required(),
                    ])
                    ->action(function (Announcement $record, array $data): void {
                        /** @var FcmNotificationService $fcmService */
                        $fcmService = app(FcmNotificationService::class);
                        $count = $fcmService->broadcast(
                            $data['title'],
                            $data['body'],
                            [
                                'type' => 'announcement',
                                'entity_id' => (string) $record->id,
                                'route' => $data['route'],
                            ]
                        );
                        Notification::make()
                            ->title('Push notification terkirim.')
                            ->body("Berhasil diproses untuk {$count} perangkat.")
                            ->success()
                            ->send();
                    }),
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
            'index' => Pages\ListAnnouncements::route('/'),
            'create' => Pages\CreateAnnouncement::route('/create'),
            'view' => Pages\ViewAnnouncement::route('/{record}'),
            'edit' => Pages\EditAnnouncement::route('/{record}/edit'),
        ];
    }
}
