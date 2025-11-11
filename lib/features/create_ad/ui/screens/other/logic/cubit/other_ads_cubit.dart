import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/car/data/model/other_ad_request.dart';
import '../../../../../data/car/data/repo/other_ads_repo.dart';
import 'other_ads_state.dart';

class OtherAdsCubit extends Cubit<OtherAdsState> {
  final OtherAdsCreateRepo repo;
  OtherAdsCubit(this.repo) : super(const OtherAdsState());

  // ====== وضع التعديل ======
  void enterEditMode(int adId) => emit(state.copyWith(isEditing: true, editingAdId: adId));

  void setExistingImageUrls(List<String> urls) =>
      emit(state.copyWith(existingImageUrls: urls));

  void removeExistingImageAt(int index) {
    final list = List<String>.from(state.existingImageUrls);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      emit(state.copyWith(existingImageUrls: list));
    }
  }

  // Prefill (من موديل التفاصيل إلى الحالة) - اختياري
  void prefillFromDetails(Map<String, dynamic> d) {
    emit(state.copyWith(
      title: (d['title'] ?? '').toString(),
      description: (d['description'] ?? '').toString(),
      regionId: _toInt(d['region_id']),
      cityId: _toInt(d['city_id']),
      price: _toNum(d['price']),
      phone: d['phone_number']?.toString(),
      priceType: (d['price_type']?.toString() ?? 'fixed'),
      allowComments: (d['allow_comments'] == true),
      allowMarketing: (d['allow_marketing_offers'] == true),
      communicationMethods: (d['communication_methods'] is List)
          ? List<String>.from((d['communication_methods'] as List).map((e) => e.toString()))
          : const <String>[],
      existingImageUrls: (d['image_urls'] is List)
          ? List<String>.from((d['image_urls'] as List).map((e) => e.toString()))
          : const <String>[],
    ));
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString().replaceAll(',', '').trim());
  }

  // ====== setters ======
  void setTitle(String v) => emit(state.copyWith(title: v, error: null, success: false));
  void setDescription(String v) => emit(state.copyWith(description: v, error: null, success: false));
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

  // ====== submit (إنشاء/تحديث) ======
  Future<void> submit() async {
    // تحقق داخلي قبل الإرسال
    final missing = <String>[];
    if ((state.title ?? '').trim().isEmpty) missing.add('عنوان الإعلان');
    if ((state.description ?? '').trim().isEmpty) missing.add('وصف العرض');
    if (state.regionId == null) missing.add('المنطقة');
    if (state.cityId == null) missing.add('المدينة');
    if (state.priceType == 'fixed' && state.price == null) missing.add('السعر');
    if ((state.phone ?? '').trim().isEmpty) missing.add('رقم الهاتف');
    if (!state.isEditing && state.images.isEmpty) missing.add('صورة واحدة على الأقل'); // عند الإنشاء فقط
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
      if (state.isEditing && state.editingAdId != null) {
        // ✅ UPDATE JSON
        final res = await repo.updateOtherAd(
          id: state.editingAdId!,
          title: state.title!.trim(),
          description: state.description!.trim(),
          priceType: (state.priceType).trim(),
          price: state.price, // يُرسل فقط إذا fixed
          cityId: state.cityId!,
          regionId: state.regionId!,
          allowComments: state.allowComments,
          allowMarketingOffers: state.allowMarketing,
          phoneNumber: state.phone!.trim(),
          communicationMethods: state.communicationMethods,
          imageUrls: state.existingImageUrls.isEmpty ? null : state.existingImageUrls,
          // latitude/longitude لو عندك أضفهم
        );

        emit(state.copyWith(submitting: false, success: true, error: null));
        return;
      }

      // ✅ CREATE Multipart
      final req = OtherAdRequest(
        title: state.title!.trim(),
        description: state.description!.trim(),
        regionId: state.regionId!,
        cityId: state.cityId!,
        price: state.price!,
        phone: state.phone!.trim(),
        priceType: (state.priceType).trim(),
        allowComments: state.allowComments,
        allowMarketing: state.allowMarketing,
        communicationMethods: state.communicationMethods,
        images: state.images,
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