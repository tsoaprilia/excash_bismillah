const String tableOrderDetail = 'order_detail';

class OrderDetailFields {
  static const String id_order_detail = 'id_order_detail';
  static const String id_order = 'id_order';
  static const String id_product = 'id_product';
  static const String amount = 'amount';
  static const String subtotal = 'subtotal';
  static const String created_at = 'created_at';
  static const String updated_at = 'updated_at';
}

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

  Map<String, dynamic> toJson() => {
        OrderDetailFields.id_order_detail: id_order_detail,
        OrderDetailFields.id_order: id_order,
        OrderDetailFields.id_product: id_product,
        OrderDetailFields.amount: amount,
        OrderDetailFields.subtotal: subtotal,
        OrderDetailFields.created_at: created_at.toIso8601String(),
        OrderDetailFields.updated_at: updated_at.toIso8601String(),
      };

  static OrderDetail fromJson(Map<String, dynamic> json) => OrderDetail(
        id_order_detail: json[OrderDetailFields.id_order_detail],
        id_order: json[OrderDetailFields.id_order],
        id_product: json[OrderDetailFields.id_product],
        amount: json[OrderDetailFields.amount],
        subtotal: json[OrderDetailFields.subtotal],
        created_at: DateTime.parse(json[OrderDetailFields.created_at]),
        updated_at: DateTime.parse(json[OrderDetailFields.updated_at]),
      );
}
