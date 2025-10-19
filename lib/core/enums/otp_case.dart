enum OtpCase {
  login('PHONE_VERIFICATION_FOR_LOGIN'),
  verification('PHONE_VERIFICATION'),
  resetPassword('PASSWORD_RESET'),
  email('EMAIL_VERIFICATION'),
  socialEmail('SOCIAL_EMAIL_VERIFICATION'),
  changeEmail('CHANGE_EMAIL'),
  changePhone('CHANGE_PHONE');

  final String value;

  const OtpCase(this.value);
}
