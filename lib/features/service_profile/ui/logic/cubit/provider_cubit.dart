import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/service_request_models.dart';

import '../../../data/repo/service_provider_repo.dart';
import 'provider_state.dart';

class ProviderCubit extends Cubit<ProviderState> {
  final ServiceProviderRepo _repo;
  ProviderCubit(this._repo) : super(const ProviderState());

  Future<void> loadAll(int providerId) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final p = await _repo.fetchProvider(providerId);
      emit(state.copyWith(loading: false, provider: p));
      await Future.wait([
        loadRequests(),
        loadReceivedOffers(),
      ]);
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> loadRequests() async {
    emit(state.copyWith(requestsLoading: true, clearRequestsError: true));
    try {
      final list = await _repo.fetchServiceRequests();
      emit(state.copyWith(requestsLoading: false, requests: list));
    } catch (e) {
      emit(
        state.copyWith(
          requestsLoading: false,
          requestsError: e.toString(),
        ),
      );
    }
  }

  Future<void> loadReceivedOffers() async {
    emit(
      state.copyWith(
        receivedOffersLoading: true,
        clearReceivedOffersError: true,
      ),
    );
    try {
      final list = await _repo.fetchMyReceivedOffers();
      emit(
        state.copyWith(
          receivedOffersLoading: false,
          receivedOffers: list,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          receivedOffersLoading: false,
          receivedOffersError: e.toString(),
        ),
      );
    }
  }

  /// ❌ هذه هي التي كانت تسبّب 403 (لا صلاحية)
  /// يفضّل عدم استدعائها من واجهة المزوّد، وترك تغيير حالة الطلب لصاحب الطلب (العميل)
  Future<void> updateRequestStatus(int requestId, String newStatus) async {
    emit(
      state.copyWith(
        isUpdating: true,
        actingRequestId: requestId,
        updateSuccess: false,
        clearRequestsError: true,
      ),
    );
    try {
      await _repo.updateRequestStatus(requestId, newStatus);

      final updated = state.requests.map((r) {
        if (r.id == requestId) {
          return ServiceRequest(
            id: r.id,
            description: r.description,
            status: newStatus,
            createdAt: r.createdAt,
            user: r.user,
            city: r.city,
          );
        }
        return r;
      }).toList();

      emit(
        state.copyWith(
          isUpdating: false,
          actingRequestId: null,
          requests: updated,
          updateSuccess: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          actingRequestId: null,
          requestsError: e.toString(),
        ),
      );
    }
  }

  /// 👉 الجديد: المزوّد يقدّم عرض (Submit) على طلب
  Future<bool> submitOffer({
    required int requestId,
    required num price,
    String? message,
  }) async {
    emit(
      state.copyWith(
        isUpdating: true,
        actingRequestId: requestId,
        clearRequestsError: true,
      ),
    );
    try {
      await _repo.submitOffer(
        requestId: requestId,
        price: price,
        message: message,
      );

      emit(
        state.copyWith(
          isUpdating: false,
          actingRequestId: null,
          updateSuccess: true,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          actingRequestId: null,
          requestsError: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<void> acceptRequest(int requestId) =>
      updateRequestStatus(requestId, 'completed');

  Future<void> rejectRequest(int requestId) =>
      updateRequestStatus(requestId, 'cancelled');

  void ackUpdateSuccess() => emit(state.copyWith(updateSuccess: false));
  void clearRequestsError() => emit(state.copyWith(clearRequestsError: true));
  void clearReceivedOffersError() =>
      emit(state.copyWith(clearReceivedOffersError: true));
}