// lib/features/create_ad/ui/screens/car/logic/cubit/car_ads_cubit.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../../../../../product_details/data/model/car_details_model.dart' as details;
import 'car_ads_state.dart';
import '../../../../../data/car/data/model/car_ad_request.dart';
import '../../../../../data/car/data/repo/car_ads_repository.dart';

class CarAdsCubit extends Cubit<CarAdsState> {
  final CarAdsRepository _repo;
  CarAdsCubit(this._repo) : super(CarAdsState());

  int? _exhibitionId;

  // الدخول لوضع التعديل
  void enterEditMode(int adId) {
    emit(state.copyWith(isEditing: true, editingAdId: adId));
  }

  void reset() => emit(CarAdsState(
    isEditing: false,
    editingAdId: null,
    success: false,
    submitting: false,
    error: null,
    categoryId: 1,
    priceType: 'fixed',
    condition: '',
    saleType: '',
    warranty: '',
    transmission: '',
    fuelType: '',
    driveType: '',
    doors: '',
    allowComments: true,
    allowMarketing: false,
    contactChat: true,
    contactWhatsapp: true,
    contactCall: true,
  ));

  void setExhibitionId(int? id) {
    _exhibitionId = id;
    debugPrint('>>> CarAdsCubit: Exhibition ID set to $_exhibitionId');
  }

  // setters
  void setPhone(String v) => emit(state.copyWith(phone: v.trim().isEmpty ? null : v.trim()));
  void setAddressAr(String? v) => emit(state.copyWith(addressAr: v));
  void setLatLng(double? lat, double? lng) => emit(state.copyWith(latitude: lat, longitude: lng));
  void setCityId(int? id) => emit(state.copyWith(cityId: id));
  void setRegionId(int? id) => emit(state.copyWith(regionId: id));
  void setContactChat(bool v) => emit(state.copyWith(contactChat: v));
  void setContactWhatsapp(bool v) => emit(state.copyWith(contactWhatsapp: v));
  void setContactCall(bool v) => emit(state.copyWith(contactCall: v));
  void setAllowComments(bool v) => emit(state.copyWith(allowComments: v));
  void setAllowMarketing(bool v) => emit(state.copyWith(allowMarketing: v));

  void addImage(File f) => emit(state.copyWith(images: [...state.images, f]));
  void removeImageAt(int i) {
    final imgs = [...state.images]..removeAt(i);
    emit(state.copyWith(images: imgs));
  }

  void setTechnicalReport(File? f) => emit(state.copyWith(technicalReport: f));
  void setTitle(String v) => emit(state.copyWith(title: v.trim().isEmpty ? null : v.trim()));
  void setDescription(String v) => emit(state.copyWith(description: v.trim().isEmpty ? null : v.trim()));
  void setPrice(num? v) => emit(state.copyWith(price: v));
  void setPriceType(String v) => emit(state.copyWith(priceType: v));
  void setCondition(String v) => emit(state.copyWith(condition: v));
  void setSaleType(String v) => emit(state.copyWith(saleType: v));
  void setWarranty(String v) => emit(state.copyWith(warranty: v));
  void setMileage(num? v) => emit(state.copyWith(mileage: v));
  void setTransmission(String v) => emit(state.copyWith(transmission: v));
  void setCylinders(int? v) => emit(state.copyWith(cylinders: v));
  void setColor(String? v) => emit(state.copyWith(color: v));
  void setFuelType(String v) => emit(state.copyWith(fuelType: v));
  void setDriveType(String v) => emit(state.copyWith(driveType: v));
  void setHorsepower(int? v) => emit(state.copyWith(horsepower: v));
  void setDoors(String v) => emit(state.copyWith(doors: v));
  void setVehicleType(String? v) => emit(state.copyWith(vehicleType: v));
  void setBrandId(int? id) => emit(state.copyWith(brandId: id));
  void setModelId(int? id) => emit(state.copyWith(modelId: id));
  void setYear(int? v) => emit(state.copyWith(year: v));

  // صور موجودة مسبقاً للتعديل
  void setExistingImageUrls(List<String> urls) => emit(state.copyWith(existingImageUrls: urls));

  // حذف صورة قديمة
  void removeExistingImageAt(int i) {
    final current = [...state.existingImageUrls];
    if (i >= 0 && i < current.length) {
      current.removeAt(i);
      emit(state.copyWith(existingImageUrls: current));
    }
  }

