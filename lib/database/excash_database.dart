import 'dart:convert';
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
  CREATE TABLE $tableOrders ( 
      ${OrderFields.id_order} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${OrderFields.id} INTEGER NOT NULL,
      ${OrderFields.total_product} INTEGER NOT NULL,
      ${OrderFields.total_price} INTEGER NOT NULL,
      ${OrderFields.payment} INTEGER NOT NULL,
      ${OrderFields.change} INTEGER NOT NULL,
      ${OrderFields.created_at} TEXT NOT NULL,
      FOREIGN KEY (${OrderFields.id}) REFERENCES $tableUser(${UserFields.id})
    )
''');

    await db.execute(''' 
  CREATE TABLE $tableOrderDetail (
    ${OrderDetailFields.id_order_detail} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${OrderDetailFields.id_order} INTEGER NOT NULL,
    ${OrderDetailFields.id_product} TEXT NOT NULL,
    ${OrderDetailFields.quantity} INTEGER NOT NULL,
    ${OrderDetailFields.price} REAL NOT NULL,
    ${OrderDetailFields.subtotal} REAL NOT NULL,
    FOREIGN KEY (${OrderDetailFields.id_order}) REFERENCES $tableOrders(${OrderFields.id_order}) ON DELETE CASCADE,
    FOREIGN KEY (${OrderDetailFields.id_product}) REFERENCES $tableProduct(${ProductFields.id_product})
  )
