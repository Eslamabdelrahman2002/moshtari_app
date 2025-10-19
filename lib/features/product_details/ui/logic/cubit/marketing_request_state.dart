class MarketingRequestState {
  final bool submitting;
  final bool success;
  final String? error;
  final String? serverMessage;

  const MarketingRequestState({
    this.submitting = false,
    this.success = false,
    this.error,
    this.serverMessage,
  });

  MarketingRequestState copyWith({
    bool? submitting,
    bool? success,
    String? error,
    String? serverMessage,
  }) {
    return MarketingRequestState(
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,
      serverMessage: serverMessage,
    );
  }
}