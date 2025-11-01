import 'dart:async';

class ConversationBumpEvent {
  final int? conversationId;
  final int? partnerId;
  final String preview; // النص المعروض في القائمة: [صورة]/[رسالة صوتية]/نص...
  final String type;    // text | image | audio | voice
  final String timeIso; // createdAt ISO
  final bool isMine;    // مرسلة منّي

  ConversationBumpEvent({
    required this.preview,
    required this.type,
    required this.timeIso,
    required this.isMine,
    this.conversationId,
    this.partnerId,
  });
}

class ChatEventsBus {
  final _controller = StreamController<ConversationBumpEvent>.broadcast();
  Stream<ConversationBumpEvent> get stream => _controller.stream;
  void emitBump(ConversationBumpEvent e) => _controller.add(e);
  Future<void> dispose() async => _controller.close();
}