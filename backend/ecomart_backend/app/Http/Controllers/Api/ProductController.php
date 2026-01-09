<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use App\Http\Resources\ProductResource;
use App\Http\Requests\StoreProductRequest;
use App\Http\Requests\UpdateProductRequest;

class ProductController extends Controller
{
    /**
     * Display a listing of products (public, with pagination and search).
     */
public function index(Request $request)
{
    $query = Product::query();

    if ($request->has('category_id')) {
        $query->where('category_id', $request->category_id);
    }

    $products = $query->with('category')->get();

    
    return response()->json([
        'data' => $products,
        'meta' => [
            'total' => $products->count(),
        ]
    ]);
}
    /**
     * Store a new product (protected by auth in route).
     */
    public function store(StoreProductRequest $request)
{
    $product = Product::create($request->validated());

    return response()->json([
        'message' => 'Product created successfully',
        'data' => new ProductResource($product)
    ], 201);
}

    /**
     * Display the specified product.
     */
    public function show(Product $product)
    {
        
        if ($product->trashed()) {
            return response()->json(['error' => 'Product not found'], 404);
        }

        return response()->json(new ProductResource($product));
    }

    /**
     * Update the specified product.
     */
    public function update(UpdateProductRequest $request, Product $product)
    {
        $product->update($request->validated());

        return response()->json([
            'message' => 'Product updated successfully',
            'data' => new ProductResource($product)
        ]);
    }

    /**
     * Remove the specified product (soft delete).
     */
    public function destroy(Product $product)
    {
        $product->delete();

        return response()->json(['message' => 'Product deleted successfully'], 204);
    }
}
