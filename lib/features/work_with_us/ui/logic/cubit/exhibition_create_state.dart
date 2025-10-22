import 'package:equatable/equatable.dart';

class ExhibitionCreateState extends Equatable {
  final bool submitting;
  final bool success;
  final String? error;
  final int? createdId;

  const ExhibitionCreateState({
    this.submitting = false,
    this.success = false,
    this.error,
    this.createdId,
  });

  ExhibitionCreateState copyWith({
    bool? submitting,
    bool? success,
    String? error,
    bool clearError = false,
    int? createdId,
    bool clearId = false,
  }) {
    return ExhibitionCreateState(
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: clearError ? null : (error ?? this.error),
      createdId: clearId ? null : (createdId ?? this.createdId),
    );
  }

  @override
  List<Object?> get props => [submitting, success, error, createdId];
}