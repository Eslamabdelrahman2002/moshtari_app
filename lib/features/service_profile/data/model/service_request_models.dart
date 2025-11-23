import 'dart:convert';

int _asInt(v) => v is int ? v : int.tryParse('$v') ?? 0;

/// مدينة الطلب
class ReqCity {
  final String nameAr;
  final String nameEn;

  ReqCity({
    required this.nameAr,
    required this.nameEn,
  });

  factory ReqCity.fromJson(Map<String, dynamic> j) => ReqCity(
    nameAr: (j['name_ar'] ?? '').toString(),
    nameEn: (j['name_en'] ?? '').toString(),
  );
}

/// صاحب الطلب (العميل)
class ReqUser {
  final int id;
  final String name;
  final String? personalImage;
  final String? phone;
  final String? email;

  ReqUser({
    required this.id,
    required this.name,
    this.personalImage,
    this.phone,
    this.email,
  });

  factory ReqUser.fromJson(Map<String, dynamic> j) => ReqUser(
    // يدعم الحقول: id / user_id
    id: _asInt(j['id'] ?? j['user_id']),
    // يدعم الحقول: name / user_name
    name: (j['name'] ?? j['user_name'] ?? '').toString(),
    personalImage: (j['personal_image'] ?? '').toString().isEmpty
        ? null
        : (j['personal_image'] as String),
    // يدعم: phone / user_phone
    phone: (j['user_phone'] ?? j['phone'])?.toString(),
    // يدعم: email / user_email
    email: (j['user_email'] ?? j['email'])?.toString(),
  );
}

/// الطلب نفسه
class ServiceRequest {
  final int id;
  final String description;
  final String status; // pending | in_progress | completed | cancelled ...
  final DateTime? createdAt;
  final ReqUser? user;
  final ReqCity? city;

  ServiceRequest({
    required this.id,
    required this.description,
    required this.status,
    required this.createdAt,
    this.user,
    this.city,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> j) => ServiceRequest(
    id: _asInt(j['id']),
    description: (j['description'] ?? j['comment'] ?? '').toString(),
    status: (j['status'] ?? 'pending').toString(),
    createdAt: j['created_at'] != null
        ? DateTime.tryParse('${j['created_at']}')
        : null,
    user: j['user'] is Map<String, dynamic>
        ? ReqUser.fromJson(j['user'] as Map<String, dynamic>)
        : null,
    city: j['city'] is Map<String, dynamic>
        ? ReqCity.fromJson(j['city'] as Map<String, dynamic>)
        : null,
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
        list.add(ServiceRequest.fromJson(e as Map<String, dynamic>));
      }
    }
    return ServiceRequestsResponse(success: j['success'] == true, data: list);
  }

  static ServiceRequestsResponse fromRaw(String raw) =>
      ServiceRequestsResponse.fromJson(json.decode(raw));
}