<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\RateLimiter;
use App\Models\User;
use App\Http\Resources\UserResource;
use Telegram;

class AuthController extends Controller
{
    /**
     * Send Telegram message to user (reusable method).
     */
    private function sendTelegramMessage(User $user, string $message, string $token = null)
    {
        if (!$user->telegram_chat_id) {
            return; 
        }

        $fullMessage = $message;
        if ($token) {
            $fullMessage .= "\n\nYour API Token: " . $token . "\n(Keep it safe and use in the app!)";
        }

        try {
            Telegram::sendMessage([
                'chat_id' => $user->telegram_chat_id,
                'text' => $fullMessage,
                'parse_mode' => 'HTML', 
            ]);
        } catch (\Exception $e) {
            // Log error لو الـ bot مش شغال: \Log::error('Telegram send failed: ' . $e->getMessage());
        }
    }

    /**
     * Register a new user and send welcome via Telegram.
     */
  public function register(Request $request)
{
    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'email' => 'required|email|unique:users,email',
        'password' => 'required|min:8|confirmed',
        'telegram_chat_id' => 'nullable|string',
    ]);

    $user = User::create([
        'name' => $validated['name'],
        'email' => $validated['email'],
        'password' => Hash::make($validated['password']),
        'telegram_chat_id' => $validated['telegram_chat_id'] ?? null,
        'role' => 'customer',
    ]);

    $token = $user->createToken('api-token')->plainTextToken;

    $this->sendTelegramMessage($user, "Welcome to Ecomart, {$user->name}! 🎉\nYour account is ready. Start shopping!");

    return response()->json([
        'user' => [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'telegram_chat_id' => $user->telegram_chat_id,
            'role' => $user->role,
        ],
        'token' => $token,
    ], 201);
}

    /**
     * Authenticate user with rate limiting and Telegram notification.
     */
    public function login(Request $request)
    {
    
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $key = 'login:' . $request->ip();

        if (RateLimiter::tooManyAttempts($key, 5)) {
            throw ValidationException::withMessages([
                'email' => ['Too many login attempts. Please try again later.'],
            ]);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            RateLimiter::hit($key, 60);
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        RateLimiter::clear($key);

        $token = $user->createToken('api-token')->plainTextToken;

        $this->sendTelegramMessage($user, "Login successful for {$user->name}! 👋\nYou're now connected to Ecomart.", $token);

        
        return response()->json([
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'telegram_chat_id' => $user->telegram_chat_id,
                'role' => $user->role,
            ],
            'token' => $token,
        ]);
    }

    /**
     * Get authenticated user profile.
     */
    public function user(Request $request)
    {
       
        $user = $request->user();
        return response()->json([
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'telegram_chat_id' => $user->telegram_chat_id,
                'role' => $user->role,
            ],
        ]);
    }

    /**
     * Logout current device.
     */
    public function logout(Request $request)
    {
        $user = $request->user();
        $allDevices = $request->boolean('all_devices', false);

        if ($allDevices) {
            $user->tokens()->delete();
            $this->sendTelegramMessage($user, "Logged out from all devices. See you soon! 👋");
        } else {
            $user->currentAccessToken()->delete();
            $this->sendTelegramMessage($user, "Logged out from this device. Safe travels! 🔒");
        }

        return response()->json(['message' => 'Logged out successfully']);
    }
}
