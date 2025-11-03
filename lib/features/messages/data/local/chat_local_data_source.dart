import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mushtary/features/messages/data/models/chat_model.dart' as rm;

class LocalMessage {
  final int? id;
  final int? serverId;
  final int? conversationId;
  final String convoKey;
  final int senderId;
  final int receiverId;
  final String content;
  final String messageType;
  final DateTime createdAt;
  final String status; // pending/sent/failed/...
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
    required this.messageType,
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
    'type': messageType,
    'created_at': createdAt.millisecondsSinceEpoch,
    'status': status,
    'is_mine': isMine ? 1 : 0,
    'ad_id': adId,
  };

  static LocalMessage fromMap(Map<String, dynamic> m) => LocalMessage(
    id: m['id'] as int?,
    serverId: m['server_id'] as int?,
    conversationId: m['conversation_id'] as int?,
    convoKey: m['convo_key'] as String? ?? '',
    senderId: (m['sender_id'] as num?)?.toInt() ?? 0,
    receiverId: (m['receiver_id'] as num?)?.toInt() ?? 0,
    content: m['content'] as String? ?? '',
    messageType: m['type'] as String? ?? 'text',
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (m['created_at'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    ),
    status: m['status'] as String? ?? 'sent',
    isMine: (m['is_mine'] as int?) == 1,
    adId: (m['ad_id'] as num?)?.toInt(),
  );

  static LocalMessage fromRemote(
      rm.Message remote, String convoKey, int meId) {
    return LocalMessage(
      serverId: remote.id,
      conversationId: remote.conversationId,
      convoKey: convoKey,
      senderId: remote.senderId ?? 0,
      receiverId: remote.receiverId ?? 0,
      content: remote.messageContent ?? '',
      messageType: remote.messageType ?? 'text',
      createdAt:
      DateTime.tryParse(remote.createdAt ?? '') ?? DateTime.now(),
      status: 'sent',
      isMine: remote.senderId == meId,
      adId: null,
    );
  }

  rm.Message toMessage() {
    return rm.Message(
      id: serverId,
      senderId: senderId,
      receiverId: receiverId,
      conversationId: conversationId,
      messageContent: content,
      messageType: messageType,
      createdAt: createdAt.toIso8601String(),
    );
  }
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
  final DateTime? lastSync;

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
    this.lastSync,
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
    'last_sync': lastSync?.millisecondsSinceEpoch,
  };

  static LocalConversation fromMap(Map<String, dynamic> m) =>
      LocalConversation(
        id: m['id'] as int?,
        conversationId: m['conversation_id'] as int?,
        convoKey: m['convo_key'] as String? ?? '',
        peerId: (m['peer_id'] as num?)?.toInt() ?? 0,
        peerName: m['peer_name'] as String? ?? 'مستخدم',
        peerAvatar: m['peer_avatar'] as String?,
        lastMessage: m['last_message'] as String?,
        lastTime: (m['last_time'] as int?) != null
            ? DateTime.fromMillisecondsSinceEpoch(
            m['last_time'] as int)
            : null,
        unreadCount: (m['unread_count'] as num?)?.toInt() ?? 0,
        lastSync: (m['last_sync'] as int?) != null
            ? DateTime.fromMillisecondsSinceEpoch(
            m['last_sync'] as int)
            : null,
      );
}

class ChatLocalDataSource {
  // Singleton + static controllers (لتفادي تعدد الـ instances بعد hot reload/DI)
  static ChatLocalDataSource? _instance;
  factory ChatLocalDataSource(Database db) =>
      _instance ??= ChatLocalDataSource._(db);
  ChatLocalDataSource._(this.db);

  final Database db;

  static final Map<String, StreamController<List<LocalMessage>>> _controllers =
  {};

