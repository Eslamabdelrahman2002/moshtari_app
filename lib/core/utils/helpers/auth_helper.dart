import 'package:flutter/material.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';

class AuthHelper {
  static bool isLoggedIn() {
    final token = CacheHelper.getData(key: 'token') as String?;
    return token != null && token.isNotEmpty;
  }

  // ترجّع true لو المستخدم مسجل بعد الرجوع من صفحة اللوجين
  static Future<bool> ensureAuthenticated(BuildContext context) async {
    if (isLoggedIn()) return true;

    // ودّي لصفحة اللوجين
    // ملاحظة: عدّل Routes.loginScreen لو اسم Route عندك مختلف
    await Navigator.pushNamed(context, Routes.loginScreen);

    // بعد الرجوع، افحص تاني
    return isLoggedIn();
  }
}