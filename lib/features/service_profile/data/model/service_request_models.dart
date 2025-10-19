import 'dart:convert';

int _asInt(v) => v is int ? v : int.tryParse('$v') ?? 0;

class ReqUser {
  final int id;
  final String name;
  final String? personalImage;

  ReqUser({required this.id, required this.name, this.personalImage});

  factory ReqUser.fromJson(Map<String, dynamic> j) => ReqUser(
    id: _asInt(j['id']),
    name: (j['name'] ?? '').toString(),
    personalImage: (j['personal_image'] ?? '').toString().isEmpty ? null : (j['personal_image'] as String),
  );
}

class ServiceRequest {
  final int id;
  final String description;
  final String status; // pending | in_progress | completed | rejected ...
  final DateTime? createdAt;
  final ReqUser? user;

  ServiceRequest({
    required this.id,
    required this.description,
    required this.status,
    required this.createdAt,
    this.user,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> j) => ServiceRequest(
    id: _asInt(j['id']),
    description: (j['description'] ?? j['comment'] ?? '').toString(),
    status: (j['status'] ?? 'pending').toString(),
    createdAt: j['created_at'] != null ? DateTime.tryParse('${j['created_at']}') : null,
    user: j['user'] is Map<String, dynamic> ? ReqUser.fromJson(j['user']) : null,
  );
}

class ServiceRequestsResponse {
  final bool success;
  final List<ServiceRequest> data;

  ServiceRequestsResponse({required this.success, required this.data});

  factory ServiceRequestsResponse.fromJson(Map<String, dynamic> j) {
    final list = <ServiceRequest>[];
    if (j['data'] is List) {
      for (final e in (j['data'] as List)) {
        list.add(ServiceRequest.fromJson(e));
      }
    }
    return ServiceRequestsResponse(success: j['success'] == true, data: list);
  }

  static ServiceRequestsResponse fromRaw(String raw) =>
      ServiceRequestsResponse.fromJson(json.decode(raw));
}