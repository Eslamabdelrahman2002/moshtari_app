import 'package:flutter/services.dart';
import 'package:mushtary/core/utils/helpers/regex.dart';

class AppInputFormats {
  static FilteringTextInputFormatter numbersFormat =
      FilteringTextInputFormatter.allow(AppRegex.numbersRegex);
}
