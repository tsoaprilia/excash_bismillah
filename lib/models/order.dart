const String tableOrder = 'order';

class OrderFields {
  static const String id_order = 'id_order';
  static const String id_user = 'id_user';
  static const String total_product = 'total_product';
  static const String total_price = 'total_price';
  static const String diskon_type = 'diskon_type';
  static const String diskon_value = 'diskon_value';
  static const String payment = 'payment';
  static const String change = 'change';
  static const String created_at = 'created_at';
  static const String updated_at = 'updated_at';
}

class Order {
  final int? id_order;
  final int id_user;
  final int total_product;
  final int total_price;
  final bool diskon_type;
  final int diskon_value;
  final int payment;
  final int change;
  final DateTime created_at;
  final DateTime updated_at;

  Order({
    this.id_order,
    required this.id_user,
    required this.total_product,
    required this.total_price,
    required this.diskon_type,
    required this.diskon_value,
    required this.payment,
    required this.change,
    required this.created_at,
    required this.updated_at,
  });

  Map<String, dynamic> toJson() => {
        OrderFields.id_order: id_order,
        OrderFields.id_user: id_user,
        OrderFields.total_product: total_product,
        OrderFields.total_price: total_price,
        OrderFields.diskon_type: diskon_type ? 1 : 0,
        OrderFields.diskon_value: diskon_value,
        OrderFields.payment: payment,
        OrderFields.change: change,
        OrderFields.created_at: created_at.toIso8601String(),
        OrderFields.updated_at: updated_at.toIso8601String(),
      };

  static Order fromJson(Map<String, dynamic> json) => Order(
        id_order: json[OrderFields.id_order],
        id_user: json[OrderFields.id_user],
        total_product: json[OrderFields.total_product],
        total_price: json[OrderFields.total_price],
        diskon_type: json[OrderFields.diskon_type] == 1,
        diskon_value: json[OrderFields.diskon_value],
        payment: json[OrderFields.payment],
        change: json[OrderFields.change],
        created_at: DateTime.parse(json[OrderFields.created_at]),
        updated_at: DateTime.parse(json[OrderFields.updated_at]),
      );
}
