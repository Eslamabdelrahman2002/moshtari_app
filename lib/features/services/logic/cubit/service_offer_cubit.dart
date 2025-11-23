import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/features/services/logic/cubit/service_offer_state.dart';
import '../../data/repo/service_offers_repo.dart';


class ServiceOffersCubit extends Cubit<ServiceOffersState> {
  final ServiceOffersRepo _repo;
  ServiceOffersCubit(this._repo) : super(const ServiceOffersState());

  /// تقديم عرض على طلب معيّن
  Future<bool> submit({
    required int requestId,
    required num price,
    String? message,
  }) async {
    emit(state.copyWith(
      loading: true,
      clearError: true,
      success: false,
      clearLastCreated: true,
      clearActing: true,
    ));
    try {
      final offer = await _repo.submitOffer(
        requestId: requestId,
        price: price,
        message: message,
      );
      emit(state.copyWith(
        loading: false,
        success: true,
        lastCreatedOffer: offer,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
      ));
      return false;
    }
  }

  /// قبول عرض
  Future<bool> accept(int offerId) async {
    emit(state.copyWith(
      loading: true,
      clearError: true,
      success: false,
      actingOfferId: offerId,
    ));
    try {
      await _repo.acceptOffer(offerId);
      emit(state.copyWith(
        loading: false,
        success: true,
        clearActing: true,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
        clearActing: true,
      ));
      return false;
    }
  }

  /// رفض عرض
  Future<bool> reject(int offerId) async {
    emit(state.copyWith(
      loading: true,
      clearError: true,
      success: false,
      actingOfferId: offerId,
    ));
    try {
      await _repo.rejectOffer(offerId);
      emit(state.copyWith(
        loading: false,
        success: true,
        clearActing: true,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
        clearActing: true,
      ));
      return false;
    }
  }

  void resetSuccess() => emit(state.copyWith(success: false));
}