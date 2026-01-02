<?php

namespace App\Services;

use Telegram\Bot\Laravel\Facades\Telegram; 
use Illuminate\Support\Facades\Log;
use App\Models\User; 

class TelegramService
{
    /**
     * Send message to a specific user.
     */
    public function sendToUser(int $userId, string $message, array $options = []): bool
    {
        $user = User::find($userId);
        if (!$user || !$user->telegram_chat_id) {
            Log::warning('No chat_id for user', ['user_id' => $userId]);
            return false; 
        }

        try {
            Telegram::sendMessage(array_merge([
                'chat_id' => $user->telegram_chat_id,
                'text' => $message,
                'parse_mode' => 'HTML', 
            ], $options)); 

            Log::info('Telegram message sent successfully', [
                'user_id' => $userId,
                'message_preview' => substr($message, 0, 50) 
            ]);
            return true;
        } catch (\Exception $e) {
            Log::error('Telegram send failed', [
                'user_id' => $userId,
                'error' => $e->getMessage(),
            ]);
            return false;
        }
    }
}