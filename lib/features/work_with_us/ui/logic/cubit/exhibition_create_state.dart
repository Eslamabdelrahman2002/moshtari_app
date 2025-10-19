import 'package:equatable/equatable.dart';

class ExhibitionCreateState extends Equatable {
  final bool submitting;
  final bool success;
  final String? error;

  const ExhibitionCreateState({
    this.submitting = false,
    this.success = false,
    this.error,
  });

  ExhibitionCreateState copyWith({
    bool? submitting,
    bool? success,
    String? error,
  }) {
    return ExhibitionCreateState(
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,
    );
  }

  @override
  List<Object?> get props => [submitting, success, error];
}