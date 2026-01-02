<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function updateTelegram(Request $request)
    {
        $request->validate([
            'telegram_chat_id' => 'required|string',
        ]);

        $user = $request->user();
        $user->telegram_chat_id = $request->telegram_chat_id;
        $user->save();

        return response()->json([
            'message' => 'Telegram account linked successfully!',
            'telegram_chat_id' => $user->telegram_chat_id,
        ]);
    }
}