import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SendMessageResult {
  final bool acked;
  final dynamic ackData;
  SendMessageResult({required this.acked, this.ackData});
}

class ChatSocketService {
  final String? Function()? tokenProvider;
  // مثال: '87.237.225.78:8888'
  final String host;

  /// '/' للسيرفر عندك
  final String path;

  /// true => https/wss (لو معاك دومين + SSL)، false => http/ws
  final bool secure;

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

    final token = tokenProvider?.call();
    if (token == null || token.isEmpty) {
      throw Exception('No token found for WebSocket');
    }

    final pathToUse = _normalizePath(path);

    try {
      _socket?.disconnect();
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
    _connected = false;

    final opts = IO.OptionBuilder()
        .setTransports(['websocket'])            // مهم: WebSocket فقط
        .setPath(pathToUse)                      // '/'
        .setQuery({'token': token})              // فقط token (لا تضيف EIO)
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
      if (!completer.isCompleted) completer.complete();
    });

    s.onConnectError((err) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('connect_error: $err'));
      }
    });

    s.onDisconnect((_) => _connected = false);
    s.onError((_) {});

    // استقبال
    s.on('newMessage', (data) => _incomingController.add(_toMap(data)));
    s.on('messageCreated', (data) => _incomingController.add(_toMap(data)));

    s.connect();

    await completer.future.timeout(
      connectTimeout,
      onTimeout: () => throw TimeoutException('Socket.IO connect timeout (path: $pathToUse)'),
    );
  }

  // Ack كـ Object (مش Array)
  Future<dynamic> emitWithAck(
      String event,
      Map<String, dynamic> payload, {
        Duration timeout = const Duration(seconds: 20),
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

  // ============ Events ============

  Future<dynamic> getUserChatRooms(int userId) {
    return emitWithAck('getUserChatRooms', {
      'user_id': userId,
      'userId': userId,
    });
  }

  Future<dynamic> getMessages(int chatId) {
    return emitWithAck('getMessages', {
      'chat_id': chatId.toString(), // Postman
    });
  }

  Future<dynamic> getConversationMessages(int conversationId) {
    return getMessages(conversationId);
  }

  Future<dynamic> initiateChat(int senderId, int receiverId) {
    return emitWithAck('initiateChat', {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'senderId': senderId,
      'receiverId': receiverId,
    });
  }

  // مطابق لـ Postman
  Future<SendMessageResult> sendMessageSmart({
    required int chatId,
    required int senderId,
    required int receiverId,
    required String content,
    String messageType = 'text',
    int? repliedToId,
    Duration ackTimeout = const Duration(seconds: 5),
  }) async {
    final payload = {
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message_type': messageType,
      'content': content,
      'replied_to_id': repliedToId, // null is fine
    };

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
  }) {
    return emitWithAck('markMessageAsRead', {
      'chat_id': chatId.toString(),
      'user_id': userId.toString(),
    });
  }

  // بناء على لقطة الشاشة
  Future<void> joinAuction({required int auctionId, required String auctionType}) async {
    await emitNoAck('joinAuction', {
      'auctionId': auctionId,
      'auction_type': auctionType,
    });
  }

  Stream<Map<String, dynamic>> get incomingMessagesStream =>
      _incomingController.stream;

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