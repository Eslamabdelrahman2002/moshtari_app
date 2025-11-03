import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/messages_repo.dart';
import 'message_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final MessagesRepo repo;
  Timer? _refreshTimer;

  MessagesCubit(this.repo) : super(MessagesInitial());

  // دالة البداية (بتيجي من MessagesScreen)
  Future<void> fetchConversations() async {
    try {
      emit(MessagesLoading());
      final conversations = await repo.getConversations();
      emit(MessagesSuccess(conversations));

      // ✅ ابدأ الـ polling كل 5 ثواني بعد أول تحميل
      _startAutoRefresh();
    } catch (e) {
      emit(MessagesFailure('فشل تحميل المحادثات: $e'));
    }
  }

  // ✅ التحديث كل 5 ثواني
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _refreshConversations();
    });
  }

  // ✅ تنفيذ الـ refresh بدون إظهار loading
  Future<void> _refreshConversations() async {
    if (state is! MessagesSuccess) return;
    try {
      final newList = await repo.getConversations();
      emit(MessagesSuccess(newList));
    } catch (e) {
      // ممكن تتجاهل الأخطاء المؤقتة
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}