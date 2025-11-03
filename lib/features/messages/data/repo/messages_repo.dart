import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';
import '../../../../core/auth/auth_coordinator.dart';
import '../../../../core/dependency_injection/injection_container.dart';
import '../models/chat_model.dart';
import 'chat_socket_service.dart';

class MessagesRepo {
  final ChatSocketService _chat;
  MessagesRepo(this._chat);

  Future<int> currentUserId() async {
    String? token = CacheHelper.getData(key: 'token') as String?;
    if (token == null || token.isEmpty) {
      final auth = getIt<AuthCoordinator>();
      final newToken = await auth.ensureTokenInteractive();
      if (newToken == null || newToken.isEmpty) throw Exception('User cancelled login');
      token = newToken;
    }
    final payload = JwtDecoder.decode(token!);
    final raw = payload['user_id'] ?? payload['id'] ?? payload['sub'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? (throw Exception('Invalid user_id format'));
    throw Exception('Invalid user_id type');
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
  String? _asString(dynamic v) => v?.toString();

  Future<List<MessagesModel>> getConversations() async {
    final me = await currentUserId();
    final res = await _chat.getUserChatRooms(me);
    List list = const [];
    if (res is Map) {
      final data = res['data'] ?? res;
      if (data is Map && data['chatRooms'] is List) list = data['chatRooms'];
      else if (data is List) list = data;
      else if (res['chatRooms'] is List) list = res['chatRooms'];
    } else if (res is List) list = res;

    return list.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      final userIdInRow = _asInt(m['user_id'] ?? m['userId']);
      final providerIdInRow = _asInt(m['provider_id'] ?? m['providerId']);
      int? partnerId;
      String? partnerName;
      String? partnerImage;
      if (userIdInRow == me) {
        partnerId = providerIdInRow;
        partnerName = _asString(m['provider_name'] ?? m['providerName']);
        partnerImage = _asString(m['provider_image'] ?? m['providerImage']);
      } else {
        partnerId = userIdInRow;
        partnerName = _asString(m['user_name'] ?? m['userName']);
        partnerImage = _asString(m['user_image'] ?? m['userImage']);
      }
      partnerName ??= _asString(m['last_message_sender']);
      return MessagesModel(
        conversationId: _asInt(m['id'] ?? m['chat_id'] ?? m['chatId']),
        partnerUser: UserModel(id: partnerId, name: partnerName, profileImage: partnerImage),
        lastMessage: _asString(m['last_message'] ?? m['last_message_content'] ?? m['content'] ?? m['message']),
        lastMessageTime: _asString(m['last_message_time'] ?? m['created_at']),
        isRead: (m['is_read'] == true || m['isRead'] == true),
      );
    }).toList();
  }

  // تعديل: دعم pagination مع beforeId, afterId, limit
  Future<List<Message>> getConversationMessages(
      int conversationId, {
        int? beforeId,  // لجلب الرسائل قبل هذا ID (pagination للقديمة)
        int? afterId,   // لجلب الرسائل بعد هذا ID (للجديدة في polling)
        int limit = 20, // حد افتراضي للعدد
      }) async {
    // افتراض: _chat.getConversationMessages يقبل هذه الـ params
    // إذا لم يدعم، قم بتعديل الـ socket service هناك
    final res = await _chat.getConversationMessages(
      conversationId,
      beforeId: beforeId,
      afterId: afterId,
      limit: limit,
    );

    List list = const [];
    if (res is Map) {
      final data = res['data'];
      if (data is Map && data['messages'] is List) list = data['messages'];
      else if (res['messages'] is List) list = res['messages'];
      else if (data is List) list = data;
      else if (res['data'] is Map && res['data']['chatMessages'] is List) list = res['data']['chatMessages'];
    } else if (res is List) list = res;

    final messages = list.map((e) => Message.fromJson(Map<String, dynamic>.from(e as Map))).toList();

    // ترتيب صاعد دائمًا (أقدم أولاً)
    messages.sort((a, b) => (a.createdAt ?? '').compareTo(b.createdAt ?? ''));

    return messages;
  }

  // دالة مساعدة للـ polling (جلب الجديدة فقط)
  Future<List<Message>> getNewMessages(int conversationId, int afterId, {int limit = 10}) async {
    return getConversationMessages(conversationId, afterId: afterId, limit: limit);
  }

