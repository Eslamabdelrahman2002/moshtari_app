import 'package:flutter/material.dart';

@immutable
abstract class OtpState {}

class OtpInitial extends OtpState {}

// Verification States
class OtpVerificationLoading extends OtpState {}
class OtpVerificationSuccess extends OtpState {
  final String message;
  final String otp;

  // ✨ FIX: Corrected constructor to use named parameters
  OtpVerificationSuccess(this.message, this.otp);
}
class OtpVerificationError extends OtpState {
  final String error;
  OtpVerificationError(this.error);
}

// Resend States
class ResendOtpLoading extends OtpState {}
class ResendOtpSuccess extends OtpState {
  final String message;
  ResendOtpSuccess(this.message);
}
class ResendOtpError extends OtpState {
  final String error;
  ResendOtpError(this.error);
}