const String tableUser = 'users';

class UserFields {
  static const String id = 'id';
  static const String username = 'username';
  static const String fullName = 'full_name';
  static const String businessName = 'business_name';
  static const String password = 'password';
  static const String image = 'image';
  static const String businessAddress = 'business_address';
  static const String npwp = 'npwp';
  static const String phoneNumber = 'phone_number';
}

class User {
  final String? id;
  final String username;
  final String fullName;
  final String businessName;
  final String password;
  final String? image;
  final String businessAddress;
  final String? npwp;
  final String phoneNumber;

  User({
    this.id,
    required this.username,
    required this.fullName,
    required this.businessName,
    required this.password,
    this.image,
    required this.businessAddress,
    this.npwp,
    required this.phoneNumber,
  });

  User copy({
    String? id,
    String? username,
    String? fullName,
    String? businessName,
    String? password,
    String? image,
    String? businessAddress,
    String? npwp,
    String? phoneNumber,
  }) =>
      User(
        id: id ?? this.id,
        username: username ?? this.username,
        fullName: fullName ?? this.fullName,
        businessName: businessName ?? this.businessName,
        password: password ?? this.password,
        image: image ?? this.image,
        businessAddress: businessAddress ?? this.businessAddress,
        npwp: npwp ?? this.npwp,
        phoneNumber: phoneNumber ?? this.phoneNumber,
      );

  static User fromJson(Map<String, Object?> json) => User(
        id: json[UserFields.id] as String?,
        username: json[UserFields.username] as String,
        fullName: json[UserFields.fullName] as String,
        businessName: json[UserFields.businessName] as String,
        password: json[UserFields.password] as String,
        image: json[UserFields.image] as String?,
        businessAddress: json[UserFields.businessAddress] as String,
        npwp: json[UserFields.npwp] as String?,
        phoneNumber: json[UserFields.phoneNumber] as String,
      );

  Map<String, Object?> toJson() => {
        UserFields.id: id,
        UserFields.username: username,
        UserFields.fullName: fullName,
        UserFields.businessName: businessName,
        UserFields.password: password,
        UserFields.image: image,
        UserFields.businessAddress: businessAddress,
        UserFields.npwp: npwp,
        UserFields.phoneNumber: phoneNumber,
      };
}
