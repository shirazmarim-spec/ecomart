<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;

class OrdersController extends Controller
{
    public function index()
    {
        try {
            $user = request()->user(); 
            if (!$user) {
                return response()->json(['error' => 'User not authenticated'], 401);
            }
            $orders = $user->orders()->get();
            return response()->json([
                'data' => $orders,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
                'line' => $e->getLine(),
                'file' => $e->getFile(),
            ], 500); 
        }
    }

    public function store(Request $request)
    {
        try {
            $user = request()->user();
            if (!$user) {
                return response()->json(['error' => 'User not authenticated'], 401);
            }
            $order = Order::create([
                'user_id' => $user->id,
                'total' => $request->total,
                'status' => 'pending',
                'products' => $request->products,
            ]);

            return response()->json([
                'message' => 'Order placed successfully',
                'data' => $order,
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage(),
                'line' => $e->getLine(),
            ], 500); 
        }
    }
}
