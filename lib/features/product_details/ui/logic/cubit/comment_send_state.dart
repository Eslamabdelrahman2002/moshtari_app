class CommentSendState {
  final bool submitting;
  final bool success;
  final String? error;

  const CommentSendState({
    this.submitting = false,
    this.success = false,
    this.error,
  });

  CommentSendState copyWith({
    bool? submitting,
    bool? success,
    String? error,
  }) {
    return CommentSendState(
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,
    );
  }
}