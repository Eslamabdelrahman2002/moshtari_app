import 'package:flutter/material.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

class MFAppConfig {
  final String baseUrl;      // مثال: https://apitest.myfatoorah.com أو https://api.myfatoorah.com
  final String token;        // MyFatoorah API Token (يفضل من السيرفر)
  final String languageCode; // 'ar' أو 'en'

  const MFAppConfig({
    required this.baseUrl,
    required this.token,
    this.languageCode = 'ar',
  });
}

class MyFatoorahService {
  static bool _inited = false;
  static bool get isInited => _inited;

  static late MFAppConfig _cfg;

  // نسختك من الحزمة تتوقع 3 باراميترات في init: (baseUrl, token, languageCode)
  static Future<void> init(MFAppConfig cfg) async {
    _cfg = cfg;
    MFSDK.init(cfg.baseUrl, cfg.token, cfg.languageCode);
    _inited = true;
  }

  // تشغيل الدفع: paymentMethodId = 0 يعرض كل الطرق المتاحة (Apple Pay / Mada / Visa ... حسب التفعيل)
  static Future<dynamic> pay({
    required BuildContext context, // غير مستخدم في نسختك، لكن نتركه في التوقيع
    required double amount,
  }) async {
    if (!_inited) {
      throw Exception('MyFatoorahService لم يتم تهيئته بعد.');
    }

    // بعض النسخ تدعم named params، لو ظهر خطأ غيّرها إلى MFExecutePaymentRequest(0, amount)
    final req = MFExecutePaymentRequest(paymentMethodId: 0, invoiceValue: amount);

    String? createdInvoiceId;

    // نسختك تتوقع 3 باراميترات فقط
    final result = await MFSDK.executePayment(
      req,
      _cfg.languageCode,
          (String invoiceId) {
        createdInvoiceId = invoiceId;
      },
    );

    // result يحمل نتيجة الدفع (النوع قد يختلف حسب النسخة)، لذلك نعيده كـ dynamic
    return result;
  }
}