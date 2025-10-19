// File: provider_state.dart (التعديل في copyWith)

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
  final bool updating;
  final bool updateSuccess; // <--- تمت الإضافة هنا

  const ProviderState({
    this.loading = false,
    this.error,
    this.provider,
    this.requestsLoading = false,
    this.requestsError,
    this.requests = const [],
    this.updating = false,
    this.updateSuccess = false, // <--- قيمة أولية
  });

  ProviderState copyWith({
    bool? loading,
    String? error,
    ServiceProviderModel? provider,
    bool? requestsLoading,
    String? requestsError,
    List<ServiceRequest>? requests,
    bool? updating,
    bool? updateSuccess, // <--- تمت الإضافة هنا
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
      updating: updating ?? this.updating,
      updateSuccess: updateSuccess ?? false, // <--- التعامل معها هنا
    );
  }

  @override
  List<Object?> get props => [loading, error, provider, requestsLoading, requestsError, requests, updating, updateSuccess];
}