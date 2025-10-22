// lib/features/product_details/data/repo/car_parts_repo.dart
import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart';
import 'package:mushtary/core/api/app_exception.dart';
import '../model/car_part_details_model.dart';

class CarPartsRepo {
  final ApiService _apiService;
  CarPartsRepo(this._apiService);

  Future<CarPartDetailsModel> getCarPartAdById(int id) async {
    try {
      // المسار الأساسي الصحيح
      final r1 = await _apiService.getResponse(
        ApiConstants.carPartAdDetails(id),
        relaxStatus: true,
      );

      Map<String, dynamic>? body;

      if ((r1.statusCode ?? 500) >= 200 &&
          (r1.statusCode ?? 500) < 300 &&
          r1.data is Map) {
        body = Map<String, dynamic>.from(r1.data as Map);
      } else if (r1.statusCode == 404) {
        // فallback للمسار القديم (لو السيرفر يدعمه)
        final r2 = await _apiService.getResponse(
          ApiConstants.carPartAdDetails(id),
          relaxStatus: true,
        );
        if ((r2.statusCode ?? 500) >= 200 &&
            (r2.statusCode ?? 500) < 300 &&
            r2.data is Map) {
          body = Map<String, dynamic>.from(r2.data as Map);
        }
      }

      if (body == null) {
        throw AppException('فشل في جلب تفاصيل قطعة الغيار (المسار غير موجود)');
      }

      final data = body['data'] is Map
          ? Map<String, dynamic>.from(body['data'])
          : body;

      return CarPartDetailsModel.fromJson(data);
    } catch (e) {
      throw AppException("فشل في جلب تفاصيل قطعة الغيار: $e");
    }
  }
}