class ForgetPasswordRequestBody {
  final String phoneNumber;

  ForgetPasswordRequestBody({required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
    };
  }
}

class ForgetPasswordResponse {
  final String? message;

  ForgetPasswordResponse({this.message});

  factory ForgetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordResponse(
      message: json['message'],
    );
  }
}