  Future<int?> initiateChat(int receiverId) async {
    final senderId = await currentUserId();
    final res = await _chat.initiateChat(senderId, receiverId);
    if (res is Map) {
      if (res['success'] == false && res['message'] is String) throw Exception(res['message']!.toString());
      final id =
          res['conversationId'] ??
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

  // يحوّل أي path/URL/dataUrl إلى أنسب فورمات للإرسال (Base64 للملفات)
  Future<String> _encodeIfNeeded({required String content, required String type}) async {
    String data = content;
    final looksLikeFilePath = data.startsWith('/') || data.startsWith('file://') || data.contains('\\') || data.contains('storage/emulated');
    final looksLikeB64 = () {
      final clean = data.trim();
      if (clean.startsWith('data:')) return true;
      if (clean.length < 64) return false;
      return RegExp(r'^[A-Za-z0-9+/]+={0,2}$').hasMatch(clean);
    }();

    if (type == 'image' || type == 'audio' || type == 'voice' || type == 'file') {
      if (data.startsWith('data:')) {
        final idx = data.indexOf(',');
        if (idx != -1) data = data.substring(idx + 1);
      } else if (looksLikeB64) {
        // already base64
      } else if (data.startsWith('http')) {
        // لو السيرفر يقبل URL اتركه كما هو، وإلا حوّله قبل الإرسال.
      } else if (looksLikeFilePath) {
        final f = File(data);
        if (!await f.exists()) throw Exception('File not found at path: $data');
        final bytes = await f.readAsBytes();
        data = base64Encode(bytes);
      }
    }
    return data;
  }

  Future<int?> sendMessage(SendMessageRequestBody body, int conversationId) async {
    final senderId = await currentUserId();
    final contentToSend = await _encodeIfNeeded(content: body.messageContent, type: body.messageType);
    final result = await _chat.sendMessageSmart(
      chatId: conversationId,
      senderId: senderId,
      receiverId: body.receiverId,
      content: contentToSend,
      messageType: body.messageType,
      repliedToId: body.repliedToId,
      listingId: body.listingId,
    );

    if (result.acked && result.ackData is Map) {
      final map = Map<String, dynamic>.from(result.ackData as Map);
      final ok = map['success'] == true || map['ok'] == true || map['status'] == 'ok';
      if (!ok) throw Exception(map['message']?.toString() ?? 'Failed to send');
      try {
        final data = Map<String, dynamic>.from(map['data'] as Map);
        final msg = Map<String, dynamic>.from(data['message'] as Map);
        final mid = msg['msg_id'];
        if (mid is num) return mid.toInt();
        if (mid is String) return int.tryParse(mid);
      } catch (_) {}
    }
    return null;
  }

  Future<void> joinChat(int conversationId) => _chat.joinChat(conversationId);
  Future<void> leaveChat(int conversationId) => _chat.leaveChat(conversationId);

  // Normalize payload من السوكيت
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

      final id = _asInt(payload['id'] ?? payload['msg_id']);
      final conversationId = _asInt(payload['conversation_id'] ?? payload['chat_id'] ?? payload['chatId'] ?? payload['conversationId']);
      final senderId = _asInt(payload['sender_id'] ?? payload['senderId']);
      final receiverId = _asInt(payload['receiver_id'] ?? payload['receiverId']);
      final content = _asString(payload['message'] ?? payload['message_content'] ?? payload['messageContent'] ?? payload['content']);
      final messageType = _asString(payload['message_type'] ?? payload['type'] ?? payload['messageType']) ?? 'text';
      final createdAt = _asString(payload['created_at'] ?? payload['createdAt']) ?? DateTime.now().toIso8601String();

      return Message(
        id: id,
        senderId: senderId,
        receiverId: receiverId,
        conversationId: conversationId,
        messageContent: content,
        messageType: messageType,
        createdAt: createdAt,
      );
    });
  }

  Future<void> markAsRead(int conversationId) async {
    final uid = await currentUserId();
    await _chat.markMessageAsRead(chatId: conversationId, userId: uid, timeout: const Duration(seconds: 10));
  }
}