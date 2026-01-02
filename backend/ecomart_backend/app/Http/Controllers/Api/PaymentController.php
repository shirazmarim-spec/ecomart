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
                'amount' => $order->total * 100, 
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

        if ($event->type == 'payment_intent.succeeded') {
            $paymentIntent = $event->data->object;
            $orderId = $paymentIntent->metadata['order_id'];
            $order = Order::findOrFail($orderId);
            $order->status = 'paid';
            $order->save();
        }

        return response()->json(['status' => 'success'], 200);
    }
}