const String tableProduct = 'product';

class ProductFields {
  static const String id_product = 'id_product';
  static const String id_category = 'id_category';
  static const String name_product = 'name_product';
  static const String price = 'price';
  static const String selling_price = 'selling_price';
  static const String stock = 'stock';
  static const String description = 'description';
  static const String created_at = 'created_at';
  static const String updated_at = 'updated_at';
  static const String image_product = 'image_product';
}

class Product {
  final String id_product;
  final int id_category;
  final String name_product;
  final int price;
  final int selling_price;
  final int stock;
  final String description;
  final DateTime created_at;
  final DateTime updated_at;
  final String? image_product;

  Product({
    required this.id_product,
    required this.id_category,
    required this.name_product,
    required this.price,
    required this.selling_price,
    required this.stock,
    required this.description,
    required this.created_at,
    required this.updated_at,
    this.image_product,
  });

  get category => null;

  Map<String, dynamic> toJson() => {
        ProductFields.id_product: id_product,
        ProductFields.id_category: id_category,
        ProductFields.name_product: name_product,
        ProductFields.price: price,
        ProductFields.selling_price: selling_price,
        ProductFields.stock: stock,
        ProductFields.description: description,
        ProductFields.created_at: created_at.toIso8601String(),
        ProductFields.updated_at: updated_at.toIso8601String(),
        ProductFields.image_product: image_product,
      };

  static Product fromJson(Map<String, dynamic> json) => Product(
        id_product: json[ProductFields.id_product],
        id_category: json[ProductFields.id_category],
        name_product: json[ProductFields.name_product],
        price: json[ProductFields.price],
        selling_price: json[ProductFields.selling_price],
        stock: json[ProductFields.stock],
        description: json[ProductFields.description],
        created_at: DateTime.parse(json[ProductFields.created_at]),
        updated_at: DateTime.parse(json[ProductFields.updated_at]),
        image_product: json[ProductFields.image_product],
      );

  Product copy({
    String? id_product,
    int? id_category,
    String? name_product,
    int? price,
    int? selling_price,
    int? stock,
    String? description,
    DateTime? created_at,
    DateTime? updated_at,
    String? image_product,
  }) =>
      Product(
        id_product: id_product ?? this.id_product,
        id_category: id_category ?? this.id_category,
        name_product: name_product ?? this.name_product,
        price: price ?? this.price,
        selling_price: selling_price ?? this.selling_price,
        stock: stock ?? this.stock,
        description: description ?? this.description,
        created_at: created_at ?? this.created_at,
        updated_at: updated_at ?? this.updated_at,
        image_product: image_product ?? this.image_product,
      );
}

// const String tableProduct = 'product';

// class ProductFields {
//   static final List<String> values = [
//     id_product, id_category, name_product, price, selling_price, stock, description, created_at, updated_at, image_product
//   ];

//   static const String id_product = 'id_product';
//   static const String id_category = 'id_category';
//   static const String name_product = 'name_product';
//   static const String price = 'price';
//   static const String selling_price = 'selling_price';
//   static const String stock = 'stock';
//   static const String description = 'description';
//   static const String created_at = 'created_at';
//   static const String updated_at = 'updated_at';
//   static const String image_product = 'image_product';
// }

// class Product {
//   final String id_product;
//   final int id_category;
//   final String name_product;
//   final int price;
//   final int selling_price;
//   final int stock;
//   final String description;
//   final DateTime created_at;
//   final DateTime updated_at;
//   final String image_product;

//   Product({
//     required this.id_product,
//     required this.id_category,
//     required this.name_product,
//     required this.price,
//     required this.selling_price,
//     required this.stock,
//     required this.description,
//     required this.created_at,
//     required this.updated_at,
//     required this.image_product,
//   });

//   Map<String, dynamic> toJson() => {
//         ProductFields.id_product: id_product,
//         ProductFields.id_category: id_category,
//         ProductFields.name_product: name_product,
//         ProductFields.price: price,
//         ProductFields.selling_price: selling_price,
//         ProductFields.stock: stock,
//         ProductFields.description: description,
//         ProductFields.created_at: created_at.toIso8601String(),
//         ProductFields.updated_at: updated_at.toIso8601String(),
//         ProductFields.image_product: image_product,
//       };

//   static Product fromJson(Map<String, dynamic> json) => Product(
//         id_product: json[ProductFields.id_product],
//         id_category: json[ProductFields.id_category],
//         name_product: json[ProductFields.name_product],
//         price: json[ProductFields.price],
//         selling_price: json[ProductFields.selling_price],
//         stock: json[ProductFields.stock],
//         description: json[ProductFields.description],
//         created_at: DateTime.parse(json[ProductFields.created_at]),
//         updated_at: DateTime.parse(json[ProductFields.updated_at]),
//         image_product: json[ProductFields.image_product],
//       );

//   Product copy({String? id_product}) => Product(
//         id_product: id_product ?? this.id_product,
//         id_category: id_category,
//         name_product: name_product,
//         price: price,
//         selling_price: selling_price,
//         stock: stock,
//         description: description,
//         created_at: created_at,
//         updated_at: updated_at,
//         image_product: image_product,
//       );
// }
