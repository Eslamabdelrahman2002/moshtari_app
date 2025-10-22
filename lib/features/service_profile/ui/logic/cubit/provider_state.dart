// lib/features/service_profile/ui/screens/service_provider_dashboard_screen.dart

import 'package:equatable/equatable.dart';
import '../../../data/model/service_provider_models.dart';
import '../../../data/model/service_request_models.dart';

class ProviderState extends Equatable {
  final bool loading;
  final String? error;
  final ServiceProviderModel? provider;
  final bool requestsLoading;
  final String? requestsError;
  final List<ServiceRequest> requests;

  // 🟢 NEW/RENAMED:
  final bool isUpdating;
  final bool updateSuccess;
  final int? actingRequestId; // 🟢 NEW: لتتبع الطلب الذي يتم تحديث حالته حاليًا

  const ProviderState({
    this.loading = false,
    this.error,
    this.provider,
    this.requestsLoading = false,
    this.requestsError,
    this.requests = const [],
    this.isUpdating = false, // 🟢 RENAMED (كانت updating)
    this.updateSuccess = false,
    this.actingRequestId, // 🟢 NEW
  });

  ProviderState copyWith({
    bool? loading,
    String? error,
    ServiceProviderModel? provider,
    bool? requestsLoading,
    String? requestsError,
    List<ServiceRequest>? requests,

    // 🟢 NEW/RENAMED in copyWith:
    bool? isUpdating,
    bool? updateSuccess,
    int? actingRequestId, // 🟢 NEW

    bool clearError = false,
    bool clearRequestsError = false,
  }) {
    return ProviderState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      provider: provider ?? this.provider,
      requestsLoading: requestsLoading ?? this.requestsLoading,
      requestsError: clearRequestsError ? null : (requestsError ?? this.requestsError),
      requests: requests ?? this.requests,

      // 🟢 Assignments:
      isUpdating: isUpdating ?? this.isUpdating,
      updateSuccess: updateSuccess ?? this.updateSuccess,
      actingRequestId: actingRequestId, // نحتاج لجعله يقبل null صراحة لتمكين إلغاء تعيينه
    );
  }

  @override
  List<Object?> get props => [
    loading, error, provider, requestsLoading, requestsError, requests,
    isUpdating, updateSuccess, actingRequestId
  ];
}