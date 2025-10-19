// lib/features/messages/logic/cubit/messages_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/messages_repo.dart';
import 'message_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final MessagesRepo _messagesRepo;
  MessagesCubit(this._messagesRepo) : super(MessagesInitial());

  void fetchConversations() async {
    emit(MessagesLoading());
    try {
      // ✅ يجب هنا محاولة الاتصال بالـ WebSocket أولاً
      // (يفترض أن هذا يحدث داخل MessagesRepo أو ChatSocketService قبل الـ emitWithAck)

      final conversations = await _messagesRepo.getConversations();
      emit(MessagesSuccess(conversations));
    } catch (e) {
      // ✅ تعديل رسالة الخطأ لتكون أوضح
      emit(MessagesFailure('فشل الاتصال بخادم المحادثات أو جلب القائمة: ${e.toString()}'));
    }
  }
}