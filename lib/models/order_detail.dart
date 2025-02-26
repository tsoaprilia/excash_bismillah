const String tableOrderDetail = 'order_detail';
class OrderDetail {
  final int? id_order_detail;
  final int id_order;
  final String id_product;
  final int amount;
  final int subtotal;
  final DateTime created_at;
  final DateTime updated_at;

  OrderDetail({
    this.id_order_detail,
    required this.id_order,
    required this.id_product,
    required this.amount,
    required this.subtotal,
    required this.created_at,
    required this.updated_at,
  });

  // Tambahkan metode copy
  OrderDetail copy({
    int? id_order_detail,
    int? id_order,
    String? id_product,
    int? amount,
    int? subtotal,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return OrderDetail(
      id_order_detail: id_order_detail ?? this.id_order_detail,
      id_order: id_order ?? this.id_order,
      id_product: id_product ?? this.id_product,
      amount: amount ?? this.amount,
      subtotal: subtotal ?? this.subtotal,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_order_detail': id_order_detail,
      'id_order': id_order,
      'id_product': id_product,
      'amount': amount,
      'subtotal': subtotal,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
    };
  }

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id_order_detail: json['id_order_detail'],
      id_order: json['id_order'],
      id_product: json['id_product'],
      amount: json['amount'],
      subtotal: json['subtotal'],
      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
    );
  }
}
