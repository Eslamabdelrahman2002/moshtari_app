// lib/features/messages/data/models/chat_model.dart

bool _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }
  return false;
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

int toIntSafe(dynamic v, {int fallback = 0}) {
  final n = _asInt(v);
  return n ?? fallback;
}

String? _asString(dynamic v) => v?.toString();

class UserModel {
  final int? id;
  final String? name;
  final String? profileImage;

  UserModel({this.id, this.name, this.profileImage});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: _asInt(json['id']),
    name: _asString(json['name'] ?? json['username']),
    profileImage: _asString(json['profile_image'] ?? json['avatar'] ?? json['image']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'profile_image': profileImage,
  };
}

class MessagesModel {
  final int? conversationId;
  final UserModel? partnerUser;
  final String? lastMessage;
  final String? lastMessageTime;
  final bool isRead;

  // ✅ أضفنا النوع
  final String? lastMessageType;

  MessagesModel({
    this.conversationId,
    this.partnerUser,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageType, // ✅
    this.isRead = false,
  });

  factory MessagesModel.fromJson(Map<String, dynamic> json) => MessagesModel(
    conversationId: _asInt(json['id'] ??
        json['conversation_id'] ??
        json['conversationId'] ??
        json['chat_id'] ??
        json['chatId']),
    partnerUser: (json['user'] is Map)
        ? UserModel.fromJson(Map<String, dynamic>.from(json['user']))
        : null,
    lastMessage: _asString(json['last_message'] ??
        json['last_message_content'] ??
        json['lastMessage'] ??
        json['content'] ??
        json['message']),
    lastMessageTime: _asString(json['last_message_time'] ??
        json['lastMessageTime'] ??
        json['created_at'] ??
        json['createdAt']),

    // ✅ نقرأ نوع آخر رسالة (لو السيرفر بيرسله)
    lastMessageType: _asString(json['last_message_type'] ??
        json['lastMessageType'] ??
        json['type'] ??
        json['message_type'] ??
        json['messageType']),

    isRead: _asBool(json['is_read'] ?? json['isRead']),
  );

  Map<String, dynamic> toJson() => {
    'id': conversationId,
    'user': partnerUser?.toJson(),
    'last_message': lastMessage,
    'last_message_time': lastMessageTime,
    'last_message_type': lastMessageType, // ✅ نحفظها مع البيانات
    'is_read': isRead,
  };
}

class Message {
  final int? id;
  final int? senderId;
  final int? receiverId;
  final int? conversationId;
  final String? messageContent;
  final String? createdAt;
  final String? messageType;
  final String? lastMessageType;
  Message({
    this.id,
    this.senderId,
    this.lastMessageType,
    this.receiverId,
    this.conversationId,
    this.messageContent,
    this.createdAt,
    this.messageType,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: _asInt(json['id'] ?? json['msg_id'] ?? json['message_id'] ?? json['msgId'] ?? json['messageId']),
    senderId: _asInt(json['sender_id'] ?? json['senderId']),
    receiverId: _asInt(json['receiver_id'] ?? json['receiverId']),
    conversationId: _asInt(json['conversation_id'] ?? json['conversationId'] ?? json['chat_id'] ?? json['chatId']),
    messageContent: _asString(json['message_content'] ?? json['messageContent'] ?? json['content'] ?? json['message']),
    createdAt: _asString(json['created_at'] ?? json['createdAt']),
    messageType: _asString(json['message_type'] ?? json['type'] ?? json['messageType']) ?? 'text',
  );


  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': senderId,
    'receiver_id': receiverId,
    'conversation_id': conversationId,
    'message_content': messageContent,
    'created_at': createdAt,
    'message_type': messageType,
  };

}

class SendMessageRequestBody {
  final int receiverId;
  final String messageContent;
  final int? listingId;
  final String messageType;
  final int? repliedToId;

  SendMessageRequestBody({
    required this.receiverId,
    required this.messageContent,
    this.listingId,
    this.messageType = 'text',
    this.repliedToId,
  });

  Map<String, dynamic> toMap() => {
    'receiver_id': receiverId,
    'message_content': messageContent,
    'message_type': messageType,
    if (listingId != null) 'listing_id': listingId,
    if (repliedToId != null) 'replied_to_id': repliedToId,
  };
}

class AdInfo {
  final int id;
  final String title;
  final String price;
  final String imageUrl;

  AdInfo({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  factory AdInfo.fromJson(Map<String, dynamic> json) => AdInfo(
    id: toIntSafe(json['id']),
    title: _asString(json['title']) ?? '',
    price: _asString(json['price']) ?? '',
    imageUrl: _asString(json['imageUrl'] ?? json['image_url'] ?? json['image']) ?? '',
  );
}