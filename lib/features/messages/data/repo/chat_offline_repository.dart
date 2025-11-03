import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:mushtary/features/messages/data/models/chat_model.dart' as rm;

import '../local/chat_local_data_source.dart';
import 'messages_repo.dart';

class ChatOfflineRepository {
  final ChatLocalDataSource local;
  final MessagesRepo remote;
  final Connectivity connectivity;

  ChatOfflineRepository({
    required this.local,
    required this.remote,
    required this.connectivity,
  });

  StreamSubscription? _incomingSub;

  Future<String> _key({int? conversationId, int? partnerId}) =>
      local.computeConvoKey(conversationId: conversationId, partnerId: partnerId);

  Future<bool> _isOnline() async {
    final res = await connectivity.checkConnectivity();
    return res == ConnectivityResult.mobile || res == ConnectivityResult.wifi;
  }

  static String? _asString(dynamic v) => v?.toString();

  Future<void> initConversation({
    int? conversationId,
    int? partnerId,
    String? partnerName,
    String? partnerAvatar,
  }) async {
    await local.ensureIndexes();
    final k = await _key(conversationId: conversationId, partnerId: partnerId);
    final exist = await local.getConversationByKey(k);
    if (exist == null) {
      await local.upsertConversation(LocalConversation(
        convoKey: k,
        conversationId: conversationId,
        peerId: partnerId ?? 0,
        peerName: _asString(partnerName) ?? 'مستخدم',
        peerAvatar: _asString(partnerAvatar),
        lastMessage: null,
        lastTime: null,
        lastSync: null,
      ));
    }
  }

  Stream<List<LocalMessage>> watchMessagesLocal({int? conversationId, int? partnerId}) async* {
    final k = await _key(conversationId: conversationId, partnerId: partnerId);
    // debugPrint('👀 watch key=$k');
    yield* local.watchMessages(k);
  }

  // بريدج السوكيت → SQLite
  void startIncomingBridge({required int meId, int? currentConversationId}) {
    _incomingSub?.cancel();
    _incomingSub = remote.incomingMessages().listen((m) async {
      try {
        final partnerId = (m.senderId == meId) ? (m.receiverId ?? 0) : (m.senderId ?? 0);
        final convId = m.conversationId ?? currentConversationId;
        final k = await _key(conversationId: convId, partnerId: partnerId);

        final lm = LocalMessage.fromRemote(m, k, meId);
        await local.upsertRemoteMessage(lm);

        if (convId != null && convId > 0) {
          await local.updateConversationIdForKey(k, convId);
        }

        await local.refreshByKey(k);
        // debugPrint('📥 Bridge processed key=$k (convId=$convId)');
      } catch (e) {
        debugPrint('❌ Bridge error: $e');
      }
    }, onError: (e) {
      debugPrint('❌ Incoming stream error: $e');
    });
  }

  Future<void> disposeIncomingBridge() async {
    await _incomingSub?.cancel();
    _incomingSub = null;
  }

  // ✅ إضافة الدالة المطلوبة: قراءة الرسائل محليًا وعبر السيرفر
  Future<void> markConversationAsRead(int conversationId) async {
    try {
      await local.markAllAsRead(conversationId);
      await remote.markAsRead(conversationId);
      debugPrint('✅ OfflineRepo: Marked local/remote conversation $conversationId as read.');
    } catch (e) {
      debugPrint('⚠️ OfflineRepo: Failed to mark conversation $conversationId as read: $e');
    }
  }

  // ❌ حذف دالة _shouldSync واستبدال المنطق لضمان الجلب دائماً
  Future<void> syncFromRemote({
    required int conversationId,
    required int meId,
    bool force = true, // ✅ دائماً نعتبر القيمة force=true عند الدخول
  }) async {
    final k = await _key(conversationId: conversationId);

    // ⚠️ إزالة جميع منطق فحص shouldSync وتخطي الجلب
    debugPrint('🚨 SyncCheck: Force=true. Proceeding to fetch data.');

    try {
      debugPrint('🔄 OfflineRepo: WS GET - fetching messages for convId=$conversationId (Force: Always True)');
      final remoteMsgs = await remote.getConversationMessages(conversationId);
      debugPrint('📥 OfflineRepo: WS GET - received ${remoteMsgs.length} messages from server');

      if (remoteMsgs.isNotEmpty) {
        final localList = remoteMsgs.map<LocalMessage>((m) => LocalMessage.fromRemote(m, k, meId)).toList();
        await local.upsertMessagesSmart(localList);
        await local.updateLastSync(k, DateTime.now());
        await local.refreshByKey(k);
        debugPrint('✅ OfflineRepo: WS GET - upserted ${localList.length} messages');
      } else {
        await local.updateLastSync(k, DateTime.now());
        debugPrint('⚠️ OfflineRepo: WS GET - no remote messages found (Sync time updated)');
      }
    } catch (e) {
      debugPrint('❌ OfflineRepo: WS GET syncFromRemote failed: $e');
    }
  }

  bool _looksLikeFilePath(String data) {
    return data.startsWith('/') ||
        data.startsWith('file://') ||
        data.contains('storage/emulated') ||
        data.contains('\\') ||
        data.endsWith('.m4a') ||
        data.endsWith('.aac') ||
        data.endsWith('.jpg') ||
        data.endsWith('.jpeg') ||
        data.endsWith('.png') ||
        data.endsWith('.webp');
  }

