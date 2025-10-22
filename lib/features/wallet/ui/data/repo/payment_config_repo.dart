import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart' as core;
import 'myfatoorah_service.dart';

class PaymentConfigRepo {
  final core.ApiService _api;
  PaymentConfigRepo(this._api);

  Future<MFAppConfig> fetchMyFatoorahConfig() async {

    final dynamic res = await _api.get(ApiConstants.myFatoorahConfig);
    final map = (res is Map<String, dynamic>) ? res : <String, dynamic>{};

    final baseUrl = (map['base_url'] ?? map['baseUrl'] ?? 'https://apitest.myfatoorah.com').toString();
    final token = (map['token'] ?? map['api_token'] ?? '').toString();
    final languageCode = (map['language'] ?? 'ar').toString();

    if (token.isEmpty) {
      throw Exception('لم يتم استلام رمز MyFatoorah من الخادم');
    }

    return MFAppConfig(
      baseUrl: baseUrl,
      token: token,
      languageCode: languageCode,
    );
  }
}