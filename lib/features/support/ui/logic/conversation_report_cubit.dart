import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/conversation_report_models.dart';
import '../../data/repo/conversation_report_repo.dart';
import 'conversation_report_state.dart';

class ConversationReportCubit extends Cubit<ConversationReportState> {
  final ConversationReportRepo _repo;
  ConversationReportCubit(this._repo) : super(const ConversationReportState());

  Future<void> submit({
    required int conversationId,
    required String reason,
  }) async {
    emit(state.copyWith(submitting: true, success: false, clearError: true, clearReport: true));
    try {
      final res = await _repo.createReport(
        conversationId: conversationId,
        request: ConversationReportRequest(reason: reason),
      );
      if (!res.success) {
        throw Exception(res.message.isNotEmpty ? res.message : 'تعذر إنشاء البلاغ');
      }
      emit(state.copyWith(submitting: false, success: true, report: res.data));
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(submitting: false, success: false, error: msg));
    }
  }

  void reset() => emit(const ConversationReportState());
}