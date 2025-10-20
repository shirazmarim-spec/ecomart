<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Product;

class ProductSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Product::create([
            'name' => 'Laptop',
            'description' => 'High-end laptop',
            'price' => 1000.00,
            'stock' => 10,
            'image_url' => 'https://via.placeholder.com/150?text=Laptop',
        ]);

        Product::create([
            'name' => 'Phone',
            'description' => 'Smartphone',
            'price' => 500.00,
            'stock' => 20,
            'image_url' => 'https://via.placeholder.com/150?text=Phone',
        ]);

        // أضيفي 3 أكثر بنفس الشكل
        Product::create([
            'name' => 'Tablet',
            'description' => 'Tablet device',
            'price' => 300.00,
            'stock' => 15,
            'image_url' => 'https://via.placeholder.com/150?text=Tablet',
        ]);

        Product::create([
            'name' => 'Headphones',
            'description' => 'Wireless headphones',
            'price' => 100.00,
            'stock' => 30,
            'image_url' => 'https://via.placeholder.com/150?text=Headphones',
        ]);

        Product::create([
            'name' => 'Mouse',
            'description' => 'Wireless mouse',
            'price' => 20.00,
            'stock' => 50,
            'image_url' => 'https://via.placeholder.com/150?text=Mouse',
        ]);
    }
}