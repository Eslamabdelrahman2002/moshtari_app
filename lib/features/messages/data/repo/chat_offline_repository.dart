import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mushtary/features/messages/data/models/messages_model.dart';

import '../local/chat_local_data_source.dart';
import '../models/chat_model.dart' as msg;
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

  Future<String> _key({int? conversationId, int? partnerId}) =>
      local.computeConvoKey(conversationId: conversationId, partnerId: partnerId);

  Stream<List<LocalMessage>> watchMessagesLocal({int? conversationId, int? partnerId}) async* {
    final k = await _key(conversationId: conversationId, partnerId: partnerId);
    yield* local.watchMessages(k);
  }

  Future<void> initConversation({
    int? conversationId,
    int? partnerId,
    String? partnerName,
    String? partnerAvatar,
  }) async {
    final k = await _key(conversationId: conversationId, partnerId: partnerId);
    final existing = await local.getConversationByKey(k);
    if (existing == null) {
      await local.upsertConversation(LocalConversation(
        convoKey: k,
        conversationId: conversationId,
        peerId: partnerId ?? 0,
        peerName: partnerName ?? 'مستخدم',
        peerAvatar: partnerAvatar,
        lastMessage: null,
        lastTime: null,
      ));
    }
  }

  Future<bool> _isOnline() async {
    final res = await connectivity.checkConnectivity();
    return res.contains(ConnectivityResult.mobile) || res.contains(ConnectivityResult.wifi);
  }

  Future<void> syncFromRemote({required int conversationId, required int meId}) async {
    if (!await _isOnline()) return;

    final remoteMsgs = await remote.getConversationMessages(conversationId);
    final k = await _key(conversationId: conversationId);

    final toInsert = remoteMsgs.map<LocalMessage>((m) {
      final created = DateTime.tryParse(m.createdAt ?? '') ?? DateTime.now();
      return LocalMessage(
        id: null,
        serverId: m.id,
        conversationId: conversationId,
        convoKey: k,
        senderId: m.senderId ?? 0,
        receiverId: m.receiverId ?? 0,
        content: m.messageContent ?? '',
        type: 'text',
        createdAt: created,
        status: 'sent',
        isMine: (m.senderId == meId),
        adId: null,
      );
    }).toList();

    await local.upsertMessages(toInsert);
  }

  Future<void> sendMessage({
    required int meId,
    int? conversationId,
    required int partnerId,
    required String content,
    String type = 'text',
    int? adId,
  }) async {
    final k = await _key(conversationId: conversationId, partnerId: partnerId);

    final localMsg = LocalMessage(
      id: null,
      serverId: null,
      conversationId: conversationId,
      convoKey: k,
      senderId: meId,
      receiverId: partnerId,
      content: content,
      type: type,
      createdAt: DateTime.now(),
      status: 'pending',
      isMine: true,
      adId: adId,
    );

    await local.insertMessage(localMsg);

    await _trySendPending();
  }

  Future<void> _trySendPending() async {
    if (!await _isOnline()) return;

    final pendings = await local.getPendingMessages();
    for (final m in pendings) {
      try {
        int? convId = m.conversationId;

        if ((convId == null || convId == 0) && m.convoKey.startsWith('u:')) {
          final partnerId = int.tryParse(m.convoKey.split(':').last) ?? 0;
          final newConvId = await remote.initiateChat(partnerId);
          if (newConvId == null) throw Exception('initiateChat failed');
          convId = newConvId;
          await local.updateConversationIdForKey(m.convoKey, newConvId);
        }

        final chatId = convId ?? 0;

        final body = msg.SendMessageRequestBody(
          receiverId: m.receiverId,
          messageContent: m.content,
          listingId: m.adId,
          messageType: m.type,
        );

        await remote.sendMessage(body as SendMessageRequestBody, chatId);

        await local.updateMessageStatus(m.id!, 'sent');
      } catch (e) {
        if (m.id != null) {
          await local.updateMessageStatus(m.id!, 'failed');
        }
      }
    }
  }

  Future<void> syncPendingNow() => _trySendPending();
}