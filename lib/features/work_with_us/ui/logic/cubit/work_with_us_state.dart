// features/work_with_us/logic/cubit/work_with_us_state.dart
import 'package:equatable/equatable.dart';

class WorkWithUsState extends Equatable {
  final bool submitting;
  final bool success;
  final String? error;

  const WorkWithUsState({
    this.submitting = false,
    this.success = false,
    this.error,
  });

  WorkWithUsState copyWith({
    bool? submitting,
    bool? success,
    String? error,
  }) {
    return WorkWithUsState(
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,
    );
  }

  @override
  List<Object?> get props => [submitting, success, error];
}