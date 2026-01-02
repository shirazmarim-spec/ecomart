<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\OrdersController; 
use App\Http\Controllers\Api\PaymentController; 
use App\Http\Controllers\Api\ProfileController; 

use Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful;

Route::post('/auth/register', [AuthController::class, 'register'])->name('auth.register');
Route::post('/auth/login', [AuthController::class, 'login'])->name('auth.login');
Route::get('/products', [ProductController::class, 'index']);
Route::get('/products/{product}', [ProductController::class, 'show']);

Route::get('/test', function () {
    return response()->json(['message' => 'API works! User: Test', 'status' => 200]);
});

Route::post('/notifications/send-test', [NotificationController::class, 'send']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    Route::apiResource('products', ProductController::class)->only(['store', 'update', 'destroy']);

    Route::post('/notifications/send', [NotificationController::class, 'send'])->name('notifications.send');

    Route::apiResource('orders', OrdersController::class)->only(['index', 'store']); 

    Route::post('/payments/intent', [PaymentController::class, 'createIntent']);

  
    Route::post('/profile/update-telegram', [ProfileController::class, 'updateTelegram']);
});

Route::post('/payments/webhook', [PaymentController::class, 'webhook']);
Route::get('/debug-products', function () {
    return App\Models\Product::all();
});