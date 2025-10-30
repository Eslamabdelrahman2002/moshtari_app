// file: notification_model.dart

class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String body;
  final String type;
  final String screen;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.screen,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // استخراج الخريطة المتداخلة 'data' بأمان
    final nestedData = json['data'] as Map<String, dynamic>?;

    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      // 'type' موجود مباشرة في الجذر
      type: json['type'] as String? ?? '',
      // 'screen' موجود ضمن 'data'
      screen: nestedData?['screen'] as String? ?? '',
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // دالة copyWith لتحديث حالة isRead في Cubit
  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      screen: screen,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

class NotificationsResponse {
  final bool success;
  final List<NotificationModel> data;

  NotificationsResponse({required this.success, required this.data});

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}