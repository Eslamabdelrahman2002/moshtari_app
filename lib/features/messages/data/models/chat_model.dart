// Helpers
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

String? _asString(dynamic v) => v?.toString();

// 1) المستخدم
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

// 2) المحادثة
class MessagesModel {
  final int? conversationId;
  final UserModel? partnerUser;
  final String? lastMessage;
  final String? lastMessageTime;
  final bool isRead;

  MessagesModel({
    this.conversationId,
    this.partnerUser,
    this.lastMessage,
    this.lastMessageTime,
    this.isRead = false,
  });

  factory MessagesModel.fromJson(Map<String, dynamic> json) => MessagesModel(
    conversationId: _asInt(json['id'] ?? json['conversation_id'] ?? json['conversationId'] ?? json['chat_id'] ?? json['chatId']),
    partnerUser: (json['user'] is Map) ? UserModel.fromJson(Map<String, dynamic>.from(json['user'])) : null,
    lastMessage: _asString(json['last_message'] ?? json['last_message_content'] ?? json['lastMessage'] ?? json['content']),
    lastMessageTime: _asString(json['last_message_time'] ?? json['lastMessageTime'] ?? json['created_at'] ?? json['createdAt']),
    isRead: _asBool(json['is_read'] ?? json['isRead']),
  );

  Map<String, dynamic> toJson() => {
    'id': conversationId,
    'user': partnerUser?.toJson(),
    'last_message': lastMessage,
    'last_message_time': lastMessageTime,
    'is_read': isRead,
  };
}

// 3) رسالة
class Message {
  final int? id;
  final int? senderId;
  final int? receiverId;
  final int? conversationId;
  final String? messageContent; // content
  final String? createdAt;

  Message({
    this.id,
    this.senderId,
    this.receiverId,
    this.conversationId,
    this.messageContent,
    this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: _asInt(json['id']),
    senderId: _asInt(json['sender_id'] ?? json['senderId']),
    receiverId: _asInt(json['receiver_id'] ?? json['receiverId']),
    conversationId: _asInt(json['conversation_id'] ?? json['conversationId'] ?? json['chat_id'] ?? json['chatId']),
    messageContent: _asString(json['message_content'] ?? json['messageContent'] ?? json['content']),
    createdAt: _asString(json['created_at'] ?? json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': senderId,
    'receiver_id': receiverId,
    'conversation_id': conversationId,
    'message_content': messageContent,
    'created_at': createdAt,
  };
}

// 4) Body لإرسال رسالة
class SendMessageRequestBody {
  final int receiverId;
  final String messageContent;
  final int? listingId; // اختياري
  final String? messageType; // مثل "text"
  final int? repliedToId;

  SendMessageRequestBody({
    required this.receiverId,
    required this.messageContent,
    this.listingId,
    this.messageType,
    this.repliedToId,
  });

  Map<String, dynamic> toMap() => {
    'receiver_id': receiverId,
    'message_content': messageContent,
    if (listingId != null) 'listing_id': listingId,
    if (messageType != null) 'message_type': messageType,
    if (repliedToId != null) 'replied_to_id': repliedToId,
  };
}

// ==========================================================
// ✅ إضافة موديل بيانات الإعلان ووسائط شاشة الدردشة
// ==========================================================

class AdInfo {
  final int id;
  final String title;
  final String imageUrl;
  final String price;
  final int receiverId;
  final String receiverName;

  AdInfo({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.receiverId,
    required this.receiverName,
  });
}

class ChatScreenArgs {
  final MessagesModel chatModel;
  final AdInfo? adInfo;

  ChatScreenArgs({
    required this.chatModel,
    this.adInfo,
  });
}