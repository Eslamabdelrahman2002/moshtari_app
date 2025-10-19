class RegisterRequestBody {
  final String username;
  final String email;
  final String phoneNumber;
  final String? referralCode;

  RegisterRequestBody({
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.referralCode,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
    };
    if (referralCode != null && referralCode!.isNotEmpty) {
      map['referral_code'] = referralCode!;
    }
    return map;
  }
}

class RegisterResponse {
  final String? message;
  // Add other properties from the response if needed

  RegisterResponse({this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'],
    );
  }
}
