import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'chat_db.dart';

class LocalMessage {
  final int? id;
  final int? serverId;
  final int? conversationId;
  final String convoKey;
  final int senderId;
  final int receiverId;
  final String content;
  final String type; // 'text'
  final DateTime createdAt;
  final String status; // pending/sent/delivered/read/failed
  final bool isMine;
  final int? adId;

  LocalMessage({
    this.id,
    this.serverId,
    this.conversationId,
    required this.convoKey,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.status,
    required this.isMine,
    this.adId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'server_id': serverId,
    'conversation_id': conversationId,
    'convo_key': convoKey,
    'sender_id': senderId,
    'receiver_id': receiverId,
    'content': content,
    'type': type,
    'created_at': createdAt.millisecondsSinceEpoch,
    'status': status,
    'is_mine': isMine ? 1 : 0,
    'ad_id': adId,
  };

  static LocalMessage fromMap(Map<String, dynamic> m) => LocalMessage(
    id: m['id'] as int?,
    serverId: m['server_id'] as int?,
    conversationId: m['conversation_id'] as int?,
    convoKey: m['convo_key'] as String,
    senderId: (m['sender_id'] as num?)?.toInt() ?? 0,
    receiverId: (m['receiver_id'] as num?)?.toInt() ?? 0,
    content: m['content'] as String? ?? '',
    type: m['type'] as String? ?? 'text',
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (m['created_at'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
    ),
    status: m['status'] as String? ?? 'sent',
    isMine: (m['is_mine'] as int?) == 1,
    adId: (m['ad_id'] as num?)?.toInt(),
  );
}

class LocalConversation {
  final int? id;
  final int? conversationId;
  final String convoKey; // 'c:{id}' أو 'u:{partnerId}'
  final int peerId;
  final String peerName;
  final String? peerAvatar;
  final String? lastMessage;
  final DateTime? lastTime;
  final int unreadCount;

  LocalConversation({
    this.id,
    this.conversationId,
    required this.convoKey,
    required this.peerId,
    required this.peerName,
    this.peerAvatar,
    this.lastMessage,
    this.lastTime,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'conversation_id': conversationId,
    'convo_key': convoKey,
    'peer_id': peerId,
    'peer_name': peerName,
    'peer_avatar': peerAvatar,
    'last_message': lastMessage,
    'last_time': lastTime?.millisecondsSinceEpoch,
    'unread_count': unreadCount,
  };

  static LocalConversation fromMap(Map<String, dynamic> m) => LocalConversation(
    id: m['id'] as int?,
    conversationId: m['conversation_id'] as int?,
    convoKey: m['convo_key'] as String,
    peerId: (m['peer_id'] as num?)?.toInt() ?? 0,
    peerName: m['peer_name'] as String? ?? 'مستخدم',
    peerAvatar: m['peer_avatar'] as String?,
    lastMessage: m['last_message'] as String?,
    lastTime: (m['last_time'] as int?) != null
        ? DateTime.fromMillisecondsSinceEpoch(m['last_time'] as int)
        : null,
    unreadCount: (m['unread_count'] as num?)?.toInt() ?? 0,
  );
}

class ChatLocalDataSource {
  final Database db;
  ChatLocalDataSource(this.db);

  final Map<String, StreamController<List<LocalMessage>>> _controllers = {};

  Future<String> computeConvoKey({int? conversationId, int? partnerId}) async {
    if (conversationId != null && conversationId > 0) return 'c:$conversationId';
    if (partnerId != null && partnerId > 0) return 'u:$partnerId';
    throw ArgumentError('conversationId or partnerId must be provided');
  }

  Future<void> upsertConversation(LocalConversation c) async {
    await db.insert('conversations', c.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<LocalConversation?> getConversationByKey(String key) async {
    final res = await db.query('conversations', where: 'convo_key=?', whereArgs: [key], limit: 1);
    return res.isEmpty ? null : LocalConversation.fromMap(res.first);
  }

  Future<void> updateConversationIdForKey(String key, int conversationId) async {
    await db.update('conversations', {'conversation_id': conversationId}, where: 'convo_key=?', whereArgs: [key]);
    await db.update('messages', {'conversation_id': conversationId}, where: 'convo_key=?', whereArgs: [key]);
    await _emit(key: key);
  }

  Future<List<LocalMessage>> getMessagesByKey(String key) async {
    final res = await db.query('messages', where: 'convo_key=?', whereArgs: [key], orderBy: 'created_at DESC');
    return res.map(LocalMessage.fromMap).toList();
  }

  // FIX: نرجع ID للإدراج ونبث التغييرات
  Future<int> insertMessage(LocalMessage m) async {
    final id = await db.insert('messages', m.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await _emit(key: m.convoKey);
    return id;
  }

  Future<void> upsertMessages(List<LocalMessage> msgs) async {
    if (msgs.isEmpty) return;
    final batch = db.batch();
    for (final m in msgs) {
      batch.insert('messages', m.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
    // ابث لكل محادثة مشمولة
    final keys = msgs.map((e) => e.convoKey).toSet();
    for (final k in keys) {
      await _emit(key: k);
    }
  }

  // FIX: احصل على convo_key للإشعار
  Future<void> updateMessageStatus(int localId, String status, {int? serverId}) async {
    final row = await db.query('messages', columns: ['convo_key'], where: 'id=?', whereArgs: [localId], limit: 1);
    await db.update(
      'messages',
      {'status': status, if (serverId != null) 'server_id': serverId},
      where: 'id=?',
      whereArgs: [localId],
    );
    if (row.isNotEmpty) {
      final key = row.first['convo_key'] as String;
      await _emit(key: key);
    }
  }

  Future<List<LocalMessage>> getPendingMessages() async {
    final res = await db.query(
      'messages',
      where: 'status IN ("pending","failed")',
      orderBy: 'created_at ASC',
      limit: 100,
    );
    return res.map(LocalMessage.fromMap).toList();
  }

  Stream<List<LocalMessage>> watchMessages(String key) {
    _controllers.putIfAbsent(key, () => StreamController.broadcast());
    getMessagesByKey(key).then((m) => _controllers[key]?.add(m));
    return _controllers[key]!.stream;
  }

  Future<void> _emit({required String key}) async {
    if (_controllers.containsKey(key)) {
      final msgs = await getMessagesByKey(key);
      _controllers[key]!.add(msgs);
    }
  }
}