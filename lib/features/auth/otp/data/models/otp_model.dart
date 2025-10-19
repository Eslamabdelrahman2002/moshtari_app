class VerifyOtpRequestBody {
  final String phoneNumber;
  final String otp;

  VerifyOtpRequestBody({required this.phoneNumber, required this.otp});

  Map<String, dynamic> toJson() {
    return {'phone_number': phoneNumber, 'otp': otp};
  }
}

class ResendOtpRequestBody {
  final String phoneNumber;
  ResendOtpRequestBody({required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {'phone_number': phoneNumber};
  }
}

// ✨ FIX: Updated the OtpResponse model to match your API
class OtpResponse {
  final String? message;
  final String? token; // Token is at the top level
  final UserData? data;

  OtpResponse({this.message, this.token, this.data});

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      message: json['message'],
      token: json['token'], // Parse the token from the root
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }
}

// ✨ ADDED: A new class to handle the nested 'data' object
class UserData {
  final int? userId;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final bool? isActive;

  UserData({
    this.userId,
    this.username,
    this.email,
    this.phoneNumber,
    this.isActive,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      isActive: json['is_active'],
    );
  }
}