  // --------------------------------------------------------------
  Future<void> submit() async {
    debugPrint('[Car] submit tapped');

    String? getMissingField() {
      if (state.title == null || state.title!.trim().isEmpty) return 'عنوان الإعلان';
      if (state.description == null || state.description!.trim().isEmpty) return 'وصف العرض';
      if (state.priceType == 'fixed' && state.price == null) return 'السعر';
      if (state.brandId == null) return 'ماركة السيارة (ID)';
      if (state.modelId == null) return 'موديل السيارة (ID)';
      if (state.year == null) return 'سنة السيارة';
      if (state.priceType.isEmpty) return 'نوع البيع';
      if (state.condition.isEmpty) return 'حالة السيارة';
      if (state.saleType.isEmpty) return 'نوع الدفع';
      if (state.warranty.isEmpty) return 'الضمان';
      if (state.transmission.isEmpty) return 'القير';
      if (state.fuelType.isEmpty) return 'نوع الوقود';
      if (state.driveType.isEmpty) return 'نوع الدفع';
      if (state.doors.isEmpty) return 'عدد الأبواب';
      return null;
    }

    final missingField = getMissingField();
    if (missingField != null) {
      emit(state.copyWith(error: 'يرجى تعبئة الحقل: $missingField'));
      emit(state.copyWith(clearError: true));
      return;
    }

    // تحقق من السعر الكبير جداً
    const maxPrice = 100000000.0;
    if (state.price != null && state.price! > maxPrice) {
      emit(state.copyWith(error: 'السعر كبير جداً. الحد الأقصى هو 100 مليون'));
      emit(state.copyWith(clearError: true));
      return;
    }

    emit(state.copyWith(submitting: true, error: null));

    try {
      final req = CarAdRequest(
        title: state.title!,
        description: state.description!,
        price: state.price ?? 0,
        priceType: state.priceType,
        categoryId: 1,
        cityId: state.cityId ?? 1,
        regionId: state.regionId ?? 1,
        latitude: state.latitude ?? 24.774265,
        longitude: state.longitude ?? 46.738586,
        phone: state.phone,
        contactChat: state.contactChat,
        contactWhatsapp: state.contactWhatsapp,
        contactCall: state.contactCall,
        condition: state.condition,
        saleType: state.saleType,
        warranty: state.warranty,
        mileage: state.mileage ?? 0,
        transmission: state.transmission,
        cylinders: state.cylinders ?? 4,
        color: state.color ?? 'أبيض',
        fuelType: state.fuelType,
        driveType: state.driveType,
        horsepower: state.horsepower ?? 150,
        doors: state.doors,
        vehicleType: state.vehicleType ?? 'sedan',
        brandId: state.brandId!,
        modelId: state.modelId!,
        year: state.year!,
        allowComments: state.allowComments,
        allowMarketing: state.allowMarketing,
        images: state.images,
        technicalReport: state.technicalReport,
        exhibitionId: _exhibitionId,
      );

      final isEdit = state.isEditing && state.editingAdId != null;

      final res = isEdit
          ? await _repo.updateCarAd(
        state.editingAdId!,
        req,
        imageUrls: state.existingImageUrls.isEmpty ? null : state.existingImageUrls,
      )
          : await _repo.createCarAd(req);

      if (res.success) {
        emit(state.copyWith(submitting: false, success: true, error: res.message));
      } else {
        emit(state.copyWith(submitting: false, error: res.message));
      }
    } on DioException catch (e) {
      debugPrint('HTTP error: status=${e.response?.statusCode}, body=${e.response?.data}');
      if (e.response?.statusCode == 500) {
        emit(state.copyWith(error: 'خطأ في الخادم (500). راجع البيانات أو الدعم.'));
      } else {
        emit(state.copyWith(error: e.toString()));
      }
      emit(state.copyWith(submitting: false));
      emit(state.copyWith(clearError: true));
    } catch (e) {
      emit(state.copyWith(submitting: false, error: e.toString()));
      emit(state.copyWith(clearError: true));
    }
  }

  // --------------------------------------------------------------

  void prefillFromDetails(details.CarDetailsModel d) {
    emit(state.copyWith(
      title: (d.title ?? '').trim().isEmpty ? null : d.title!.trim(),
      description: d.description.trim().isEmpty ? null : d.description.trim(),
      price: _parseNum(d.price),
      addressAr: _composeAddress(d.region, d.city),
      phone: (d.userPhoneNumber ?? '').trim().isEmpty ? null : d.userPhoneNumber!.trim(),
      mileage: _parseNum(d.mileage),
      transmission: _mapTransmission(d.transmissionType),
      cylinders: _toIntOrNull(d.cylinderCount),
      color: (d.color ?? '').trim().isEmpty ? null : d.color!.trim(),
      fuelType: _mapFuel(d.fuelType),
      driveType: _mapDrive(d.driveType),
      horsepower: _toIntOrNull(d.horsepower),
      vehicleType: (d.vehicleType ?? '').trim().isEmpty ? null : d.vehicleType!.trim(),
      brandId: _toIntOrNull(d.brand),
      modelId: _toIntOrNull(d.modelAr),
      year: _toIntOrNull(d.year),
      allowComments: state.allowComments,
      allowMarketing: state.allowMarketing,
      existingImageUrls: d.imageUrls ?? const [],
    ));
  }

  int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final s = v.trim();
      return int.tryParse(s);
    }
    return null;
  }

  num? _parseNum(String? s) {
    if (s == null) return null;
    return num.tryParse(s.replaceAll(',', '').trim());
  }

  String _composeAddress(String? region, String? city) {
    final parts = <String>[];
    if (region != null && region.trim().isNotEmpty) parts.add(region.trim());
    if (city != null && city.trim().isNotEmpty) parts.add(city.trim());
    return parts.join(' - ');
  }

  String _mapTransmission(String? v) {
    final s = (v ?? '').toLowerCase();
    if (s.contains('manual') || s.contains('عادي')) return 'manual';
    if (s.contains('auto') || s.contains('automatic') || s.contains('اوتو') || s.contains('أوتومات')) return 'automatic';
    return state.transmission.isNotEmpty ? state.transmission : 'automatic';
  }

  String _mapFuel(String? v) {
    final s = (v ?? '').toLowerCase();
    if (s.contains('gas') || s.contains('بنزين')) return 'gasoline';
    if (s.contains('diesel') || s.contains('ديزل')) return 'diesel';
    if (s.contains('hybrid') || s.contains('هايب')) return 'hybrid';
    if (s.contains('electric') || s.contains('كهرب')) return 'electric';
    return state.fuelType.isNotEmpty ? state.fuelType : 'gasoline';
  }

  String _mapDrive(String? v) {
    final s = (v ?? '').toLowerCase();
    if (s.contains('front') || s.contains('أمام')) return 'front_wheel';
    if (s.contains('rear') || s.contains('خلف')) return 'rear_wheel';
    if (s.contains('all') || s.contains('4') || s.contains('رباع')) return 'all_wheel';
    return state.driveType.isNotEmpty ? state.driveType : 'front_wheel';
  }
}