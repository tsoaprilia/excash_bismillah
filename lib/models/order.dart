const String tableOrders = 'orders';

class OrderFields {
  static const String id_order = 'id_order';
  static const String id = 'id'; // Tambahkan id
  static const String total_product = 'total_product';
  static const String total_price = 'total_price';
  static const String payment = 'payment';
  static const String change = 'change';
  static const String created_at = 'created_at';
}

class Order {
  final int? id_order;
  final String id;
  final int total_product;
  final int total_price;
  final int payment;
  final int change;
  final DateTime created_at;

  Order({
    this.id_order,
    required this.id,
    required this.total_product,
    required this.total_price,
    required this.payment,
    required this.change,
    required this.created_at,
  });

  Map<String, dynamic> toJson() => {
        OrderFields.id_order: id_order,
        OrderFields.id: id,
        OrderFields.total_product: total_product,
        OrderFields.total_price: total_price,
        OrderFields.payment: payment,
        OrderFields.change: change,
        OrderFields.created_at: created_at.toIso8601String(),
      };

  static Order fromJson(Map<String, dynamic> json) => Order(
        id_order: json[OrderFields.id_order],
        id: json[OrderFields.id] ?? 0, // Default 0 jika null
        total_product: json[OrderFields.total_product],
        total_price: json[OrderFields.total_price],
        payment: json[OrderFields.payment],
        change: json[OrderFields.change],
        created_at: DateTime.parse(json[OrderFields.created_at]),
      );

  Order copy({
    int? id_order,
    String? id,
    int? total_product,
    int? total_price,
    int? payment,
    int? change,
    DateTime? created_at,
  }) =>
      Order(
        id_order: id_order ?? this.id_order,
        id: id ?? this.id,
        total_product: total_product ?? this.total_product,
        total_price: total_price ?? this.total_price,
        payment: payment ?? this.payment,
        change: change ?? this.change,
        created_at: created_at ?? this.created_at,
      );
}
