<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Telegram;

class NotificationController extends Controller
{
   public function send(Request $request)
{
    $user = $request->user(); 

    if (!$user || !$user->telegram_chat_id) {
        return response()->json(['error' => 'No Telegram chat ID for this user'], 400);
    }

    $message = $request->message ?? "مرحبا {$user->name}! 🎉\nتم تسجيل الدخول بنجاح في Ecomart. ابدأ التسوق الآن! 🛒";

    try {
        \Telegram::bot('mybot')->sendMessage([
            'chat_id' => $user->telegram_chat_id,
            'text' => $message,
            'parse_mode' => 'HTML',
        ]);
        return response()->json(['message' => 'Notification sent successfully!']);
    } catch (\Exception $e) {
        \Log::error('Telegram send failed: ' . $e->getMessage());
        return response()->json(['error' => 'Failed to send notification'], 500);
    }
}
}