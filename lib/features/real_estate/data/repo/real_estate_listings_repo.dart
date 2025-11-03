import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/app_exception.dart';
import 'package:mushtary/features/real_estate/data/model/real_estate_ad_model.dart';
import 'package:mushtary/features/real_estate/data/model/real_estate_listings_filter.dart';

/// Repository مسؤول عن جلب القوائم العقارية مع تطبيق الفلاتر (إعلانات / طلبات)
class RealEstateListingsRepo {
  final ApiService _api;

  RealEstateListingsRepo(this._api);
  Future<List<RealEstateListModel>> getListings(
      RealEstateListingsFilter filter,
      ) async {
    try {
      // 🛰️ استدعاء الـ API مع بارامترات الاستعلام الناتجة من toQuery()
      final response = await _api.get(
        ApiConstants.realEstateListings,
        queryParameters: filter.toQuery(),
      );

      // ✅ تأكيد أن شكل الاستجابة كما هو متوقع
      if (response is! Map<String, dynamic>) {
        throw AppException('Unexpected response format: expected JSON object');
      }

      final data = response['data'];

      if (data is! List) {
        throw AppException('Unexpected data shape: expected list in "data" key');
      }

      // 🔄 تحويل القائمة إلى List<RealEstateListModel>
      final listings = data
          .map((e) => RealEstateListModel.fromJson(
        Map<String, dynamic>.from(e as Map),
      ))
          .toList();

      return listings;

    } catch (e, st) {
      // 🧯 أي خطأ نحوله إلى AppException مع الرسالة الكاملة لتسهيل التتبع
      throw AppException('Failed to load listings: $e\n$st');
    }
  }

  /// (اختياري) جلب تفاصيل عقار واحد حسب ID
  Future<RealEstateListModel> getListingById(int id) async {
    try {
      final response = await _api.get(
        '${ApiConstants.realEstateListings}/$id',
      );

      if (response is! Map<String, dynamic> || response['data'] == null) {
        throw AppException('Invalid response format while fetching listing $id');
      }

      final map = Map<String, dynamic>.from(response['data'] as Map);
      return RealEstateListModel.fromJson(map);

    } catch (e, st) {
      throw AppException('Failed to load listing #$id: $e\n$st');
    }
  }
}