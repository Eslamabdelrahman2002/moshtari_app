class AppRegex {
  // email validation regex
  static bool isEmailValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  // phone validation regex
  static bool isPhoneValid(String phone) {
    return RegExp(r"^(?:[+0]9)?[0-9]{9,12}$").hasMatch(phone);
  }

  // password validation regex
  static bool isPasswordValid(String password) {
    return RegExp(
            r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$")
        .hasMatch(password);
  }

  static RegExp numbersRegex = RegExp(r'[0-9]');

  // link validation regex
  static bool isLinkValid(String link) {
    return RegExp(
            r"^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}")
        .hasMatch(link);
  }
}
