import 'package:equatable/equatable.dart';
import '../../data/model/conversation_report_models.dart';

class ConversationReportState extends Equatable {
  final bool submitting;
  final bool success;
  final String? error;
  final ConversationReportData? report;

  const ConversationReportState({
    this.submitting = false,
    this.success = false,
    this.error,
    this.report,
  });

  ConversationReportState copyWith({
    bool? submitting,
    bool? success,
    String? error,
    bool clearError = false,
    ConversationReportData? report,
    bool clearReport = false,
  }) {
    return ConversationReportState(
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: clearError ? null : (error ?? this.error),
      report: clearReport ? null : (report ?? this.report),
    );
  }

  @override
  List<Object?> get props => [submitting, success, error, report];
}