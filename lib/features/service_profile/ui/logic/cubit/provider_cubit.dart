// lib/features/product_details/ui/logic/cubit/provider_cubit.dart

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
      await loadRequests(); // بعد البروفايل
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
      emit(state.copyWith(requestsLoading: false, requestsError: e.toString()));
    }
  }

  Future<void> updateRequestStatus(int requestId, String newStatus) async {
    // 🟢 بدء التحميل: تعيين isUpdating و actingRequestId
    emit(state.copyWith(
      isUpdating: true,
      actingRequestId: requestId,
      updateSuccess: false,
      clearRequestsError: true,
    ));
    try {
      await _repo.updateRequestStatus(requestId, newStatus);

      // حدّث العنصر محلياً
      final updated = state.requests.map((r) {
        if (r.id == requestId) {
          return ServiceRequest(
            id: r.id,
            description: r.description,
            status: newStatus,
            createdAt: r.createdAt,
            user: r.user,
          );
        }
        return r;
      }).toList();

      // 🟢 النجاح: إعادة تعيين isUpdating و actingRequestId
      emit(state.copyWith(
        isUpdating: false,
        actingRequestId: null,
        requests: updated,
        updateSuccess: true, // للإشارة إلى نجاح العملية في الـ Listener
      ));

    } catch (e) {
      // 🟢 الفشل: إعادة تعيين isUpdating و actingRequestId مع رسالة الخطأ
      emit(state.copyWith(
        isUpdating: false,
        actingRequestId: null,
        requestsError: e.toString(),
      ));
    }
  }
}