''');

    List<Map> tables =
        await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
    print(tables); // Ini akan menampilkan semua tabel yang ada di database
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

  Future<List<Product>> getProductsByCategory(int? categoryId) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result;

    if (categoryId == null || categoryId == 0) {
      result = await db.query(tableProduct);
    } else {
      result = await db.query(
        tableProduct,
        where: '${ProductFields.id_category} = ?',
        whereArgs: [categoryId],
      );
    }

    return result.map((json) => Product.fromJson(json)).toList();
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

  Future<int> deleteProductById(String id) async {
    final db = await instance.database;
    return await db.delete(
      'product',
      where: '${ProductFields.id_product} = ?',
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

//ORDER

  Future<int> createOrder(Order order, List<OrderDetail> orderDetails) async {
    final db = await instance.database;

    // Dapatkan user yang sedang login
    User? currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception("User belum login");
    }
    int currentUserId = currentUser.id!;

    int orderId = -1;

    // Mulai transaksi
    await db.transaction((txn) async {
      // Gunakan total_price dari objek order yang diterima
      int totalPrice =
          order.total_price; // Gunakan total_price yang dikirim dari UI

      // Simpan data order ke tabel Order
      orderId = await txn.insert(tableOrders, {
        OrderFields.id: currentUserId, // ID user yang membuat order
        OrderFields.total_product: order.total_product,
        OrderFields.total_price:
            totalPrice, // Gunakan total_price yang diterima
        OrderFields.payment: order.payment,
        OrderFields.change: order.change,
        OrderFields.created_at: order.created_at.toIso8601String(),
      });

      print("Order inserted with total_price: ${order.total_price}");

      // Loop untuk menyimpan setiap detail order
      for (var detail in orderDetails) {
        // Hitung subtotal untuk setiap order detail
        double subtotal = detail.quantity * detail.price;

        // Ambil stok saat ini dari database
        List<Map<String, dynamic>> stockResult = await txn.query(
          tableProduct,
          columns: [ProductFields.stock],
          where: '${ProductFields.id_product} = ?',
          whereArgs: [detail.id_product],
        );

        if (stockResult.isNotEmpty) {
          int currentStock = stockResult[0][ProductFields.stock];

          // Cek apakah stok mencukupi
          if (currentStock < detail.quantity) {
            throw Exception(
                "Stok tidak mencukupi untuk produk ${detail.id_product}");
          }

          // Simpan detail order ke tabel OrderDetail (termasuk subtotal)
          await txn.insert(tableOrderDetail, {
            OrderDetailFields.id_order: orderId,
            OrderDetailFields.id_product: detail.id_product,
            OrderDetailFields.quantity: detail.quantity,
            OrderDetailFields.price: detail.price,
            OrderDetailFields.subtotal:
                subtotal, // Menyimpan subtotal yang dihitung
          });

          // Kurangi stok produk setelah berhasil menambahkan ke OrderDetail
          await txn.update(
            tableProduct,
            {ProductFields.stock: currentStock - detail.quantity},
            where: '${ProductFields.id_product} = ?',
            whereArgs: [detail.id_product],
          );
        } else {
          throw Exception(
              "Produk dengan ID ${detail.id_product} tidak ditemukan.");
        }
      }
    });

    return orderId;
  }

  Future<List<Map<String, dynamic>>> debugOrders() async {
    final db = await database;
    return await db.query('order');
  }

  Future<List<Map<String, dynamic>>> debugOrderDetails(int orderId) async {
    final db = await database;
    return await db
        .query('order_detail', where: 'id_order = ?', whereArgs: [orderId]);
  }

  Future<int> createOrderDetail(
    int orderId,
    int productId,
    int quantity,
    double price,
    double subtotal, // Add subtotal as a parameter
  ) async {
    final db = await instance.database;
    return await db.insert('order_detail', {
      'id_order': orderId,
      'id_product': productId,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal, // Store subtotal in the database
    });
  }

// Get Order by ID
  Future<Order> getOrderById(int orderId) async {
    final db = await instance.database;
    final result = await db.query(
      'orders',
      where: 'id_order = ?',
      whereArgs: [orderId],
    );

    print(
        "Result from getOrder: ${jsonEncode(result)}"); // Lebih rapi untuk debugging

    if (result.isNotEmpty) {
      return Order.fromJson(result.first);
    } else {
      throw Exception("Order not found");
    }
  }

  // Get Order Details by Order ID
  // Future<List<OrderDetail>> getOrderDetails(int orderId) async {
  //   final db = await instance.database;
  //   final result = await db.query(
  //     'order_details',
  //     where: 'id_order = ?',
  //     whereArgs: [orderId],
  //   );
  //   return result.map((json) => OrderDetail.fromJson(json)).toList();
  // }

  Future<List<Order>> getAllOrders() async {
    final db = await instance.database;
    final result =
        await db.query(tableOrders, orderBy: '${OrderFields.created_at} DESC');
    return result.map((json) => Order.fromJson(json)).toList();
  }

  // Future<List<OrderDetail>> getOrderDetails(int orderId) async {
  //   final db = await instance.database;
  //   final result = await db.query(
  //     tableOrderDetail,
  //     where: '${OrderDetailFields.id_order} = ?',
  //     whereArgs: [orderId],
  //   );
  //   return result.map((json) => OrderDetail.fromJson(json)).toList();
  // }

  Future<void> updateProductStock(int productId, int newStock) async {
    final db = await instance.database;
    await db.update(
      tableProduct,
      {'stock': newStock},
      where: 'id_product = ?',
      whereArgs: [productId],
    );
  }

// Di dalam kelas ExcashDatabase
  Future<List<OrderDetail>> getOrderDetails(int orderId) async {
    final db = await instance.database;
    final result = await db.query(
      tableOrderDetail, // Pastikan nama tabel sesuai dengan yang ada di database
      where: '${OrderDetailFields.id_order} = ?',
      whereArgs: [orderId],
    );

    print("Result from getOrderDetails: $result"); // Debugging query result
    return result.map((json) => OrderDetail.fromJson(json)).toList();
  }

  Future<User?> getCurrentUser() async {
    final db = await instance.database;

    final maps = await db.query(
      tableUser,
      limit: 1, // Ambil user pertama
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first); // Pakai fromJson()
    }
    return null;
  }

  Future<List<Order>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query(
      tableOrders,
      orderBy: '${OrderFields.created_at} DESC',
    );
    return result.map((json) => Order.fromJson(json)).toList();
  }
}
