<?php

namespace App\Services\Notifications;

use App\Models\DeviceToken;
use App\Models\User;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Exception\MessagingException;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Throwable;

class FcmNotificationService
{
    public function __construct(
        protected ?Messaging $messaging = null
    ) {
        if (! $this->messaging && app()->bound(Messaging::class)) {
            $this->messaging = app(Messaging::class);
        }
    }

    /**
     * Send notification to a single FCM device token.
     *
     * @param  array<string, mixed>  $data
     */
    public function sendToToken(string $token, string $title, string $body, array $data = []): bool
    {
        if (! $this->messaging) {
            Log::warning('FCM Notification skipped: Messaging service not bound.');

            return false;
        }

        try {
            $message = CloudMessage::new()
                ->withToken($token)
                ->withNotification(Notification::create($title, $body))
                ->withData($data);

            $this->messaging->send($message);

            return true;
        } catch (MessagingException $e) {
            Log::warning('FCM MessagingException sending to token: '.$e->getMessage());
            $this->handleInvalidTokenException($e, $token);

            return false;
        } catch (Throwable $e) {
            Log::error('FCM Error sending to token: '.$e->getMessage());

            return false;
        }
    }

    /**
     * Send notification to all device tokens of a user.
     *
     * @param  array<string, mixed>  $data
     */
    public function sendToUser(User $user, string $title, string $body, array $data = []): int
    {
        /** @var array<int, string> $tokens */
        $tokens = $user->deviceTokens()->pluck('token')->toArray();
        if (empty($tokens)) {
            return 0;
        }

        $successCount = 0;
        foreach ($tokens as $token) {
            if ($this->sendToToken($token, $title, $body, $data)) {
                $successCount++;
            }
        }

        return $successCount;
    }

    /**
     * Broadcast notification to active device tokens.
     *
     * @param  array<string, mixed>  $data
     */
    public function broadcast(string $title, string $body, array $data = [], ?string $role = null): int
    {
        $query = DeviceToken::query();

        if ($role) {
            $query->whereHas('user', function ($q) use ($role) {
                $q->whereHas('roles', function ($r) use ($role) {
                    $r->where('name', $role);
                });
            });
        }

        /** @var array<int, string> $tokens */
        $tokens = $query->pluck('token')->unique()->toArray();
        if (empty($tokens)) {
            return 0;
        }

        $successCount = 0;
        foreach ($tokens as $token) {
            if ($this->sendToToken($token, $title, $body, $data)) {
                $successCount++;
            }
        }

        return $successCount;
    }

    /**
     * Delete invalid or unregistered device tokens.
     */
    protected function handleInvalidTokenException(MessagingException $e, string $token): void
    {
        $message = strtolower($e->getMessage());
        if (str_contains($message, 'notfound') || str_contains($message, 'unregistered') || str_contains($message, 'invalid')) {
            DeviceToken::where('token', $token)->delete();
            Log::info("Purged invalid FCM device token: {$token}");
        }
    }
}
