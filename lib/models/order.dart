import 'dart:convert';

class Order {
  final int id;
  final int userId;
  final double total;
  final String status;
  final List<Map<String, dynamic>> products;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    required this.products,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      total: double.parse(json['total'].toString()),
      status: json['status'],
      products: json['products'] is String
          ? (jsonDecode(json['products']) as List)
                .map((p) => p as Map<String, dynamic>)
                .toList()
          : (json['products'] as List)
                .map((p) => p as Map<String, dynamic>)
                .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total': total,
      'status': status,
      'products': products,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

