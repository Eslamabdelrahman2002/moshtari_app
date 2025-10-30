import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';
import '../models/messages_model.dart';
import 'chat_socket_service.dart';

class MessagesRepo {
  final ChatSocketService _chat;
  MessagesRepo(this._chat);

  int currentUserId() {
    final token = CacheHelper.getData(key: 'token') as String?;
    if (token == null || token.isEmpty) throw Exception('Not logged in');
    final payload = JwtDecoder.decode(token);
    final dynamic raw = payload['user_id'] ?? payload['id'] ?? payload['sub'];
    if (raw == null) throw Exception('user_id not found in token');
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? (throw Exception('Invalid user_id format'));
    throw Exception('Invalid user_id type');
  }

  Future<List<MessagesModel>> getConversations() async {
    final userId = currentUserId();
    final res = await _chat.getUserChatRooms(userId);

    List list = const [];
    if (res is Map) {
      final data = res['data'] ?? res;
      if (data is Map && data['chatRooms'] is List) {
        list = data['chatRooms'] as List;
      } else if (data is List) {
        list = data;
      } else if (res['chatRooms'] is List) {
        list = res['chatRooms'] as List;
      }
    } else if (res is List) {
      list = res;
    }

    return list.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      final me = userId;
      final userIdInRow = _asInt(m['user_id'] ?? m['userId']);
      final providerIdInRow = _asInt(m['provider_id'] ?? m['providerId']);

      int? partnerId;
      String? partnerName;
      String? partnerImage;

      if (userIdInRow == me) {
        partnerId = providerIdInRow;
        partnerName = m['provider_name']?.toString() ?? m['providerName']?.toString();
        partnerImage = m['provider_image']?.toString() ?? m['providerImage']?.toString();
      } else {
        partnerId = userIdInRow;
        partnerName = m['user_name']?.toString() ?? m['userName']?.toString();
        partnerImage = m['user_image']?.toString() ?? m['userImage']?.toString();
      }

      partnerName ??= m['last_message_sender']?.toString();

      return MessagesModel(
        conversationId: _asInt(m['id'] ?? m['chat_id'] ?? m['chatId']),
        partnerUser: UserModel(
          id: partnerId,
          name: partnerName,
          profileImage: partnerImage,
        ),
        lastMessage: m['last_message']?.toString() ??
            m['last_message_content']?.toString() ??
            m['content']?.toString(),
        lastMessageTime:
        m['last_message_time']?.toString() ?? m['created_at']?.toString(),
        isRead: _asBool(m['is_read'] ?? m['isRead']),
      );
    }).toList();
  }

  Future<List<Message>> getConversationMessages(int conversationId) async {
    final res = await _chat.getConversationMessages(conversationId);
    List list = const [];
    if (res is Map) {
      final data = res['data'];
      if (data is Map && data['messages'] is List) {
        list = data['messages'] as List;
      } else if (res['messages'] is List) {
        list = res['messages'] as List;
      } else if (data is List) {
        list = data;
      } else if (res['data'] is Map && res['data']['chatMessages'] is List) {
        list = res['data']['chatMessages'] as List;
      }
    } else if (res is List) {
      list = res;
    }
    return list.map((e) => Message.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  /// ✅ sendMessage الآن يدعم أنواع متعددة: text / image / file
  Future<void> sendMessage(SendMessageRequestBody body, int conversationId) async {
    final senderId = currentUserId();
    final result = await _chat.sendMessageSmart(
      chatId: conversationId,
      senderId: senderId,
      receiverId: body.receiverId,
      content: body.messageContent,
      messageType: body.messageType ?? 'text',
      repliedToId: body.repliedToId,
    );

    if (result.acked && result.ackData is Map) {
      final m = Map<String, dynamic>.from(result.ackData as Map);
      final ok = m['success'] == true || m['ok'] == true || m['status'] == 'ok';
      if (!ok) {
        final msg = m['message']?.toString() ?? 'فشل إرسال الرسالة';
        throw Exception(msg);
      }
    }
    debugPrint('sendMessage acked=${result.acked}  data=${result.ackData}');
  }

  Stream<Message> incomingMessages() {
    return _chat.incomingMessagesStream.map((e) {
      final map = Map<String, dynamic>.from(e);
      final payload = (map['message'] is Map)
          ? Map<String, dynamic>.from(map['message'])
          : (map['data'] is Map)
          ? Map<String, dynamic>.from(map['data'])
          : (map['content'] is Map)
          ? Map<String, dynamic>.from(map['content'])
          : (map['newMessage'] is Map)
          ? Map<String, dynamic>.from(map['newMessage'])
          : map;
      return Message.fromJson(payload);
    });
  }

  Future<int?> initiateChat(int receiverId) async {
    final senderId = currentUserId();
    final res = await _chat.initiateChat(senderId, receiverId);

    if (res is Map) {
      if (res['success'] == false && res['message'] is String) {
        throw Exception(res['message']!.toString());
      }
      final id = res['conversationId'] ??
          res['id'] ??
          res['chat_id'] ??
          res['chatId'] ??
          (res['data'] is Map
              ? (res['data']['conversationId'] ??
              res['data']['id'] ??
              res['data']['chat_id'] ??
              res['data']['chatId'])
              : null);

      if (id is num) return id.toInt();
      if (id is String) return int.tryParse(id);
    }
    return null;
  }

  Future<void> markAsRead(int conversationId) async {
    final uid = currentUserId();
    await _chat.markMessageAsRead(chatId: conversationId, userId: uid);
  }
}

// Helpers ===================================================
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