import 'dart:io';

import 'package:excash/models/excash.dart';
import 'package:excash/models/order.dart';
import 'package:excash/models/order_detail.dart';
import 'package:excash/models/product.dart';
import 'package:excash/models/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ExcashDatabase {
  static final ExcashDatabase instance = ExcashDatabase._init();

  ExcashDatabase._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('excash.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCategory (
        ${CategoryFields.id_category} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${CategoryFields.name_category} TEXT NOT NULL,
        ${CategoryFields.created_at_category} TEXT NOT NULL,
        ${CategoryFields.updated_at_category} TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableProduct (
        ${ProductFields.id_product} TEXT PRIMARY KEY,
        ${ProductFields.id_category} INTEGER NOT NULL,
        ${ProductFields.name_product} TEXT NOT NULL,
        ${ProductFields.price} INTEGER NOT NULL,
        ${ProductFields.selling_price} INTEGER NOT NULL,
        ${ProductFields.stock} INTEGER NOT NULL,
        ${ProductFields.description} TEXT NOT NULL,
        ${ProductFields.created_at} TEXT NOT NULL,
        ${ProductFields.updated_at} TEXT NOT NULL,
        FOREIGN KEY (${ProductFields.id_category}) REFERENCES $tableCategory(${CategoryFields.id_category})
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableUser (
        ${UserFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${UserFields.email} TEXT UNIQUE NOT NULL,
        ${UserFields.fullName} TEXT NOT NULL,
        ${UserFields.businessName} TEXT NOT NULL,
        ${UserFields.password} TEXT NOT NULL,
        ${UserFields.image} TEXT NULL
      )
    ''');

        await db.execute('''
      CREATE TABLE "order" (
        id_order INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user INTEGER NOT NULL,
        total_product INTEGER NOT NULL,
        total_price INTEGER NOT NULL,
        diskon_type BOOLEAN NOT NULL,
        diskon_value INTEGER NOT NULL,
        payment INTEGER NOT NULL,
        change INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (id_user) REFERENCES user(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE order_detail (
        id_order_detail INTEGER PRIMARY KEY AUTOINCREMENT,
        id_order INTEGER NOT NULL,
        id_product TEXT NOT NULL,
        amount INTEGER NOT NULL,
        subtotal INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (id_order) REFERENCES "order"(id_order),
        FOREIGN KEY (id_product) REFERENCES product(id_product)
      )
    ''');
  }

  //CATEGORY
  Future<Category> create(Category category) async {
    final db = await instance.database;
    final id = await db.insert(
      tableCategory,
      {
        CategoryFields.name_category: category.name_category,
        CategoryFields.created_at_category:
            category.created_at_category.toIso8601String(),
        CategoryFields.updated_at_category:
            category.updated_at_category.toIso8601String(),
      },
    );
    return category.copy(id_category: id);
  }

  Future<List<Category>> getAllCategory() async {
    final db = await instance.database;
    final result = await db.query(tableCategory);
    return result.map((json) => Category.fromJson(json)).toList();
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await instance.database;
    final result = await db.query(tableCategory,
        where: '${CategoryFields.id_category} = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return Category.fromJson(result.first);
    } else {
      return null;
    }
  }

  Future<int> updateCategory(Category category) async {
    final db = await instance.database;
    return await db.update(
      tableCategory,
      {
        CategoryFields.name_category: category.name_category,
        CategoryFields.updated_at_category: DateTime.now().toIso8601String(),
      },
      where: '${CategoryFields.id_category} = ?',
      whereArgs: [category.id_category],
    );
  }

  Future<int> deleteCategoryById(int id) async {
    final db = await instance.database;
    return await db.delete(tableCategory,
        where: '${CategoryFields.id_category} = ?', whereArgs: [id]);
  }

  //PRODUCT
  // PRODUCT CRUD
  Future<Product> createProduct(Product product) async {
    final db = await instance.database;
    final newProduct = product.copy(
      created_at: product.created_at ?? DateTime.now(),
      updated_at: product.updated_at ?? DateTime.now(),
    );

    // 🔹 Debug: Cek sebelum insert
    print("Menyimpan Produk:");
    print("Nama: ${newProduct.name_product}");
    print("ID Kategori: ${newProduct.id_category}");

    await db.insert(tableProduct, newProduct.toJson());
    return newProduct;
  }

  Future<void> loadProducts() async {
    final dbProducts = await ExcashDatabase.instance.getAllProducts();
    print("🔹 Produk dari DB:");
    for (var p in dbProducts) {
      print("Nama: ${p.name_product}, ID Kategori: ${p.id_category}");
    }
  }

  // Future<Product> createProduct(Product product) async {
  //   final db = await instance.database;
  //   final newProduct = product.copy(
  //     created_at: product.created_at ?? DateTime.now(),
  //     updated_at: product.updated_at ?? DateTime.now(),
  //   );
  //   await db.insert(tableProduct, newProduct.toJson());
  //   print("Simpan Produk: Nama = ${product.name_product}, ID Kategori = ${product.id_category}");

  //   return newProduct;
  // }

  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;
    final result = await db.query(tableProduct);
    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product?> getProductById(String id) async {
    final db = await instance.database;
    final result = await db.query(tableProduct,
        where: '${ProductFields.id_product} = ?', whereArgs: [id]);
    return result.isNotEmpty ? Product.fromJson(result.first) : null;
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    final updatedProduct = product.copy(updated_at: DateTime.now());
    return await db.update(
      tableProduct,
      updatedProduct.toJson(),
      where: '${ProductFields.id_product} = ?',
      whereArgs: [product.id_product],
    );
  }

  Future<int> deleteProductById(int id) async {
    final db = await instance.database;
    return await db.delete(
      'product',
      where: 'id_product = ?',
      whereArgs: [id],
    );
  }

  // 🔹 REGISTER USER
  Future<int> registerUser(User user) async {
    final db = await instance.database;

    // Cek apakah email sudah terdaftar
    final existingUser = await db.query(
      tableUser,
      where: '${UserFields.email} = ?',
      whereArgs: [user.email],
    );

    if (existingUser.isNotEmpty) {
      throw Exception("Email sudah digunakan");
    }

    return await db.insert(tableUser, user.toJson());
  }

  // 🔹 LOGIN USER
  Future<User?> loginUser(String email, String password) async {
    final db = await instance.database;

    final result = await db.query(
      tableUser,
      where: '${UserFields.email} = ? AND ${UserFields.password} = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return User.fromJson(result.first);
    } else {
      return null;
    }
  }

  Future<User?> getUserById(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableUser,
      columns: [
        UserFields.id,
        UserFields.email,
        UserFields.fullName,
        UserFields.businessName,
        UserFields.password,
        UserFields.image,
      ],
      where: '${UserFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;

    return db.update(
      tableUser,
      user.toJson(),
      where: '${UserFields.id} = ?',
      whereArgs: [user.id],
    );
  }



//CREATE ORDER
Future<int> createOrderTransaction(Order order, List<OrderDetail> orderDetails) async {
  final db = await instance.database;

  return await db.transaction((txn) async {
    // Simpan order ke tabel order
    final orderId = await txn.insert(tableOrder, order.toJson());

    // Simpan setiap item ke tabel order_detail
    for (var detail in orderDetails) {
      final newDetail = detail.copy(id_order: orderId);
      await txn.insert(tableOrderDetail, newDetail.toJson());

      // Update stok produk
      final product = await getProductById(detail.id_product);
      if (product != null) {
        final newStock = product.stock - detail.amount;
        if (newStock < 0) {
          throw Exception("Stok tidak mencukupi untuk produk ${product.name_product}");
        }
        await txn.update(
          tableProduct,
          {ProductFields.stock: newStock},
          where: "${ProductFields.id_product} = ?",
          whereArgs: [detail.id_product],
        );
      }
    }
    return orderId;
  });
}
  // Future<int> deleteProductById(int id) async {
  //   final db = await instance.database;

  //   // 1️⃣ Ambil informasi produk terlebih dahulu sebelum dihapus
  //   final product = await getProductById(id.toString());

  //   if (product != null && product.image_product != null && product.image_product!.isNotEmpty) {
  //     try {
  //       final file = File(product.image_product!);
  //       if (await file.exists()) {
  //         await file.delete(); // Hapus file dari penyimpanan
  //         print("✅ Gambar dihapus: ${product.image_product}");
  //       }
  //     } catch (e) {
  //       print("❌ Gagal menghapus gambar: $e");
  //     }
  //   }

  //   // 2️⃣ Hapus produk dari database
  //   return await db.delete(
  //     'product',
  //     where: 'id_product = ?',
  //     whereArgs: [id],
  //   );
  // }

  getAllTransactions() {}
}
//   Future<int> deleteProductById(String id) async {
//     final db = await instance.database;
//     return await db.delete(tableProduct, where: '${ProductFields.id_product} = ?', whereArgs: [id]);
//   }
// }


//   Future<Product> createProduct(Product product) async {
//     final db = await instance.database;
//     await db.insert(tableProduct, product.toJson());
//     return product;
//   }

//   Future<List<Product>> getAllProducts() async {
//     final db = await instance.database;
//     final result = await db.query(tableProduct);
//     return result.map((json) => Product.fromJson(json)).toList();
//   }

//   Future<Product?> getProductById(String id) async {
//     final db = await instance.database;
//     final result = await db.query(tableProduct, where: '${ProductFields.id_product} = ?', whereArgs: [id]);
//     return result.isNotEmpty ? Product.fromJson(result.first) : null;
//   }

//   Future<int> updateProduct(Product product) async {
//     final db = await instance.database;
//     return await db.update(
//       tableProduct,
//       product.toJson(),
//       where: '${ProductFields.id_product} = ?',
//       whereArgs: [product.id_product],
//     );
//   }

//   Future<int> deleteProductById(String id) async {
//     final db = await instance.database;
//     return await db.delete(tableProduct, where: '${ProductFields.id_product} = ?', whereArgs: [id]);
//   }
// }

