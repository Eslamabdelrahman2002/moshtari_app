import 'package:bloc/bloc.dart';
import '../../data/repo/real_estate_requests_create_repo.dart';
import 'real_estate_requests_state.dart';

class RealEstateRequestsCubit extends Cubit<RealEstateRequestsState> {
  final RealEstateRequestsCreateRepo _repo;

  RealEstateRequestsCubit(this._repo) : super(RealEstateRequestsState.initial());

  // Setters (الموجودة مع Debug)
  void setRequestType(String? type) {
    print('>>> [Cubit] Set requestType: $type'); // Debug
    emit(state.copyWith(requestType: type));
  }

  void setRealEstateType(String? type) {
    print('>>> [Cubit] Set realEstateType: $type'); // Debug
    emit(state.copyWith(realEstateType: type));
  }

  void setRegionId(int? id) {
    print('>>> [Cubit] Set regionId: $id'); // Debug
    emit(state.copyWith(regionId: id));
  }

  void setCityId(int? id) {
    print('>>> [Cubit] Set cityId: $id'); // Debug
    emit(state.copyWith(cityId: id));
  }

  void setBudgetMin(num? value) {
    print('>>> [Cubit] Set budgetMin: $value'); // Debug
    emit(state.copyWith(budgetMin: value));
  }

  void setBudgetMax(num? value) {
    print('>>> [Cubit] Set budgetMax: $value'); // Debug
    emit(state.copyWith(budgetMax: value));
  }

  void setAreaMin(num? value) {
    print('>>> [Cubit] Set areaMin: $value'); // Debug
    emit(state.copyWith(areaMin: value));
  }

  void setAreaMax(num? value) {
    print('>>> [Cubit] Set areaMax: $value'); // Debug
    emit(state.copyWith(areaMax: value));
  }

  void setStreetWidthMin(int? value) {
    print('>>> [Cubit] Set streetWidthMin: $value'); // Debug
    emit(state.copyWith(streetWidthMin: value));
  }

  void setStreetWidthMax(int? value) {
    print('>>> [Cubit] Set streetWidthMax: $value'); // Debug
    emit(state.copyWith(streetWidthMax: value));
  }

  void setPreferredFloors(int? value) {
    print('>>> [Cubit] Set preferredFloors: $value'); // Debug
    emit(state.copyWith(preferredFloors: value));
  }

  void setPreferredRooms(int? value) {
    print('>>> [Cubit] Set preferredRooms: $value'); // Debug
    emit(state.copyWith(preferredRooms: value));
  }

  void setPreferredBathrooms(int? value) {
    print('>>> [Cubit] Set preferredBathrooms: $value'); // Debug
    emit(state.copyWith(preferredBathrooms: value));
  }

  void setPreferredLivingrooms(int? value) {
    print('>>> [Cubit] Set preferredLivingrooms: $value'); // Debug
    emit(state.copyWith(preferredLivingrooms: value));
  }

  void setPreferredFacade(String? value) {
    print('>>> [Cubit] Set preferredFacade: $value'); // Debug
    emit(state.copyWith(preferredFacade: value));
  }

  void setServices(List<String> services) {
    print('>>> [Cubit] Set services: $services'); // Debug
    emit(state.copyWith(services: services));
  }

  void setPaymentMethod(String? method) {
    print('>>> [Cubit] Set paymentMethod: $method'); // Debug
    emit(state.copyWith(paymentMethod: method));
  }

  void setContactPhone(String? phone) {
    print('>>> [Cubit] Set contactPhone: $phone'); // Debug
    emit(state.copyWith(contactPhone: phone));
  }

  void setAllowComments(bool value) {
    print('>>> [Cubit] Set allowComments: $value'); // Debug
    emit(state.copyWith(allowComments: value));
  }

  void setAllowMarketingOffers(bool value) {
    print('>>> [Cubit] Set allowMarketingOffers: $value'); // Debug
    emit(state.copyWith(allowMarketingOffers: value));
  }

  void setAllowNegotiation(bool value) {
    print('>>> [Cubit] Set allowNegotiation: $value'); // Debug
    emit(state.copyWith(allowNegotiation: value));
  }

  void setNotes(String? value) {
    print('>>> [Cubit] Set notes: $value'); // Debug
    emit(state.copyWith(notes: value));
  }

  Future<void> submit() async {
    print('>>> [Cubit] Submit called - State: $state'); // Debug
    // ✅ تحسين Validation (رسائل منفصلة وأوضح)
    if (state.requestType == null) {
      final error = 'يرجى اختيار غرض الطلب (إيجار أو شراء)';
      print('>>> [Cubit] Validation error (requestType): $error'); // Debug
      emit(state.copyWith(error: error));
      return;
    }
    if (state.realEstateType == null) {
      final error = 'يرجى اختيار نوع العقار';
      print('>>> [Cubit] Validation error (realEstateType): $error'); // Debug
      emit(state.copyWith(error: error));
      return;
    }
    if (state.cityId == null) {
      final error = 'يرجى اختيار المدينة';
      print('>>> [Cubit] Validation error (cityId): $error'); // Debug
      emit(state.copyWith(error: error));
      return;
    }

    emit(state.copyWith(submitting: true, error: null));
    try {
      final payload = {
        'request_type': state.requestType,
        'real_estate_type': state.realEstateType,
        'region_id': state.regionId, // ✅ إضافة regionId إلى payload
        'city_id': state.cityId,
        'budget_min': state.budgetMin,
        'budget_max': state.budgetMax,
        'area_min': state.areaMin,
        'area_max': state.areaMax,
        'street_width_min': state.streetWidthMin,
        'street_width_max': state.streetWidthMax,
        'preferred_floors': state.preferredFloors,
        'preferred_rooms': state.preferredRooms,
        'preferred_bathrooms': state.preferredBathrooms,
        'preferred_livingrooms': state.preferredLivingrooms,
        'preferred_facade': state.preferredFacade,
        'services': state.services,
        'payment_method': state.paymentMethod,
        'contact_phone': state.contactPhone,
        'allow_comments': state.allowComments,
        'allow_marketing_offers': state.allowMarketingOffers,
        'allow_negotiation': state.allowNegotiation,
        'notes': state.notes,
      };

      print('>>> [Cubit] Payload: $payload'); // Debug
      await _repo.createRequest(payload);
      emit(state.copyWith(submitting: false, success: true, error: null)); // ✅ clear error
      print('>>> [Cubit] Submit success'); // Debug
    } catch (e) {
      final error = 'حدث خطأ في الإرسال: ${e.toString()}';
      print('>>> [Cubit] Submit error: $error'); // Debug
      emit(state.copyWith(submitting: false, error: error));
    }
  }


}