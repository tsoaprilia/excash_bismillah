const String tableOrderDetail = 'order_detail';

class OrderDetailFields {
  static const String id_order_detail = 'id_order_detail';
  static const String id_order = 'id_order';
  static const String id_product = 'id_product';
  static const String quantity = 'quantity';
  static const String price = 'price';
  static const String subtotal = 'subtotal';
}

class OrderDetail {
  final int? id_order_detail;
  final int id_order;
  final int id_product;
  final int quantity;
  final double price;
  final double subtotal;

  OrderDetail({
    this.id_order_detail,
    required this.id_order,
    required this.id_product,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  Map<String, dynamic> toJson() => {
        OrderDetailFields.id_order_detail: id_order_detail,
        OrderDetailFields.id_order: id_order,
        OrderDetailFields.id_product: id_product,
        OrderDetailFields.quantity: quantity,
        OrderDetailFields.price: price,
        OrderDetailFields.subtotal: subtotal,
      };

  static OrderDetail fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id_order_detail:
          int.tryParse(json[OrderDetailFields.id_order_detail].toString()) ?? 0,
      id_order: int.tryParse(json[OrderDetailFields.id_order].toString()) ?? 0,
      id_product:
          int.tryParse(json[OrderDetailFields.id_product].toString()) ?? 0,
      quantity: int.tryParse(json[OrderDetailFields.quantity].toString()) ?? 0,
      price: double.tryParse(json[OrderDetailFields.price].toString()) ?? 0.0,
      subtotal:
          double.tryParse(json[OrderDetailFields.subtotal].toString()) ?? 0.0,
    );
  }

  OrderDetail copy({
    int? id_order_detail,
    int? id_order,
    int? id_product,
    int? quantity,
    double? price,
    double? subtotal,
  }) =>
      OrderDetail(
        id_order_detail: id_order_detail ?? this.id_order_detail,
        id_order: id_order ?? this.id_order,
        id_product: id_product ?? this.id_product,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
        subtotal: subtotal ?? this.subtotal,
      );
}
