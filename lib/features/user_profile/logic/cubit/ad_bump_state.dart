class AdBumpState {
  final bool loading;
  final bool success;
  final String? error;

  const AdBumpState({this.loading = false, this.success = false, this.error});

  AdBumpState copyWith({bool? loading, bool? success, String? error}) {
    return AdBumpState(
      loading: loading ?? this.loading,
      success: success ?? this.success,
      error: error,
    );
  }
}