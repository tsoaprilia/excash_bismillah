import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/models/log.dart';
import 'package:excash/models/order.dart';
import 'package:excash/models/order_detail.dart';
import 'package:excash/models/product.dart';
import 'package:excash/models/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

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
      CREATE TABLE $tableUser (
        ${UserFields.id} TEXT PRIMARY KEY,
        ${UserFields.email} TEXT UNIQUE NOT NULL,
        ${UserFields.fullName} TEXT NOT NULL,
        ${UserFields.businessName} TEXT NOT NULL,
        ${UserFields.password} TEXT NOT NULL,
        ${UserFields.image} TEXT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCategory (
        ${CategoryFields.id_category} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${CategoryFields.id} TEXT,
        ${CategoryFields.name_category} TEXT NOT NULL,
        ${CategoryFields.created_at_category} TEXT NOT NULL,
        ${CategoryFields.updated_at_category} TEXT,
        FOREIGN KEY (${CategoryFields.id}) REFERENCES $tableUser(${UserFields.id}) ON DELETE CASCADE

      )
    ''');

    await db.execute('''
      CREATE TABLE $tableProduct (
        ${ProductFields.id_product} TEXT PRIMARY KEY,
        ${CategoryFields.id} TEXT,
        ${ProductFields.id_category} INTEGER NOT NULL,
        ${ProductFields.name_product} TEXT NOT NULL,
        ${ProductFields.price} INTEGER NOT NULL,
        ${ProductFields.selling_price} INTEGER NOT NULL,
        ${ProductFields.stock} INTEGER NOT NULL,
        ${ProductFields.description} TEXT NOT NULL,
        ${ProductFields.created_at} TEXT NOT NULL,
        ${ProductFields.updated_at} TEXT NOT NULL,
        FOREIGN KEY (${CategoryFields.id}) REFERENCES $tableUser(${UserFields.id}) ON DELETE CASCADE,
        FOREIGN KEY (${ProductFields.id_category}) REFERENCES $tableCategory(${CategoryFields.id_category}) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
  CREATE TABLE $tableOrders ( 
      ${OrderFields.id_order} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${OrderFields.id} TEXT NOT NULL,
      ${OrderFields.total_product} INTEGER NOT NULL,
      ${OrderFields.total_price} INTEGER NOT NULL,
      ${OrderFields.payment} INTEGER NOT NULL,
      ${OrderFields.change} INTEGER NOT NULL,
      ${OrderFields.created_at} TEXT NOT NULL,
      FOREIGN KEY (${OrderFields.id}) REFERENCES $tableUser(${UserFields.id}) ON DELETE CASCADE
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
    FOREIGN KEY (${OrderDetailFields.id_product}) REFERENCES $tableProduct(${ProductFields.id_product}) ON DELETE CASCADE
  )
''');

    await db.execute('''
  CREATE TABLE $tableLogActivity (
    ${LogActivityFields.id_log} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${LogActivityFields.date} TEXT NOT NULL,
    ${LogActivityFields.type} TEXT NOT NULL,
    ${LogActivityFields.user} TEXT NOT NULL,
    ${LogActivityFields.email} TEXT NOT NULL,
    ${LogActivityFields.operation} TEXT NOT NULL,
    ${LogActivityFields.oldValue} TEXT,
    ${LogActivityFields.newValue} TEXT
  )
''');

    List<Map> tables =
        await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
    print(tables);
    // Ini akan menampilkan semua tabel yang ada di database
  }

  //CATEGORY
  Future<Category> create(Category category) async {
    final db = await instance.database;

    // Mendapatkan data pengguna yang sedang login
    User? currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception("User belum login");
    }

    // ID kategori sekarang menggunakan ID pengguna yang sedang login
    final userId = currentUser.id!;

    // Menyimpan kategori ke dalam database dengan ID pengguna yang sedang login
    final id = await db.insert(
      tableCategory,
      {
        CategoryFields.id: userId, // Menggunakan ID user sebagai ID kategori
        CategoryFields.name_category: category.name_category,
        CategoryFields.created_at_category:
            category.created_at_category.toIso8601String(),
        CategoryFields.updated_at_category:
            category.updated_at_category.toIso8601String(),
      },
    );

    // Log aktivitas
    await logActivity(
        "add", currentUser.email, currentUser.fullName, "Category");

    // Mengembalikan kategori yang telah dibuat dengan ID yang baru
    return category.copy(id_category: id, id: userId);
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

    // Melakukan update kategori ke dalam database
    int result = await db.update(
      tableCategory,
      {
        CategoryFields.name_category: category.name_category,
        CategoryFields.updated_at_category: DateTime.now().toIso8601String(),
      },
      where: '${CategoryFields.id_category} = ?',
      whereArgs: [category.id_category],
    );

    // Mendapatkan user yang sedang login untuk mencatat aktivitas
    User? currentUser = await getCurrentUser();
    if (currentUser != null) {
      // Menambahkan log aktivitas untuk operasi "edit"
      await logActivity(
          "edit", currentUser.email, currentUser.fullName, "category");
    }

    return result;
  }

  Future<int> deleteCategoryById(int id) async {
    final db = await instance.database;

    // Mendapatkan kategori yang akan dihapus untuk log aktivitas
    final category = await getCategoryById(id);

    if (category != null) {
      // Menghapus kategori dari tabel
      int result = await db.delete(
        tableCategory,
        where: '${CategoryFields.id_category} = ?',
        whereArgs: [id],
      );

      // Mendapatkan user yang sedang login
      User? currentUser = await getCurrentUser();
      if (currentUser != null) {
        // Menambahkan log aktivitas untuk operasi "delete"
        await logActivity(
            "delete", currentUser.email, currentUser.fullName, "category");
      }

      return result;
    }

    return 0; // Kategori tidak ditemukan
  }

  // PRODUCT CRUD
  Future<Product> createProduct(Product product) async {
    final db = await instance.database;

    // Dapatkan user yang sedang login
    User? currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception("User belum login");
    }

    // Tambahkan ID User ke produk
    final newProduct = product.copy(
      id: currentUser.id!,
      created_at: product.created_at ?? DateTime.now(),
      updated_at: product.updated_at ?? DateTime.now(),
    );

    // 🔹 Debug: Cek sebelum insert
    print("Menyimpan Produk:");
    print("Nama: ${newProduct.name_product}");
    print("ID Kategori: ${newProduct.id_category}");

    await db.insert(tableProduct, newProduct.toJson());

    // Log aktivitas
    await logActivity(
        "add", currentUser.email, currentUser.fullName, "product");

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

    // Convert the result to Product objects
    return result.map((json) {
      return Product.fromJson(
          json); // Ensure 'stock' is correctly handled as an int in 'Product.fromJson'
    }).toList();
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

    // Memeriksa apakah email sudah ada di database
    final existingUser = await db.query(
      'users', // Pastikan menggunakan nama tabel yang benar
      where: '${UserFields.email} = ?',
      whereArgs: [user.email],
    );

    // Jika sudah ada, lemparkan exception
    if (existingUser.isNotEmpty) {
      throw Exception("Email sudah digunakan");
    }

    // Membuat user baru dengan ID yang dihasilkan oleh UUID
    final newUser = user.copy(id: const Uuid().v4());

    // Menyisipkan data user baru ke dalam database
    final insertedId = await db.insert(
      'users', // Pastikan nama tabel yang benar
      newUser.toJson(),
      conflictAlgorithm: ConflictAlgorithm
          .replace, // Jika data sudah ada, ganti dengan yang baru
    );

    print(
        "User berhasil terdaftar dengan ID: $insertedId"); // Debugging: melihat ID yang baru terdaftar
    return insertedId;
  }

  // 🔹 LOGIN USER
  Future<User?> loginUser(String email, String password) async {
    final db = await instance.database;

    final result = await db.query(
      'users', // Pastikan menggunakan nama tabel yang benar
      where: '${UserFields.email} = ? AND ${UserFields.password} = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      print("User berhasil login: ${result.first}");
      return User.fromJson(result.first);
    } else {
      print("Login gagal: tidak ada user yang cocok.");
      return null;
    }
  }

  Future<User?> getUserById(String id) async {
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
    String currentUserId = currentUser.id!;

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

  Future<List<Order>> getAllOrders() async {
    final db = await instance.database;
    final result =
        await db.query(tableOrders, orderBy: '${OrderFields.created_at} DESC');
    return result.map((json) => Order.fromJson(json)).toList();
  }

  // Future<void> updateProductStock(int productId, int newStock) async {
  //   final db = await instance.database;
  //   await db.update(
  //     tableProduct,
  //     {'stock': newStock},
  //     where: 'id_product = ?',
  //     whereArgs: [productId],
  //   );
  // }
  Future<void> updateProductStock(String productId, int newStock) async {
    final db = await instance.database;

    // Pastikan stock valid dan tidak negatif
    if (newStock < 0) {
      throw Exception("Stock tidak bisa negatif");
    }

    // Update stok produk dengan id_product sebagai String
    await db.update(
      tableProduct,
      {ProductFields.stock: newStock}, // Pastikan newStock adalah integer
      where:
          '${ProductFields.id_product} = ?', // id_product tetap sebagai String
      whereArgs: [productId], // Menyertakan productId sebagai String
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

  //log
  // Example of inserting a log activity
  Future<void> logActivity(
    String type,
    String email,
    String user,
    String operation, {
    String? oldValue,
    String? newValue,
  }) async {
    final db = await instance.database;
    String? formattedOldValue;
    String? formattedNewValue;

    // Handling the 'edit', 'add', and 'delete' operations for category, product, user, etc.

    if (operation == 'category') {
      // Get the name_category from the category table
      if (type == 'edit') {
        formattedOldValue = 'Old Category Name: $oldValue';
        formattedNewValue = 'New Category Name: $newValue';
      } else if (type == 'add') {
        formattedOldValue = 'New Category Added';
        formattedNewValue = 'Category Name: $newValue';
      } else if (type == 'delete') {
        // Fetch the category name by oldValue (category id)
        var category =
            await getCategoryById2(oldValue); // oldValue is the category id
        formattedOldValue = 'Category Deleted: ${category?.name_category}';
        formattedNewValue = 'Category Name: ${category?.name_category}';
      }
    }

    if (operation == 'product') {
      // Get the name_product from the product table
      if (type == 'edit') {
        formattedOldValue = 'Old Product Name: $oldValue';
        formattedNewValue = 'New Product Name: $newValue';
      } else if (type == 'add') {
        formattedOldValue = 'New Product Added';
        formattedNewValue = 'Product Name: $newValue';
      } else if (type == 'delete') {
        // Fetch the product name by oldValue (product id)
        var product =
            await getProductById2(oldValue); // oldValue is the product id
        formattedOldValue = 'Product Deleted: ${product?.name_product}';
        formattedNewValue = 'Product Name: ${product?.name_product}';
      }
    }

    if (operation == 'user') {
      // Get the full name from the user table
      if (type == 'edit') {
        formattedOldValue = 'Old User Full Name: $oldValue';
        formattedNewValue = 'New User Full Name: $newValue';
      } else if (type == 'add') {
        formattedOldValue = 'New User Added';
        formattedNewValue = 'User Full Name: $newValue';
      } else if (type == 'delete') {
        // Fetch the user full name by oldValue (user id)
        var user = await getUserById2(oldValue); // oldValue is the user id
        formattedOldValue = 'User Deleted: ${user?.fullName}';
        formattedNewValue = 'User Full Name: ${user?.fullName}';
      }
    }

    if (operation == 'order') {
      // Handling order operations
      if (type == 'edit') {
        formattedOldValue = 'Old Order Status: $oldValue';
        formattedNewValue = 'New Order Status: $newValue';
      } else if (type == 'add') {
        formattedOldValue = 'New Order Created';
        formattedNewValue = 'Order ID: $newValue';
      } else if (type == 'delete') {
        formattedOldValue = 'Order Canceled';
        formattedNewValue = 'Order ID: $oldValue';
      }
    }

    // Insert the log data into the database
    final log = LogActivity(
      date: DateTime.now().toIso8601String(),
      type: type,
      user: user,
      email: email,
      operation: operation,
      oldValue: formattedOldValue,
      newValue: formattedNewValue,
    );

    await db.insert('log_activity', log.toJson());
  }

  Future<Category?> getCategoryById2(String? categoryId) async {
    final db = await instance.database;
    final result = await db.query(
      'category',
      where: 'id_category = ?',
      whereArgs: [categoryId],
    );
    return result.isNotEmpty ? Category.fromJson(result.first) : null;
  }

  Future<Product?> getProductById2(String? productId) async {
    final db = await instance.database;
    final result = await db.query(
      'product',
      where: 'id_product = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty ? Product.fromJson(result.first) : null;
  }

  Future<User?> getUserById2(String? userId) async {
    final db = await instance.database;
    final result = await db.query(
      'user',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? User.fromJson(result.first) : null;
  }

  Future<List<LogActivity>> getLogs() async {
    final db = await instance.database;
    final result = await db.query(tableLogActivity, orderBy: 'date DESC');

    return result.map((json) => LogActivity.fromJson(json)).toList();
  }

  Future<LogActivity> getLogById(String id) async {
    final db = await instance.database;

    final result = await db.query(
      tableLogActivity,
      where: '${LogActivityFields.id_log} = ?',
      whereArgs: [id], // Expecting a String
    );

    if (result.isNotEmpty) {
      return LogActivity.fromJson(result.first);
    } else {
      throw Exception("Log not found");
    }
  }
}
