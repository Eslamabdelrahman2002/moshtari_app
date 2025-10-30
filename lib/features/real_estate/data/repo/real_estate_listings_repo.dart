// file: real_estate_listings_repo.dart

import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/app_exception.dart';
// import 'package:mushtary/features/real_estate/data/model/real_estate_listing_item.dart'; // ❌ تم إزالة الاستيراد
import 'package:mushtary/features/real_estate/data/model/real_estate_ad_model.dart'; // ✅ افتراض أن هذا هو RealEstateListModel
import 'package:mushtary/features/real_estate/data/model/real_estate_listings_filter.dart';

class RealEstateListingsRepo {
  final ApiService _api;
  RealEstateListingsRepo(this._api);

  // ✅ FIX: تغيير نوع الإرجاع المتوقع في الريبو
  Future<List<RealEstateListModel>> getListings(RealEstateListingsFilter f) async {
    try {
      final res = await _api.get(
        ApiConstants.realEstateListings,
        queryParameters: f.toQuery(),
      );
      if (res is! Map || res['data'] is! List) {
        throw AppException('Unexpected response shape');
      }
      final List data = res['data'];

      // ✅ FIX: التحويل إلى RealEstateListModel (افتراضياً)
      return data
          .map((e) => RealEstateListModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

    } catch (e) {
      throw AppException('Failed to load listings: $e');
    }
  }
}