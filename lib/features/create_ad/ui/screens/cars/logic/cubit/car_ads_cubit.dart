import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'car_ads_state.dart';
import '../../../../../data/car/data/model/car_ad_request.dart';
import '../../../../../data/car/data/repo/car_ads_repository.dart';

class CarAdsCubit extends Cubit<CarAdsState> {
  final CarAdsRepository _repo;
  CarAdsCubit(this._repo) : super(CarAdsState());

  // ✅ NEW: Variable داخلي لتخزين exhibitionId (من الـ router)
  int? _exhibitionId;

  void reset() => emit(CarAdsState(
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

  // ✅ NEW: Method لتعيين exhibitionId (يستدعى من initState في الـ widget)
  void setExhibitionId(int? id) {
    _exhibitionId = id;
    debugPrint('>>> CarAdsCubit: Exhibition ID set to $_exhibitionId'); // ✅ NEW: debug print (اختياري)
  }

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

  Future<void> submit() async {
    debugPrint('[Car] submit tapped');

    String? getMissingField() {
      if (state.title == null || state.title!.trim().isEmpty) return 'عنوان الإعلان';
      if (state.description == null || state.description!.trim().isEmpty) return 'وصف العرض';
      if (state.price == null) return 'السعر';
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
      emit(state.copyWith(error: 'خطأ: يرجى تعبئة الحقل الأساسي: $missingField'));
      emit(state.copyWith(clearError: true));
      return;
    }

    emit(state.copyWith(submitting: true, error: null));
    try {
      final req = CarAdRequest(
        title: state.title!,
        description: state.description!,
        price: state.price!,
        priceType: state.priceType,
        categoryId: 1, // ثابت: سيارات
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
        exhibitionId: _exhibitionId, // ✅ NEW: مرر exhibitionId للـ request (لو موجود)
      );

      final response = await _repo.createCarAd(req);

      if (response.success) {
        emit(state.copyWith(submitting: false, success: true, error: response.message));
      } else {
        emit(state.copyWith(submitting: false, error: response.message));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        debugPrint('[Car] Receive Timeout Caught. Assuming background processing.');
        emit(state.copyWith(
          submitting: false,
          success: true,
          error: 'تم استلام إعلانك (قد يكون قيد المراجعة). يرجى التحقق لاحقاً.',
        ));
      } else {
        emit(state.copyWith(submitting: false, error: e.toString()));
        emit(state.copyWith(clearError: true));
      }
    } catch (e) {
      emit(state.copyWith(submitting: false, error: e.toString()));
      emit(state.copyWith(clearError: true));
    }
  }
}