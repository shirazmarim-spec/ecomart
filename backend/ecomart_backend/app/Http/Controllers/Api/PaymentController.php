<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Stripe\Stripe;
use Stripe\PaymentIntent;
use App\Models\Order;
use Illuminate\Support\Facades\Log;

class PaymentController extends Controller
{
    public function __construct()
    {
        Stripe::setApiKey(env('STRIPE_SECRET'));
    }

  public function createIntent(Request $request)
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json(['error' => 'Unauthorized'], 401);
            }

            $order = Order::findOrFail($request->order_id);
            if ($order->user_id != $user->id) {
                return response()->json(['error' => 'Unauthorized'], 401);
            }

            $intent = PaymentIntent::create([
                'amount' => (int) bcmul($order->total, 100, 0), 
                'currency' => 'usd',
                'metadata' => ['order_id' => $order->id],
            ]);

            return response()->json([
                'client_secret' => $intent->client_secret,
            ]);
        } catch (\Exception $e) {
            Log::error('Payment Intent Error: ' . $e->getMessage()); 
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
    public function webhook(Request $request)
    {
        $payload = $request->getContent();
        $sigHeader = $request->header('Stripe-Signature');
        $endpointSecret = env('STRIPE_WEBHOOK_SECRET');

        try {
            $event = \Stripe\Webhook::constructEvent($payload, $sigHeader, $endpointSecret);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Webhook signature verification failed'], 400);
        }

       if ($event->type === 'payment_intent.succeeded') {
    $paymentIntent = $event->data->object;

   
    $orderId = $paymentIntent->metadata['order_id'] ?? null;
    if (!$orderId) {
        Log::warning('Webhook received without order_id');
        return response()->json(['status' => 'ignored'], 200);
    }

    $order = Order::find($orderId);

    if (!$order) {
        Log::warning("Order not found for ID: $orderId");
        return response()->json(['status' => 'ignored'], 200);
    }

   
    if ($order->status === 'paid') {
        return response()->json(['status' => 'already_paid'], 200);
    }

   
    $order->status = 'paid';
    $order->save();

    Log::info("Order $orderId marked as paid via webhook");
}
        return response()->json(['status' => 'success'], 200);
    }
}
