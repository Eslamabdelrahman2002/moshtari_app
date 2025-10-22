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

  // setters
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
  void setRegionId(int? v) => emit(state.copyWith(regionId: v)); // 🟢 تمت الإضافة

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

  Future<void> submit() async {
    // منع الضغط المزدوج أثناء الإرسال
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
        regionId: state.regionId, // 🟢 تمت الإضافة
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