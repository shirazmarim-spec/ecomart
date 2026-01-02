<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Product;
use App\Models\Category;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $category1 = Category::create([
            'name' => 'Electronics',
            'description' => 'Gadgets and tech products.',
        ]);

        $category2 = Category::create([
            'name' => 'Clothing',
            'description' => 'Fashion items.',
        ]);

        Product::create([
            'name' => 'Sample Product 1',
            'description' => 'A great product for testing!',
            'price' => 99.99,
            'stock' => 10,
            'image_url' => 'https://example.com/image1.jpg', 
            'category_id' => $category1->id,
        ]);

        Product::create([
            'name' => 'Sample Product 2',
            'description' => 'Another awesome item.',
            'price' => 149.99,
            'stock' => 5,
            'image_url' => 'https://example.com/image2.jpg',
            'category_id' => $category2->id,
        ]);
    }
}