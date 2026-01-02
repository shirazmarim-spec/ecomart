<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{public function up(): void
{
    Schema::create('products', function (Blueprint $table) {
        $table->id();
        $table->string('name');
        $table->text('description')->nullable();
        $table->decimal('price', 8, 2);
        $table->integer('stock')->default(0);
        $table->string('image_url')->nullable();
        $table->unsignedBigInteger('category_id')->nullable(); 
        $table->timestamps();
        $table->softDeletes(); 
        $table->index(['name', 'stock']);
        $table->foreign('category_id')->references('id')->on('categories')->onDelete('set null');
    });
}

public function down(): void
{
    Schema::dropIfExists('products');
}
};