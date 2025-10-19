import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mushtary/core/enums/otp_case.dart';

part 'otp_screen_args.g.dart';

@JsonSerializable(createToJson: true, createFactory: true)
class OtpScreenArgs {
  final String phoneNumber;
  final OtpCase otpCase;

  OtpScreenArgs({required this.phoneNumber, required this.otpCase});
}
