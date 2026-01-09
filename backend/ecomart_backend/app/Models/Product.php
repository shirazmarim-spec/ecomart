<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder; 

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'price',
        'stock',
        'image_url',
        'category_id', 
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'stock' => 'integer',
        ];
    }

   
   public function category()
{
    return $this->belongsTo(Category::class);
}
  
    protected static function booted()
    {
        static::addGlobalScope('available', function (Builder $builder) {
            $builder->where('stock', '>', 0);
        });
    }

    public function getImageUrlAttribute($value)
    {
        return $value ? asset('storage/' . $value) : null;
    }
}
