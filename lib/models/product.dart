const String tableProduct = 'product';

class ProductFields {
  static const String id_product = 'id_product';
  static const String id = 'id';
  static const String id_category = 'id_category';
  static const String name_product = 'name_product';
  static const String price = 'price';
  static const String selling_price = 'selling_price';
  static const String stock = 'stock';
  static const String description = 'description';
  static const String created_at = 'created_at';
  static const String updated_at = 'updated_at';
  static const String is_disabled = 'is_disabled';
}

class Product {
  final String id_product;
  final String id;
  final int id_category;
  final String name_product;
  final int price;
  final int selling_price;
   int stock;
  final String description;
  final DateTime created_at;
  final DateTime updated_at;
  final bool is_disabled;

  Product({
    required this.id_product,
    required this.id,
    required this.id_category,
    required this.name_product,
    required this.price,
    required this.selling_price,
    required this.stock,
    required this.description,
    required this.created_at,
    required this.updated_at,
    required this.is_disabled,
  });

  get category => null;

  get category_product => null;

  Map<String, dynamic> toJson() => {
        ProductFields.id_product: id_product,
        ProductFields.id: id,
        ProductFields.id_category: id_category,
        ProductFields.name_product: name_product,
        ProductFields.price: price,
        ProductFields.selling_price: selling_price,
        ProductFields.stock: stock,
        ProductFields.description: description,
        ProductFields.created_at: created_at.toIso8601String(),
        ProductFields.updated_at: updated_at.toIso8601String(),
        ProductFields.is_disabled: is_disabled ? 1 : 0,
      };

  static Product fromJson(Map<String, dynamic> json) => Product(
        id_product: json[ProductFields.id_product],
        id: json[ProductFields.id] as String,
        id_category: json[ProductFields.id_category],
        name_product: json[ProductFields.name_product],
        price: json[ProductFields.price],
        selling_price: json[ProductFields.selling_price],
        stock: json[ProductFields.stock] is int
            ? json[ProductFields.stock]
            : int.tryParse(json[ProductFields.stock]?.toString() ?? '') ??
                0, // Ensure it's an int

        description: json[ProductFields.description],
        created_at: DateTime.parse(json[ProductFields.created_at]),
        updated_at: DateTime.parse(json[ProductFields.updated_at]),
        is_disabled: json[ProductFields.is_disabled] == 1,
      );

  Product copy({
    String? id_product,
    String? id,
    int? id_category,
    String? name_product,
    int? price,
    int? selling_price,
    int? stock,
    String? description,
    DateTime? created_at,
    DateTime? updated_at,
    bool? is_disabled,
  }) =>
      Product(
        id_product: id_product ?? this.id_product,
        id: id ?? this.id,
        id_category: id_category ?? this.id_category,
        name_product: name_product ?? this.name_product,
        price: price ?? this.price,
        selling_price: selling_price ?? this.selling_price,
        stock: stock ?? this.stock,
        description: description ?? this.description,
        created_at: created_at ?? this.created_at,
        updated_at: updated_at ?? this.updated_at,
        is_disabled: is_disabled ?? this.is_disabled,
      );
}
