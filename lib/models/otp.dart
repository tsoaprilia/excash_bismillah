const String tableOtp = 'product';

class OtpModel {
  final int? id;
  final String fullname;
  final String otpCode;
  final int expiredAt;

  OtpModel({
    this.id,
    required this.fullname,
    required this.otpCode,
    required this.expiredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullname': fullname,
      'otp_code': otpCode,
      'expired_at': expiredAt,
    };
  }

  factory OtpModel.fromMap(Map<String, dynamic> map) {
    return OtpModel(
      id: map['id'],
      fullname: map['fullname'],
      otpCode: map['otp_code'],
      expiredAt: map['expired_at'],
    );
  }
}
