import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/car/data/model/other_ad_request.dart';
import '../../../../../data/car/data/repo/other_ads_repo.dart';
import 'other_ads_state.dart';

class OtherAdsCubit extends Cubit<OtherAdsState> {
  final OtherAdsCreateRepo repo;
  OtherAdsCubit(this.repo) : super(const OtherAdsState());

  // setters
  void setTitle(String v) => emit(state.copyWith(title: v, error: null, success: false));
  void setDescription(String v) => emit(state.copyWith(description: v, error: null, success: false));
  // التصنيف ثابت 4، لا حاجة فعليًا لهذا الحقل لكن نُبقي setSubCategoryId إن كان مستخدمًا في الواجهة
  void setSubCategoryId(int id) => emit(state.copyWith(subCategoryId: id, error: null, success: false));
  void setRegionId(int? id) => emit(state.copyWith(regionId: id, error: null, success: false));
  void setCityId(int? id) => emit(state.copyWith(cityId: id, error: null, success: false));
  void setPrice(num? v) => emit(state.copyWith(price: v, error: null, success: false));
  void setPhone(String v) => emit(state.copyWith(phone: v, error: null, success: false));
  void setPriceType(String v) => emit(state.copyWith(priceType: v, error: null, success: false));

  void setAllowComments(bool v) => emit(state.copyWith(allowComments: v, error: null));
  void setAllowMarketing(bool v) => emit(state.copyWith(allowMarketing: v, error: null));

  void setCommunicationMethods(List<String> methods) =>
      emit(state.copyWith(communicationMethods: methods, error: null));

  void addImage(File f) {
    final imgs = List<File>.from(state.images)..add(f);
    emit(state.copyWith(images: imgs, error: null));
  }

  void removeImageAt(int index) {
    final imgs = List<File>.from(state.images)..removeAt(index);
    emit(state.copyWith(images: imgs, error: null));
  }

  Future<void> submit() async {
    // تحقق داخلي قبل الإرسال
    final missing = <String>[];
    if ((state.title ?? '').trim().isEmpty) missing.add('عنوان الإعلان');
    if ((state.description ?? '').trim().isEmpty) missing.add('وصف العرض');
    // التصنيف ثابت، فلا نتحقق من subCategoryId
    if (state.regionId == null) missing.add('المنطقة');
    if (state.cityId == null) missing.add('المدينة');
    if (state.price == null) missing.add('السعر');
    if ((state.phone ?? '').trim().isEmpty) missing.add('رقم الهاتف');
    if (state.images.isEmpty) missing.add('صورة واحدة على الأقل');
    if (state.communicationMethods.isEmpty) missing.add('طريقة تواصل واحدة على الأقل');

    if (missing.isNotEmpty) {
      emit(state.copyWith(
        error: 'يرجى استكمال الحقول: ${missing.join(' • ')}',
        submitting: false,
        success: false,
      ));
      return;
    }

    emit(state.copyWith(submitting: true, error: null, success: false));

    try {
      final req = OtherAdRequest(
        title: state.title!.trim(),
        description: state.description!.trim(),
        regionId: state.regionId!,
        cityId: state.cityId!,
        price: state.price!,
        phone: state.phone!.trim(),
        priceType: (state.priceType ?? 'fixed').trim(),
        allowComments: state.allowComments,
        allowMarketing: state.allowMarketing,
        communicationMethods: state.communicationMethods,
        images: state.images,
        // إن كان لديك موقع على الخريطة مرره هنا:
        // locationName: state.locationName,
        // latitude: state.lat,
        // longitude: state.lng,
      );

      final res = await repo.createOtherAd(req);
      if (res.statusCode == 200 || res.statusCode == 201) {
        emit(state.copyWith(submitting: false, success: true, error: null));
      } else {
        emit(state.copyWith(
          submitting: false,
          success: false,
          error: res.data?.toString() ?? 'حدث خطأ غير متوقع',
        ));
      }
    } catch (e) {
      final msg = (e is DioException)
          ? (e.error?.toString() ?? e.message ?? 'فشل الاتصال بالخادم')
          : e.toString();
      emit(state.copyWith(submitting: false, success: false, error: msg));
    }
  }
}