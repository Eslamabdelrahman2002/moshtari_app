// lib/features/create_ad/ui/screens/real_estate/logic/cubit/real_estate_ads_cubit.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// مابرز النص العربي <-> قيم API
import '../../../../../../../core/api/post_defaults.dart';
import '../../../../../../../core/api/top_level_categories.dart';
import '../../../../../data/car/data/model/real_estate_ad_request.dart';
import '../../../../../data/car/data/repo/real_estate_ads_repo.dart';
import '../../real_estate_mappers.dart';

// حالة الكيوبت
import 'real_estate_ads_state.dart';

class RealEstateAdsCubit extends Cubit<RealEstateAdsState> {
  final RealEstateAdsRepo _repo;
  RealEstateAdsCubit(this._repo) : super(const RealEstateAdsState());

  // setters الأساسية
  void setTitle(String v) => emit(state.copyWith(title: v));
  void setDescription(String v) => emit(state.copyWith(description: v));
  void setPrice(num? v) => emit(state.copyWith(price: v));
  void setPriceType(String v) => emit(state.copyWith(priceType: v));

  // المدينة/المنطقة/الإحداثيات
  void setCityId(int? v) => emit(state.copyWith(cityId: v));
  void setRegionId(int? v) => emit(state.copyWith(regionId: v));
  void setLatLng(double? lat, double? lng) => emit(state.copyWith(latitude: lat, longitude: lng));

  // نوع العقار والغرض
  void setRealEstateType(String? v) => emit(state.copyWith(realEstateType: v));
  void setPurpose(bool isForSell) => emit(state.copyWith(purpose: RealEstateMappers.purpose(isForSell)));

  // تفاصيل إضافية
  void setAreaM2(num? v) => emit(state.copyWith(areaM2: v));
  void setStreetCount(int? v) => emit(state.copyWith(streetCount: v));
  void setFloorCount(int? v) => emit(state.copyWith(floorCount: v));
  void setRoomCount(int? v) => emit(state.copyWith(roomCount: v));
  void setBathroomCount(int? v) => emit(state.copyWith(bathroomCount: v));
  void setLivingroomCount(int? v) => emit(state.copyWith(livingroomCount: v));
  void setStreetWidth(num? v) => emit(state.copyWith(streetWidth: v));
  void setFacade(String? v) => emit(state.copyWith(facade: v));
  void setBuildingAge(String? v) => emit(state.copyWith(buildingAge: v));
  void setIsFurnished(bool? v) => emit(state.copyWith(isFurnished: v));
  void setLicenseNumber(String? v) => emit(state.copyWith(licenseNumber: v));
  void setServices(List<String> v) => emit(state.copyWith(services: v));
  void setExhibitionId(int? v) => emit(state.copyWith(exhibitionId: v));

  // صور
  void addImage(File f) => emit(state.copyWith(images: [...state.images, f]));
  void removeImageAt(int i) {
    final imgs = [...state.images]..removeAt(i);
    emit(state.copyWith(images: imgs));
  }

  // سويتشات الواجهة
  void setAllowComments(bool v) => emit(state.copyWith(allowComments: v));
  void setAllowMarketing(bool v) => emit(state.copyWith(allowMarketing: v));

  // الإرسال
  Future<void> submit({
    required bool allowComments,
    required bool allowMarketing,
  }) async {
    debugPrint('[RealEstate] submit tapped. Allow Comments: $allowComments, Allow Marketing: $allowMarketing');

    // تحدّيث الحالة بقيم السويتشات القادمة من الواجهة
    emit(state.copyWith(allowComments: allowComments, allowMarketing: allowMarketing));

    // التحقّق من الحقول الأساسية
    if (state.title == null ||
        state.description == null ||
        state.price == null ||
        state.priceType.isEmpty ||
        state.realEstateType == null) {
      emit(state.copyWith(error: 'يرجى تعبئة الحقول الأساسية للعقار'));
      emit(state.copyWith(error: null)); // مسح الخطأ بعد العرض
      return;
    }

    emit(state.copyWith(submitting: true, error: null));
    try {
      final req = RealEstateAdRequest(
        title: state.title!,
        description: state.description!,
        price: state.price!,
        priceType: state.priceType,
        // categoryId ثابت = 2 داخل الموديل
        cityId: state.cityId ?? PostDefaults.realEstateCityId,
        regionId: state.regionId ?? PostDefaults.realEstateRegionId,
        latitude: state.latitude ?? PostDefaults.realEstateLat,
        longitude: state.longitude ?? PostDefaults.realEstateLng,
        realEstateType: state.realEstateType!, // يجب اختياره
        purpose: state.purpose,
        areaM2: state.areaM2,
        streetCount: state.streetCount,
        floorCount: state.floorCount,
        roomCount: state.roomCount,
        bathroomCount: state.bathroomCount,
        livingroomCount: state.livingroomCount,
        streetWidth: state.streetWidth,
        facade: state.facade,
        buildingAge: state.buildingAge,
        isFurnished: state.isFurnished,
        licenseNumber: state.licenseNumber,
        services: state.services,
        exhibitionId: state.exhibitionId,
        images: state.images,
        // ملاحظة: allowComments/allowMarketing غير موجودة في الطلب الحالي (حسب Postman).
        // إن أردت إرسالهم، أضف حقول اختيارية في RealEstateAdRequest ومرّرهم هنا.
      );

      await _repo.createRealEstateAd(req);
      emit(state.copyWith(submitting: false, success: true));
    } catch (e) {
      emit(state.copyWith(submitting: false, error: e.toString()));
      emit(state.copyWith(error: null));
    }
  }
}