import 'package:mushtary/core/api/api_constants.dart';
import 'package:mushtary/core/api/api_service.dart' as api;

import '../model/conversation_report_models.dart';

class ConversationReportRepo {
  final api.ApiService _api;
  ConversationReportRepo(this._api);

  Future<ConversationReportResponse> createReport({
    required int conversationId,
    required ConversationReportRequest request,
  }) async {
    final map = await _api.post(
      ApiConstants.conversationReport(conversationId),
      request.toJson(),
    );
    return ConversationReportResponse.fromJson(map);
  }
}