// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_screen_args.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpScreenArgs _$OtpScreenArgsFromJson(Map<String, dynamic> json) =>
    OtpScreenArgs(
      phoneNumber: json['phoneNumber'] as String,
      otpCase: $enumDecode(_$OtpCaseEnumMap, json['otpCase']),
    );

Map<String, dynamic> _$OtpScreenArgsToJson(OtpScreenArgs instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'otpCase': _$OtpCaseEnumMap[instance.otpCase]!,
    };

const _$OtpCaseEnumMap = {
  OtpCase.login: 'login',
  OtpCase.verification: 'verification',
  OtpCase.resetPassword: 'resetPassword',
  OtpCase.email: 'email',
  OtpCase.socialEmail: 'socialEmail',
  OtpCase.changeEmail: 'changeEmail',
  OtpCase.changePhone: 'changePhone',
};
