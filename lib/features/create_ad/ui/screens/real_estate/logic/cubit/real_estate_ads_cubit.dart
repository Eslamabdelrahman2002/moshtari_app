// lib/features/create_ad/ui/screens/real_estate/logic/cubit/real_estate_ads_cubit.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/api/post_defaults.dart';
import '../../../../../data/car/data/model/real_estate_ad_request.dart';
import '../../../../../data/car/data/repo/real_estate_ads_repo.dart';
import '../../real_estate_mappers.dart';
import 'real_estate_ads_state.dart';
import 'package:mushtary/features/real_estate_details/date/model/real_estate_details_model.dart' as re;

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

  // تعبئة الحالة من تفاصيل إعلان موجود (وضع التعديل)
  void startEditingFromDetails(re.RealEstateDetailsModel d) {
    // قراءات مرنة لحقول قد تكون غير موجودة في الموديل
    String? priceTypeApi;
    double? lat;
    double? lng;
    String? realEstateTypeApi;

    try {
      priceTypeApi = (d as dynamic).priceType as String?;
    } catch (_) {}

    try {
      final latRaw = (d as dynamic).latitude;
      final lngRaw = (d as dynamic).longitude;
      lat = latRaw is double ? latRaw : double.tryParse(latRaw?.toString() ?? '');
      lng = lngRaw is double ? lngRaw : double.tryParse(lngRaw?.toString() ?? '');
    } catch (_) {}

    try {
      realEstateTypeApi = (d as dynamic).realEstateType as String?;
    } catch (_) {}

    final det = d.realEstateDetails;
    emit(state.copyWith(
      isEditing: true,
      editingAdId: d.id,
      title: d.title,
      description: d.description,
      price: d.price,
      priceType: RealEstateMappers.priceTypeFromApi(priceTypeApi),
      preselectedRegionName: d.region,
      preselectedCityName: d.city,
      latitude: lat ?? state.latitude,
      longitude: lng ?? state.longitude,
      realEstateType: realEstateTypeApi,
      areaM2: det?.areaM2,
      streetCount: det?.streetCount,
      floorCount: det?.floorCount,
      roomCount: det?.roomCount,
      bathroomCount: det?.bathroomCount,
      livingroomCount: det?.livingroomCount,
      streetWidth: det?.streetWidth,
      facade: det?.facade,
      buildingAge: det?.buildingAge,
      isFurnished: det?.isFurnished,
      licenseNumber: det?.licenseNumber,
      existingImageUrls: d.imageUrls?.join(',') ?? '',
    ));
  }

  // الإرسال (إنشاء/تحديث)
  Future<void> submit({
    required bool allowComments,
    required bool allowMarketing,
  }) async {
    debugPrint('[RealEstate] submit tapped. Allow Comments: $allowComments, Allow Marketing: $allowMarketing');
    emit(state.copyWith(allowComments: allowComments, allowMarketing: allowMarketing));

    // تحقق الحقول الأساسية
    if (state.title == null ||
        state.description == null ||
        state.price == null ||
        state.priceType.isEmpty ||
        state.realEstateType == null) {
      emit(state.copyWith(error: 'يرجى تعبئة الحقول الأساسية للعقار'));
      emit(state.copyWith(error: null)); // مسح الخطأ بعد العرض
      return;
    }

    // تحقق إضافي: purpose يجب أن يكون غير فارغ
    final purpose = state.purpose ?? 'sell'; // قيمة افتراضية
    if (purpose.isEmpty) {
      emit(state.copyWith(error: 'يرجى تحديد غرض العقار (بيع أو إيجار)'));
      emit(state.copyWith(error: null));
      return;
    }

    // تحقق شديد: السعر لا يتجاوز الحد الأقصى (لمنع numeric overflow)
    const maxPrice = 100000000.0; // حد أقصى مؤقت (100 مليون)
    if (state.price! > maxPrice) {
      emit(state.copyWith(
        error: 'السعر كبير جداً (الحد الأقصى: ${(maxPrice / 1000000).toStringAsFixed(0)} مليون). يرجى تقليل السعر أو الاتصال بالدعم.',
      ));
      emit(state.copyWith(error: null));
      return;
    }

    emit(state.copyWith(submitting: true, error: null));
    try {
      final req = RealEstateAdRequest(
        title: state.title!,
        description: state.description!,
        price: state.price!,
        priceType: state.priceType,
        cityId: state.cityId ?? PostDefaults.realEstateCityId,
        regionId: state.regionId ?? PostDefaults.realEstateRegionId,
        latitude: state.latitude ?? PostDefaults.realEstateLat,
        longitude: state.longitude ?? PostDefaults.realEstateLng,
        realEstateType: state.realEstateType!,
        purpose: purpose ?? '',
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
        images: state.images, // فقط الصور الجديدة
      );

      debugPrint('[RealEstateCubit] Submitting ${state.isEditing ? 'update' : 'create'} with ID: ${state.editingAdId}');

      if (state.isEditing && state.editingAdId != null) {
        // UPDATE: استخدم PUT مع JSON (بدون صور)
        await _repo.updateRealEstateAd(state.editingAdId!, req);
      } else {
        // CREATE: استخدم POST مع FormData (مع صور)
        await _repo.createRealEstateAd(req);
      }

      emit(state.copyWith(submitting: false, success: true));
    } catch (e) {
      debugPrint('[RealEstateCubit] Error: $e');
      emit(state.copyWith(submitting: false, error: e.toString()));
      emit(state.copyWith(error: null)); // مسح الخطأ بعد ثواني
    }
  }
}