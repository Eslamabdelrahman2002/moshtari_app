// Request Body Model
class LoginRequestBody {
  final String phoneNumber;
  LoginRequestBody({required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
    };
  }
}

// Data class for the nested "data" object in the response
class LoginData {
  final String? token;
  // You can add other user properties here if your API sends them
  // final UserModel? user;

  LoginData({this.token});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      // It will look for either 'token' or 'access_token' from the API
      token: json['token'] ?? json['access_token'],
    );
  }
}

// Response Model
class LoginResponse {
  final String? message;
  final LoginData? data;

  LoginResponse({this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'],
      // Correctly parses the nested 'data' object
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }
}