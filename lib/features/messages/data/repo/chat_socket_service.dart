import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../../core/auth/auth_coordinator.dart';
import '../../../../core/dependency_injection/injection_container.dart';

class SendMessageResult {
  final bool acked;
  final dynamic ackData;
  SendMessageResult({required this.acked, this.ackData});
}

class ChatSocketService {
  final String? Function()? tokenProvider;
  final String host; // مثال: 87.237.225.78:8888
  final String path; // مثال: '/socket.io'
  final bool secure; // true => https
  final Duration connectTimeout;

  IO.Socket? _socket;
  bool _connected = false;

  final _incomingController = StreamController<Map<String, dynamic>>.broadcast();

  ChatSocketService({
    required this.tokenProvider,
    required this.host,
    this.path = '/',
    this.secure = false,
    this.connectTimeout = const Duration(seconds: 12),
  });

  bool get isConnected => _connected;
  String get _baseUrl => '${secure ? 'https' : 'http'}://$host';

  String _normalizePath(String p) {
    var n = p.trim();
    if (n.isEmpty) n = '/';
    if (!n.startsWith('/')) n = '/$n';
    if (n.length > 1 && n.endsWith('/')) n = n.substring(0, n.length - 1);
    return n;
  }

  Future<void> ensureConnected() async {
    if (_connected) return;

    String? token = tokenProvider?.call();
    if (token == null || token.isEmpty) {
      try {
        final auth = getIt<AuthCoordinator>();
        final newToken = await auth.ensureTokenInteractive();
        if (newToken == null || newToken.isEmpty) {
          throw Exception('Authentication cancelled or failed');
        }
        token = newToken;
      } catch (e) {
        debugPrint('🔴 ChatSocketService auth failed: $e');
        rethrow;
      }
    }

    final pathToUse = _normalizePath(path);

    try {
      _socket?.disconnect();
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
    _connected = false;

    final opts = IO.OptionBuilder()
        .setTransports(['websocket'])
        .setPath(pathToUse)
        .setQuery({'token': token})
        .disableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(5)
        .setReconnectionDelay(800)
        .setTimeout(connectTimeout.inMilliseconds)
        .enableForceNew()
        .build();

    final completer = Completer<void>();
    final s = IO.io(_baseUrl, opts);
    _socket = s;

    s.onConnect((_) {
      _connected = true;
      debugPrint('🟢 ChatSocketService: Connected');
      if (!completer.isCompleted) completer.complete();
    });
    s.onConnectError((err) {
      final e = 'connect_error: $err';
      debugPrint('🔴 $e');
      if (!completer.isCompleted) completer.completeError(Exception(e));
    });
    s.onDisconnect((_) => _connected = false);
    s.onError((e) => debugPrint('🔴 socket error: $e'));

    for (final ev in [
      'newMessage','messageCreated','message','chatMessage',
      'new_message','message:created','chat:new_message',
    ]) {
      s.on(ev, (data) {
        debugPrint('📡 socket event: $ev');
        _incomingController.add(_toMap(data));
      });
    }

    s.connect();

    await completer.future.timeout(
      connectTimeout,
      onTimeout: () => throw TimeoutException('Socket connect timeout'),
    );
  }

  Future<void> joinChat(int chatId) async {
    await ensureConnected();
    final p = {'chat_id': chatId.toString(), 'chatId': chatId, 'room': 'chat:$chatId'};
    _socket!.emit('joinChat', p);
    _socket!.emit('subscribeChat', p);
    _socket!.emit('join_room', p);
    _socket!.emit('join', p);
    debugPrint('🔗 socket join chat $chatId');
  }

  Future<void> leaveChat(int chatId) async {
    if (!_connected) return;
    final p = {'chat_id': chatId.toString(), 'chatId': chatId, 'room': 'chat:$chatId'};
    _socket!.emit('leaveChat', p);
    _socket!.emit('unsubscribeChat', p);
    _socket!.emit('leave_room', p);
    _socket!.emit('leave', p);
    debugPrint('🔌 socket leave chat $chatId');
  }

  Future<dynamic> emitWithAck(
      String event,
      Map<String, dynamic> payload, {
        Duration timeout = const Duration(seconds: 25),
      }) async {
    await ensureConnected();
    final c = Completer<dynamic>();
    _socket!.emitWithAck(event, payload, ack: (data) {
      if (!c.isCompleted) c.complete(data);
    });
    return c.future.timeout(timeout, onTimeout: () {
      throw TimeoutException('Ack timeout for $event');
    });
  }

  Future<void> emitNoAck(String event, Map<String, dynamic> payload) async {
    await ensureConnected();
    _socket!.emit(event, payload);
  }

  Future<dynamic> getUserChatRooms(int userId) =>
      emitWithAck('getUserChatRooms', {'user_id': userId.toString()});

  // تعديل: دعم pagination مع beforeId, afterId, limit
  Future<dynamic> getConversationMessages(
      int conversationId, {
        int? beforeId,  // لجلب الرسائل قبل هذا ID (pagination للقديمة)
        int? afterId,   // لجلب الرسائل بعد هذا ID (للجديدة في polling)
        int limit = 20, // حد افتراضي للعدد
      }) async {
    final payload = <String, dynamic>{
      'chat_id': conversationId.toString(),
      'chatId': conversationId,
      if (beforeId != null) 'before_id': beforeId,
      if (afterId != null) 'after_id': afterId,
      'limit': limit,
    };
    debugPrint('📡 getConversationMessages: chatId=$conversationId, beforeId=$beforeId, afterId=$afterId, limit=$limit');
    return emitWithAck('getMessages', payload);  // أو 'getConversationMessages' إذا كان الـ event مختلف
  }

  Future<dynamic> getMessages(int chatId) =>
      emitWithAck('getMessages', {'chat_id': chatId.toString()});

  Future<dynamic> initiateChat(int senderId, int receiverId) =>
      emitWithAck('initiateChat', {'senderId': senderId, 'receiverId': receiverId});

  Future<SendMessageResult> sendMessageSmart({
    required int chatId,
    required int senderId,
    required int receiverId,
    required String content,
    required String messageType, // text/image/audio/file/voice
    int? repliedToId,
    int? listingId,
    Duration ackTimeout = const Duration(seconds: 30),
  }) async {
    final normalizedType = (messageType.toLowerCase() == 'voice') ? 'audio' : messageType;
    final payload = <String, dynamic>{
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message_type': normalizedType,
      'content': content,
      'replied_to_id': repliedToId,
      if (listingId != null) 'listing_id': listingId,
    };
    final pv = content.substring(0, content.length.clamp(0, 50));
    debugPrint('📤 Socket send: type=$normalizedType, chatId=$chatId, preview=$pv');

    try {
      final ack = await emitWithAck('sendMessage', payload, timeout: ackTimeout);
      return SendMessageResult(acked: true, ackData: ack);
    } on TimeoutException {
      await emitNoAck('sendMessage', payload);
      return SendMessageResult(acked: false);
    }
  }

  Future<dynamic> markMessageAsRead({
    required int chatId,
    required int userId,
    Duration timeout = const Duration(seconds: 25),
  }) =>
      emitWithAck('markMessageAsRead', {
        'chat_id': chatId.toString(),
        'user_id': userId.toString(),
      }, timeout: timeout);

  Stream<Map<String, dynamic>> get incomingMessagesStream => _incomingController.stream;

  Future<void> disconnect() async {
    try {
      _socket?.off('newMessage');
      _socket?.off('messageCreated');
      _socket?.disconnect();
      _socket?.dispose();
    } finally {
      _socket = null;
      _connected = false;
    }
  }

  Future<void> dispose() async {
    await disconnect();
    await _incomingController.close();
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data as Map);
    if (data is String) {
      try {
        final d = jsonDecode(data);
        if (d is Map) return Map<String, dynamic>.from(d);
      } catch (_) {}
    }
    return {'data': data};
  }
}