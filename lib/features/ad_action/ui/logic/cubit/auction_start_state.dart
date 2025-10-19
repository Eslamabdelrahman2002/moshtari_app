class AuctionStartState {
  final bool submitting;
  final bool success;
  final String? error;
  final String? serverMessage;

  const AuctionStartState({
    this.submitting = false,
    this.success = false,
    this.error,
    this.serverMessage,
  });

  AuctionStartState copyWith({
    bool? submitting,
    bool? success,
    String? error,
    String? serverMessage,
  }) {
    return AuctionStartState(
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,
      serverMessage: serverMessage,
    );
  }
}