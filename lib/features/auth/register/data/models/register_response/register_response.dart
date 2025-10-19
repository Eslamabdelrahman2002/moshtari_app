import 'data.dart';

class RegisterResponse {
  int? code;
  bool? success;
  String? message;
  Data? data;

  RegisterResponse({this.code, this.success, this.message, this.data});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        code: json['code'] as int?,
        success: json['success'] as bool?,
        message: json['message'] as String?,
        data: json['data'] == null
            ? null
            : Data.fromJson(json['data'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'success': success,
        'message': message,
        'data': data?.toJson(),
      };
}
