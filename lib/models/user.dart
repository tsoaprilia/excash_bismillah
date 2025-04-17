const String tableUser = 'users';

class UserFields {
  static const String id = 'id';
  static const String email = 'email';
  static const String fullName = 'full_name';
  static const String businessName = 'business_name';
  static const String password = 'password';
  static const String image = 'image';
}

class User {
  final String? id;
  final String email;
  final String fullName;
  final String businessName;
  final String password;
  final String? image;

  User({
    this.id,
    required this.email,
    required this.fullName,
    required this.businessName,
    required this.password,
    this.image,
  });

  User copy({
    String? id,
    String? email,
    String? fullName,
    String? businessName,
    String? password,
    String? image,
    
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        fullName: fullName ?? this.fullName,
        businessName: businessName ?? this.businessName,
        password: password ?? this.password,
        image: image ?? this.image,
      );

  static User fromJson(Map<String, Object?> json) => User(
        id: json[UserFields.id] as String?,
        email: json[UserFields.email] as String,
        fullName: json[UserFields.fullName] as String,
        businessName: json[UserFields.businessName] as String,
        password: json[UserFields.password] as String,
        image: json[UserFields.image] as String?,
      );

  Map<String, Object?> toJson() => {
        UserFields.id: id,
        UserFields.email: email,
        UserFields.fullName: fullName,
        UserFields.businessName: businessName,
        UserFields.password: password,
        UserFields.image: image,
      };
}
