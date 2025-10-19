import '../../data/model/service_provider_model.dart';

class ServiceProvidersState {
  final bool loading;
  final List<ServiceProviderModel> items;
  final String? error;

  const ServiceProvidersState({
    this.loading = false,
    this.items = const [],
    this.error,
  });

  ServiceProvidersState copyWith({
    bool? loading,
    List<ServiceProviderModel>? items,
    String? error,
  }) {
    return ServiceProvidersState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      error: error,
    );
  }
}