  Future<void> ensureIndexes() async {
    await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_messages_convo_server ON messages(convo_key, server_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_messages_convo_created ON messages(convo_key, created_at);');
  }

  Future<String> computeConvoKey(
      {int? conversationId, int? partnerId}) async {
    if (conversationId != null && conversationId > 0) {
      return 'c:$conversationId';
    }
    if (partnerId != null && partnerId > 0) {
      return 'u:$partnerId';
    }
    throw ArgumentError('conversationId or partnerId must be provided');
  }

  Future<void> upsertConversation(LocalConversation c) async {
    await db.insert('conversations', c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateLastSync(
      String convoKey, DateTime syncTime) async {
    await db.update(
      'conversations',
      {'last_sync': syncTime.millisecondsSinceEpoch},
      where: 'convo_key=?',
      whereArgs: [convoKey],
    );
  }

  // ✅ الدالة الجديدة المطلوبة لـ ChatOfflineRepository.markConversationAsRead
  Future<void> markAllAsRead(int conversationId) async {
    final res = await db.update(
      'conversations',
      {'unread_count': 0},
      where: 'conversation_id=?',
      whereArgs: [conversationId],
    );
    // يمكن هنا استدعاء _emit إذا كان هناك حاجة لتحديث قائمة المحادثات الرئيسية
    if (res > 0) {
      final key = await computeConvoKey(conversationId: conversationId);
      await _emit(key: key);
    }
  }


  Future<LocalConversation?> getConversationByKey(String key) async {
    final res = await db.query('conversations',
        where: 'convo_key=?', whereArgs: [key], limit: 1);
    return res.isEmpty ? null : LocalConversation.fromMap(res.first);
  }

  Future<void> updateConversationIdForKey(
      String key, int conversationId) async {
    await db.update('conversations', {'conversation_id': conversationId},
        where: 'convo_key=?', whereArgs: [key]);
    await db.update('messages', {'conversation_id': conversationId},
        where: 'convo_key=?', whereArgs: [key]);
    await _emit(key: key);
  }

  Future<List<LocalMessage>> getMessagesByKey(String key) async {
    final res = await db.query('messages',
        where: 'convo_key=?',
        whereArgs: [key],
        orderBy: 'created_at ASC, id ASC');
    return res.map<LocalMessage>(LocalMessage.fromMap).toList();
  }

  Future<int> insertMessage(LocalMessage m) async {
    final conflict = (m.serverId != null)
        ? ConflictAlgorithm.replace
        : ConflictAlgorithm.ignore;
    final id = await db.insert('messages', m.toMap(),
        conflictAlgorithm: conflict);
    await _emit(key: m.convoKey);
    return id;
  }

  Future<void> upsertMessages(List<LocalMessage> msgs) async {
    if (msgs.isEmpty) return;
    final batch = db.batch();
    for (final m in msgs) {
      if (m.serverId != null) {
        batch.insert('messages', m.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      } else {
        batch.insert('messages', m.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
    await batch.commit(noResult: true);
    final keys = msgs.map((e) => e.convoKey).toSet();
    for (final k in keys) {
      await _emit(key: k);
    }
  }

  Future<void> upsertMessagesSmart(List<LocalMessage> msgs) async {
    if (msgs.isEmpty) return;
    for (final m in msgs) {
      if (m.serverId != null) {
        await db.insert('messages', m.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      } else {
        final updated = await db.update(
          'messages',
          m.toMap(),
          where:
          'convo_key=? AND sender_id=? AND receiver_id=? AND created_at=? AND content=?',
          whereArgs: [
            m.convoKey,
            m.senderId,
            m.receiverId,
            m.createdAt.millisecondsSinceEpoch,
            m.content
          ],
        );
        if (updated == 0) {
          await db.insert('messages', m.toMap(),
              conflictAlgorithm: ConflictAlgorithm.fail);
        }
      }
    }
    final keys = msgs.map((e) => e.convoKey).toSet();
    for (final k in keys) {
      await _emit(key: k);
    }
  }

  Future<void> upsertRemoteMessage(LocalMessage m) async {
    if (m.serverId == null) {
      await upsertMessagesSmart([m]);
      return;
    }
    final updated = await db.update('messages', m.toMap(),
        where: 'convo_key=? AND server_id=?',
        whereArgs: [m.convoKey, m.serverId]);
    if (updated == 0) {
      await db.insert('messages', m.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await _emit(key: m.convoKey);
  }

  Future<void> attachServerIdByContent({
    required String convoKey,
    required String content,
    required int serverId,
    String status = 'sent',
  }) async {
    final updated = await db.update(
      'messages',
      {'server_id': serverId, 'status': status},
      where: 'convo_key=? AND content=? AND status=?',
      whereArgs: [convoKey, content, 'pending'],
    );
    if (updated > 0) {
      await _emit(key: convoKey);
    }
  }

  Future<void> updateMessageStatus(int localId, String status,
      {int? serverId}) async {
    final row = await db.query('messages',
        columns: ['convo_key'],
        where: 'id=?',
        whereArgs: [localId],
        limit: 1);
    final updates = <String, Object?>{'status': status};
    if (serverId != null) updates['server_id'] = serverId;
    await db.update('messages', updates,
        where: 'id=?', whereArgs: [localId]);
    if (row.isNotEmpty) {
      final key =
          (row.first['convo_key'] as Object?)?.toString() ?? '';
      if (key.isNotEmpty) await _emit(key: key);
    }
  }

  Future<List<LocalMessage>> getPendingMessages() async {
    final res = await db.query(
      'messages',
      where: 'status IN (?,?)',
      whereArgs: ['pending', 'failed'],
      orderBy: 'created_at ASC',
      limit: 100,
    );
    return res.map<LocalMessage>(LocalMessage.fromMap).toList();
  }

  Future<void> updateMessageStatusByContent(
      String convoKey, String content, String status) async {
    await db.update('messages', {'status': status},
        where: 'convo_key=? AND content=?',
        whereArgs: [convoKey, content]);
    await _emit(key: convoKey);
  }

  Future<void> markMessagePending(
      String convoKey, String content) async {
    await db.update('messages', {'status': 'pending'},
        where: 'convo_key=? AND content=?',
        whereArgs: [convoKey, content]);
    await _emit(key: convoKey);
  }

  Future<int> cleanupConversationDuplicates(String convoKey) async {
    final count = await db.rawDelete('''
      DELETE FROM messages 
      WHERE convo_key=? 
        AND id NOT IN (
          SELECT MIN(id) FROM messages 
          WHERE convo_key=? 
          GROUP BY server_id, content, created_at
        )
    ''', [convoKey, convoKey]);
    await _emit(key: convoKey);
    return count;
  }

  Stream<List<LocalMessage>> watchMessages(String key) {
    final controller = _controllers.putIfAbsent(
      key,
          () => StreamController<List<LocalMessage>>.broadcast(
        onListen: () async {
          final init = await getMessagesByKey(key);
          _controllers[key]!.add(init);
        },
      ),
    );
    return controller.stream;
  }

  Future<void> refreshByKey(String key) => _emit(key: key);

  Future<void> _emit({required String key}) async {
    final c = _controllers[key];
    if (c != null && !c.isClosed) {
      final msgs = await getMessagesByKey(key);
      c.add(msgs);
      debugPrint('📢 emit($key) -> Emitted ${msgs.length} messages to stream.');
    }
  }
}