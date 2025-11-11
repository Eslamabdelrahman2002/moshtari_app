import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/api/post_defaults.dart';
import 'package:mushtary/features/create_ad/data/car/data/model/car_part_ad_request.dart';
import 'package:mushtary/features/create_ad/data/car/data/repo/car_part_ads_create_repo.dart';

import 'car_part_ads_state.dart';

class CarPartAdsCubit extends Cubit<CarPartAdsState> {
  final CarPartAdsCreateRepo _repo;
  CarPartAdsCubit(this._repo) : super(CarPartAdsState());

  // =========== وضع التعديل ===========
  void enterEditMode(int adId) => emit(state.copyWith(isEditing: true, editingAdId: adId));

  void setExistingImageUrls(List<String> urls) =>
      emit(state.copyWith(existingImageUrls: urls));

  void removeExistingImageAt(int i) {
    final list = [...state.existingImageUrls];
    if (i >= 0 && i < list.length) {
      list.removeAt(i);
      emit(state.copyWith(existingImageUrls: list));
    }
  }

  // Prefill من تفاصيل الإعلان (استخدم موديلك أو Map)
  // متوافق مع JSON اللي أرسلته (image_urls, phone_number, communication_methods ...)
  void prefillFromDetails(Map<String, dynamic> d) {
    emit(state.copyWith(
      title: _asString(d['title']),
      partName: _asString(d['part_name']),
      description: _asString(d['description']),
      priceType: _asString(d['price_type'])?.isNotEmpty == true ? d['price_type'] : 'fixed',
      price: _toNum(d['price']),
      cityId: _toInt(d['city_id']),
      regionId: _toInt(d['region_id']),
      phoneNumber: _asString(d['phone_number']),
      communicationMethods: (d['communication_methods'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          state.communicationMethods,
      allowComments: (d['allow_comments'] ?? state.allowComments) as bool,
      allowMarketing: (d['allow_marketing_offers'] ?? state.allowMarketing) as bool,
      latitude: _toDouble(d['latitude']),
      longitude: _toDouble(d['longitude']),
      existingImageUrls: (d['image_urls'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    ));
  }

  String? _asString(dynamic v) => v?.toString();
  num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString().replaceAll(',', '').trim());
  }
  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  // =========== setters ===========
  void setTitle(String v) => emit(state.copyWith(title: v));
  void setPartName(String v) => emit(state.copyWith(partName: v));
  void setCondition(String v) => emit(state.copyWith(condition: v));
  void setBrandId(int? v) => emit(state.copyWith(brandId: v));
  void setSupportedModels(List<String> v) => emit(state.copyWith(supportedModel: v));
  void setDescription(String? v) => emit(state.copyWith(description: v));

  void setPrice(num? v) => emit(state.copyWith(price: v));
  void setPriceType(String v) => emit(state.copyWith(priceType: v));

  void setCityId(int? v) => emit(state.copyWith(cityId: v));
  void setNeighborhoodId(int? v) => emit(state.copyWith(neighborhoodId: v));
  void setRegionId(int? v) => emit(state.copyWith(regionId: v));

  void setPhoneNumber(String? v) => emit(state.copyWith(phoneNumber: v));
  void setCommunicationMethods(List<String> v) => emit(state.copyWith(communicationMethods: v));
  void setAllowMarketing(bool v) => emit(state.copyWith(allowMarketing: v));
  void setAllowComments(bool v) => emit(state.copyWith(allowComments: v));

  void setExhibitionId(int? v) => emit(state.copyWith(exhibitionId: v));
  void setLatLng(double? lat, double? lng) => emit(state.copyWith(latitude: lat, longitude: lng));

  void addImage(File f) => emit(state.copyWith(images: [...state.images, f]));
  void removeImageAt(int i) {
    final imgs = [...state.images]..removeAt(i);
    emit(state.copyWith(images: imgs));
  }

  // =========== submit ===========
  Future<void> submit() async {
    if (state.submitting) return;

    debugPrint('[CarPart] submit tapped');

    final needsPrice = state.priceType != 'negotiable';
    if (state.title == null ||
        state.partName == null ||
        (needsPrice && state.price == null) ||
        state.priceType.isEmpty) {
      emit(state.copyWith(error: 'يرجى تعبئة الحقول الأساسية لقطع الغيار'));
      emit(state.copyWith(error: null));
      return;
    }

    emit(state.copyWith(submitting: true, error: null));

    try {
      // وضع التعديل: PUT JSON “خفيف”
      if (state.isEditing && state.editingAdId != null) {
        await _repo.updateCarPartAd(
          state.editingAdId!,
          title: state.title!,
          description: state.description ?? '',
          priceType: state.priceType,
          price: state.price, // يُرسل داخل الريبو فقط إذا كان priceType= fixed
          cityId: state.cityId ?? PostDefaults.carPartsCityId,
          regionId: state.regionId ?? 1,
          allowComments: state.allowComments,
          allowMarketingOffers: state.allowMarketing,
          phoneNumber: state.phoneNumber,
          communicationMethods:
          state.communicationMethods.isEmpty ? null : state.communicationMethods,
          imageUrls: state.existingImageUrls.isEmpty ? null : state.existingImageUrls,
          latitude: state.latitude,
          longitude: state.longitude,
        );

        emit(state.copyWith(submitting: false, success: true));
        return;
      }

      // وضع الإنشاء: Multipart
      final req = CarPartAdRequest(
        title: state.title!,
        partName: state.partName!,
        condition: state.condition, // 'new' | 'used'
        brandId: state.brandId,
        supportedModel: state.supportedModel,
        description: state.description,
        price: state.price!,
        priceType: state.priceType,
        cityId: state.cityId ?? PostDefaults.carPartsCityId,
        regionId: state.regionId,
        neighborhoodId: state.neighborhoodId ?? PostDefaults.carPartsNeighborhoodId,
        phoneNumber: state.phoneNumber,
        communicationMethods: state.communicationMethods,
        allowMarketing: state.allowMarketing,
        allowComments: state.allowComments,
        exhibitionId: state.exhibitionId,
        latitude: state.latitude ?? PostDefaults.carPartsLat,
        longitude: state.longitude ?? PostDefaults.carPartsLng,
        images: state.images,
      );

      await _repo.createCarPartAd(req);
      emit(state.copyWith(submitting: false, success: true));
    } catch (e) {
      emit(state.copyWith(submitting: false, error: e.toString()));
      emit(state.copyWith(error: null));
    }
  }
}