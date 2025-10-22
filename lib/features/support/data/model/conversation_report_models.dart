import 'dart:convert';

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.tryParse('$v');
  } catch (_) {
    return null;
  }
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse('$v') ?? 0;
}

class ConversationReportRequest {
  final String reason;
  ConversationReportRequest({required this.reason});

  Map<String, dynamic> toJson() => {'reason': reason};
}

class ConversationReportData {
  final int id;
  final int conversationId;
  final int reporterId;
  final String reason;
  final DateTime? createdAt;

  ConversationReportData({
    required this.id,
    required this.conversationId,
    required this.reporterId,
    required this.reason,
    required this.createdAt,
  });

  factory ConversationReportData.fromJson(Map<String, dynamic> j) {
    return ConversationReportData(
      id: _asInt(j['id']),
      conversationId: _asInt(j['conversation_id']),
      reporterId: _asInt(j['reporter_id']),
      reason: (j['reason'] ?? '').toString(),
      createdAt: _asDate(j['created_at']),
    );
  }
}

class ConversationReportResponse {
  final bool success;
  final String message;
  final ConversationReportData? data;

  ConversationReportResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ConversationReportResponse.fromJson(Map<String, dynamic> j) {
    return ConversationReportResponse(
      success: j['success'] == true || j['status'] == true,
      message: (j['message'] ?? j['msg'] ?? '').toString(),
      data: j['data'] is Map<String, dynamic>
          ? ConversationReportData.fromJson(j['data'] as Map<String, dynamic>)
          : null,
    );
  }

  static ConversationReportResponse fromRaw(String raw) =>
      ConversationReportResponse.fromJson(json.decode(raw));
}