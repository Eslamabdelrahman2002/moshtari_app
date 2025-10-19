class ResetPasswordRequestBody {
  final String phoneNumber;
  final String otp;
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequestBody({
    required this.phoneNumber,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'otp': otp,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}

class ResetPasswordResponse {
  final String? message;

  ResetPasswordResponse({this.message});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      message: json['message'],
    );
  }
}
