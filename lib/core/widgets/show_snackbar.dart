import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/colors.dart';

extension SnackbarExtensions on BuildContext {
  void showSuccessSnackbar(String? msg) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: ColorsManager.success500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(4),
        content: Text(msg ?? ''),
      ),
    );
  }

  void showErrorSnackbar(String? msg) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: ColorsManager.errorColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(4),
        content: Text(msg ?? ''),
      ),
    );
  }
}