  Future<String> _encodeFile(String path) async {
    final file = File(path);
    if (!await file.exists()) throw Exception('File not found: $path');
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<int> _createConversationIfNeeded(int partnerId) async {
    try {
      final newConvId = await remote.initiateChat(partnerId);
      if (newConvId != null) {
        await initConversation(conversationId: newConvId, partnerId: partnerId);
        debugPrint('✅ Created new convo ID: $newConvId');
      }
      return newConvId ?? 0;
    } catch (e) {
      debugPrint('❌ Failed to create convo: $e');
      return 0;
    }
  }

  Future<void> sendMessageWithWS({
    required int meId,
    int? conversationId,
    required int partnerId,
    required String content,
    required String messageType,
    int? adId,
  }) async {
    String payload = content;

    // تجهيز المحتوى للملفات
    if ((messageType == 'voice' || messageType == 'audio' || messageType == 'image' || messageType == 'file') &&
        _looksLikeFilePath(content)) {
      try {
        payload = await _encodeFile(content);
        debugPrint('✅ File encoded to Base64 (type: $messageType, length: ${payload.length})');
      } catch (e) {
        final key = await _key(conversationId: conversationId, partnerId: partnerId);
        await local.insertMessage(LocalMessage(
          id: null,
          serverId: null,
          conversationId: conversationId,
          convoKey: key,
          senderId: meId,
          receiverId: partnerId,
          content: content,
          messageType: messageType,
          createdAt: DateTime.now(),
          status: 'failed',
          isMine: true,
          adId: adId,
        ));
        rethrow;
      }
    }

    final key = await _key(conversationId: conversationId, partnerId: partnerId);
    final convId = conversationId ?? await _createConversationIfNeeded(partnerId);

    // اربط convId بالمفتاح الحالي لو اتولد جديد
    if (convId > 0) {
      await local.updateConversationIdForKey(key, convId);
    }

    // 1) إدراج Pending محليًا
    final localId = await local.insertMessage(LocalMessage(
      id: null,
      serverId: null,
      conversationId: convId > 0 ? convId : null,
      convoKey: key,
      senderId: meId,
      receiverId: partnerId,
      content: payload,
      messageType: messageType,
      createdAt: DateTime.now(),
      status: 'pending',
      isMine: true,
      adId: adId,
    ));
    debugPrint('💾 Inserted pending localId=$localId key=$key convId=$convId');

    try {
      // 2) إرسال عبر السوكيت
      final body = rm.SendMessageRequestBody(
        receiverId: partnerId,
        messageContent: payload,
        listingId: adId,
        messageType: messageType,
      );
      final msgId = await remote.sendMessage(body, (convId > 0 ? convId : 0));

      // 3) تحديث نفس السطر
      if (msgId != null) {
        await local.updateMessageStatus(localId, 'sent', serverId: msgId);
      } else {
        await local.updateMessageStatus(localId, 'sent');
      }
      await local.refreshByKey(key);
      debugPrint('✅ OfflineRepo: WS POST - message sent to server (localId=$localId, msgId=$msgId)');
    } catch (e) {
      debugPrint('⚠️ OfflineRepo: WS POST failed: $e');
      await local.updateMessageStatus(localId, 'failed');
      await local.refreshByKey(key);
      rethrow;
    }
  }

  Future<void> sendMessage({
    required int meId,
    int? conversationId,
    required int partnerId,
    required String content,
    required String messageType,
    int? adId,
  }) async {
    await sendMessageWithWS(
      meId: meId,
      conversationId: conversationId,
      partnerId: partnerId,
      content: content,
      messageType: messageType,
      adId: adId,
    );
  }

  Future<void> _trySendPending({int maxRetries = 3}) async {
    final online = await _isOnline();
    if (!online) {
      debugPrint('📶 Offline - skipping pending send');
      return;
    }

    final pendings = await local.getPendingMessages();
    debugPrint('📤 Pending count: ${pendings.length}');

    for (final m in pendings) {
      int retry = 0;
      bool success = false;
      while (retry < maxRetries && !success) {
        try {
          final convId = m.conversationId ?? await _createConversationIfNeeded(m.receiverId);
          final body = rm.SendMessageRequestBody(
            receiverId: m.receiverId,
            messageContent: m.content,
            listingId: m.adId,
            messageType: m.messageType,
          );
          final msgId = await remote.sendMessage(body, convId);
          if (m.id != null) {
            await local.updateMessageStatus(m.id!, 'sent', serverId: msgId);
          }
          success = true;
          await local.refreshByKey(m.convoKey);
          debugPrint('✅ Pending sent: ${m.id}');
        } catch (e) {
          retry++;
          debugPrint('❌ Pending retry $retry/$maxRetries failed: $e');
          if (retry >= maxRetries && m.id != null) {
            await local.updateMessageStatus(m.id!, 'failed');
            await local.refreshByKey(m.convoKey);
          } else {
            await Future.delayed(Duration(seconds: retry * 2));
          }
        }
      }
    }
  }

  Future<void> syncPendingNow() => _trySendPending();
}