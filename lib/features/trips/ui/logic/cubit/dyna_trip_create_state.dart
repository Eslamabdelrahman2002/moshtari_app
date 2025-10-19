import 'package:equatable/equatable.dart';

class DynaTripCreateState extends Equatable {
  final bool submitting;
  final bool success;
  final String? error;

  const DynaTripCreateState({
    this.submitting = false,
    this.success = false,
    this.error,
  });

  DynaTripCreateState copyWith({
    bool? submitting,
    bool? success,
    String? error,
  }) {
    return DynaTripCreateState(
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,
    );
  }

  @override
  List<Object?> get props => [submitting, success, error];
}