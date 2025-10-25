import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';

import '../../data/repo/chat_offline_repository.dart';
import '../../data/models/messages_model.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatOfflineRepository repo;
  StreamSubscription? _sub;

  int? _conversationId;
  int? _partnerId;

  ChatCubit(this.repo) : super(ChatInitial());

  int _meId() {
    final token = CacheHelper.getData(key: 'token') as String?;
    if (token == null || token.isEmpty) return -1;
    final payload = JwtDecoder.decode(token);
    final raw = payload['user_id'] ?? payload['id'] ?? payload['sub'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? -1;
    return -1;
  }

  Future<void> initChat({
    int? conversationId,
    required int partnerId,
    String? partnerName,
    String? partnerAvatar,
  }) async {
    emit(ChatLoading());
    _conversationId = conversationId;
    _partnerId = partnerId;

    await repo.initConversation(
      conversationId: conversationId,
      partnerId: partnerId,
      partnerName: partnerName,
      partnerAvatar: partnerAvatar,
    );

    // راقب الرسائل من التخزين المحلي
    await _sub?.cancel();
    _sub = repo
        .watchMessagesLocal(conversationId: conversationId, partnerId: partnerId)
        .listen((localMsgs) {
      final msgs = localMsgs.map((lm) {
        return Message(
          id: lm.serverId,
          senderId: lm.senderId,
          receiverId: lm.receiverId,
          conversationId: lm.conversationId,
          messageContent: lm.content,
          createdAt: lm.createdAt.toIso8601String(),
        );
      }).toList();
      emit(ChatSuccess(msgs));
    });

    // مزامنة من السيرفر (محميّة من أي خطأ)
    try {
      if (conversationId != null && conversationId > 0) {
        await repo.syncFromRemote(conversationId: conversationId, meId: _meId());
      }
      await repo.syncPendingNow();
    } catch (_) {
      // تجاهل أي خطأ هنا لتجنّب كسر الواجهة
    }
  }

  Future<void> sendMessage({required String text, int? adId}) async {
    if (_partnerId == null) {
      emit(ChatFailure('لا يمكن تحديد المستلم.'));
      return;
    }
    try {
      await repo.sendMessage(
        meId: _meId(),
        conversationId: _conversationId,
        partnerId: _partnerId!,
        content: text,
        adId: adId,
      );
      // لا حاجة للتحديث اليدوي؛ الاستريم المحلي هيبثّ الرسالة pending فوراً
    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }

  Future<void> retryPending() => repo.syncPendingNow();

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}