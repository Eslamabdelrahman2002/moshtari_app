// lib/features/create_ad/ui/screens/other/logic/cubit/other_ads_cubit.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/api/top_level_categories.dart';
import '../../../../../data/car/data/model/other_ad_request.dart';
import '../../../../../data/car/data/repo/other_ads_repo.dart';
import 'other_ads_state.dart';

class OtherAdsCubit extends Cubit<OtherAdsState> {
  final OtherAdsCreateRepo _repo;
  OtherAdsCubit(this._repo) : super(const OtherAdsState());

  // setters
  void setTitle(String v) => emit(state.copyWith(title: v));
  void setDescription(String v) => emit(state.copyWith(description: v));

  void setCategoryId(int? v) => emit(state.copyWith(categoryId: v));

  void setPriceType(String v) => emit(state.copyWith(priceType: v));
  void setPrice(num? v) => emit(state.copyWith(price: v));

  void setCityId(int? v) => emit(state.copyWith(cityId: v));
  void setRegionId(int? v) => emit(state.copyWith(regionId: v));
  void setLocationName(String? v) => emit(state.copyWith(locationName: v));

  void setPhone(String? v) => emit(state.copyWith(phoneNumber: v));
  void setLatLng(double? lat, double? lng) =>
      emit(state.copyWith(latitude: lat, longitude: lng));

  void setAllowMarketing(bool v) => emit(state.copyWith(allowMarketing: v));
  void setAllowComments(bool v) => emit(state.copyWith(allowComments: v));
  void setCommunicationMethods(List<String> v) =>
      emit(state.copyWith(communicationMethods: v));

  void addImage(File f) => emit(state.copyWith(images: [...state.images, f]));
  void removeImageAt(int i) {
    final imgs = [...state.images]..removeAt(i);
    emit(state.copyWith(images: imgs));
  }

  Future<void> submit() async {
    if (state.title == null ||
        /* state.categoryId == null (سنضبطها هنا) */
        state.cityId == null ||
        state.priceType.isEmpty) {
      emit(state.copyWith(error: 'يرجى تعبئة الحقول الأساسية'));
      emit(state.copyWith(error: null));
      return;
    }

    emit(state.copyWith(submitting: true, success: false, error: null));
    try {
      final req = OtherAdRequest(
        title: state.title!,
        description: state.description,
        // لو ما تم تحديد التصنيف، نثبت "أخرى" = 4
        categoryId: state.categoryId ?? TopLevelCategoryIds.other,
        priceType: state.priceType,
        price: state.price,
        cityId: state.cityId!,
        regionId: state.regionId,
        locationName: state.locationName,
        phoneNumber: state.phoneNumber,
        communicationMethods: state.communicationMethods,
        allowMarketing: state.allowMarketing,
        allowComments: state.allowComments,
        latitude: state.latitude,
        longitude: state.longitude,
        images: state.images,
      );

      await _repo.createOtherAd(req);
      emit(state.copyWith(submitting: false, success: true));
    } catch (e) {
      debugPrint('[OtherAds] submit error: $e');
      emit(state.copyWith(submitting: false, error: e.toString()));
      emit(state.copyWith(error: null));
    }
  }
}