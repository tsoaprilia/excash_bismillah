import 'package:excash/models/excash.dart';
import 'package:excash/models/product.dart';
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
        ${ProductFields.image_product} TEXT,
        FOREIGN KEY (${ProductFields.id_category}) REFERENCES $tableCategory(${CategoryFields.id_category})
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
        CategoryFields.created_at_category: category.created_at_category.toIso8601String(),
        CategoryFields.updated_at_category: category.updated_at_category.toIso8601String(),
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
    final result = await db.query(tableCategory, where: '${CategoryFields.id_category} = ?', whereArgs: [id]);

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
    return await db.delete(tableCategory, where: '${CategoryFields.id_category} = ?', whereArgs: [id]);
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
    final result = await db.query(tableProduct, where: '${ProductFields.id_product} = ?', whereArgs: [id]);
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

