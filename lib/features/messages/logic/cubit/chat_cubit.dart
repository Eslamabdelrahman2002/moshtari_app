import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/messages_model.dart';
import '../../data/repo/messages_repo.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final MessagesRepo _repo;
  ChatCubit(this._repo) : super(ChatInitial());

  final List<Message> _messages = [];
  StreamSubscription<Message>? _sub;
  int? _cid;
  bool _initialized = false;

  String _key(Message m) {
    if (m.id != null) return 'id:${m.id}';
    final content = (m.messageContent ?? '').trim();
    final created = (m.createdAt ?? '').split('.').first;
    return 'tmp:${m.senderId}-${m.receiverId}-$content-$created';
  }

  void _upsert(Iterable<Message> batch, {bool replace = false}) {
    final map = <String, Message>{};
    if (!replace) {
      for (final m in _messages) {
        map[_key(m)] = m;
      }
    }
    for (final m in batch) {
      map[_key(m)] = m;
    }
    final list = map.values.toList();
    list.sort((a, b) {
      final ta = DateTime.tryParse(a.createdAt ?? '')?.millisecondsSinceEpoch ?? 0;
      final tb = DateTime.tryParse(b.createdAt ?? '')?.millisecondsSinceEpoch ?? 0;
      return tb.compareTo(ta);
    });
    _messages
      ..clear()
      ..addAll(list);
    emit(ChatSuccess(List.unmodifiable(_messages)));
  }

  Future<void> fetchMessages(int conversationId) async {
    _cid = conversationId;
    if (!_initialized) emit(ChatLoading());
    try {
      final msgs = await _repo.getConversationMessages(conversationId);
      _upsert(msgs.reversed, replace: !_initialized);
      _initialized = true;

      await _sub?.cancel();
      _sub = _repo.incomingMessages().listen((m) {
        if (m.conversationId == _cid) {
          _upsert([m], replace: false);
        }
      });
    } catch (e) {
      emit(ChatFailure(e.toString()));
    }
  }

  Future<void> sendMessage(SendMessageRequestBody body, int conversationId) async {
    final optimistic = Message(
      id: null,
      senderId: _repo.currentUserId(),
      receiverId: body.receiverId,
      conversationId: conversationId,
      messageContent: body.messageContent,
      createdAt: DateTime.now().toIso8601String(),
    );

    final optimisticKey = _key(optimistic);
    _upsert([optimistic], replace: false);

    try {
      await _repo.sendMessage(body, conversationId);
      // لا نعمل refresh كامل هنا
    } catch (e) {
      // Rollback
      _messages.removeWhere((m) => _key(m) == optimisticKey);
      emit(ChatFailure(e.toString()));
      emit(ChatSuccess(List.unmodifiable(_messages)));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}