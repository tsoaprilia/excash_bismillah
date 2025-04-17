import 'dart:convert';

const String tableCategory = 'category';

class CategoryFields{
  static const String id_category = 'id_category';
  static const String id = 'id';
  static const String name_category = 'name_category';
  static const String created_at_category = 'created_at_category';
  static const String updated_at_category ='updated_at_category';
 
}

  class Category {
  final int? id_category;
  final String id;
  final String name_category;
  final DateTime created_at_category;
  final DateTime updated_at_category;


  Category({
    this.id_category,
    required this.id,
    required this.name_category,
    required this.created_at_category,
    required this.updated_at_category,
  });

  Category copy({
    int? id_category,
    String? id,
    String? name_category,
    DateTime? created_at_category,
    DateTime? updated_at_category,
  }) {
    return Category(
      id_category: id_category ?? this.id_category,
       id: id ?? this.id,
      name_category: name_category ?? this.name_category,
      created_at_category: created_at_category ?? this.created_at_category,
      updated_at_category: updated_at_category ?? this.updated_at_category,
    );
  }
  static Category fromJson(Map<String, Object?> Json){
    return Category(
      id_category: Json[CategoryFields.id_category] as int?,
      id: Json[CategoryFields.id] as String,
      name_category: Json[CategoryFields.name_category] as String,
      created_at_category: DateTime.parse(Json[CategoryFields.created_at_category] as String),
      updated_at_category: DateTime.parse(Json[CategoryFields.updated_at_category] as String),
    );
  }

  Map<String, Object?> toJson() =>{
    CategoryFields.id_category:id_category,
        CategoryFields.id: id, 
    CategoryFields.name_category:name_category,
    CategoryFields.created_at_category: created_at_category.toIso8601String(),
    CategoryFields.updated_at_category: updated_at_category.toIso8601String(),
  };
}