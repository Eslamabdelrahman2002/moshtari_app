import 'dart:async';
import 'dart:math'; // للـ random في optimistic ID
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';

import '../../data/models/chat_model.dart' as rm;
import '../../data/models/chat_model.dart';
import '../../data/repo/messages_repo.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final MessagesRepo remote;
  ChatCubit(this.remote) : super(ChatInitial());

  int? _conversationId;
  int? _partnerId;
  int? _meIdCache;

  // للـ pagination
  int? _oldestMessageId;  // ID أقدم رسالة حاليًا
  bool _hasMoreOlderMessages = true;  // هل هناك المزيد من القديمة؟
  bool _loadingOlder = false;  // لمنع تحميل متعدد

  // Getter عام للوصول من UI
  bool get isLoadingOlder => _loadingOlder;

  // لتجنب تكرار نفس الرسالة (positive ids)
  final Set<int> _seenIds = {};

  // لتتبع الرسائل المتفائلة (للمطابقة الدقيقة)
  final Map<String, int> _optimisticIds = {}; // key: content+sender+time, value: temp ID

  StreamSubscription? _messagesSubscription;
  Timer? _pollTimer;
  bool _refreshBusy = false;

  // Helper
  List<rm.Message> _current() =>
      state is ChatSuccess ? List<rm.Message>.of((state as ChatSuccess).messages) : <rm.Message>[];

  int _meId() {
    if (_meIdCache != null) return _meIdCache!;
    final token = CacheHelper.getData(key: 'token') as String?;
    if (token == null || token.isEmpty) return -1;
    final payload = JwtDecoder.decode(token);
    final raw = payload['user_id'] ?? payload['id'] ?? payload['sub'];
    final id = (raw is int)
        ? raw
        : (raw is num)
        ? raw.toInt()
        : (raw is String)
        ? int.tryParse(raw) ?? -1
        : -1;
    _meIdCache = id;
    return id;
  }

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    _pollTimer?.cancel();
    if (_conversationId != null) {
      try {
        await remote.leaveChat(_conversationId!);
      } catch (_) {}
    }
    _optimisticIds.clear(); // تنظيف المتفائلة
    return super.close();
  }

  Future<void> initChat({
    int? conversationId,
    required int partnerId,
    String? partnerName,
    String? partnerAvatar,
  }) async {
    if (isClosed) return;

    _conversationId = conversationId;
    _partnerId = partnerId;
    _hasMoreOlderMessages = true;
    _oldestMessageId = null;
    _loadingOlder = false;
    _seenIds.clear();
    _optimisticIds.clear(); // تنظيف

    emit(ChatLoading());

    if (conversationId != null) {
      // جلب الدفعة الأولية (آخر 20 رسالة)
      await _loadInitialMessages(limit: 20);

      // انضمام للغرفة
      try {
        await remote.joinChat(conversationId);
      } catch (_) {}

      // ابدأ الـ polling للجديدة كل 5 ثواني
      _startPolling(interval: const Duration(seconds: 5));

      // Refresh سريع بعد ثانية للتأكد
      Future.delayed(const Duration(seconds: 1), () => _refreshFromServer(force: true));
    }

    // الاستماع لأحداث السوكيت
    _messagesSubscription?.cancel();
    _messagesSubscription = remote.incomingMessages().listen((m) {
      if (isClosed) return;
      if (m.conversationId == null || m.conversationId != _conversationId) return;

      final list = _current();

      // ✅ تحسين: استبدال المتفائلة إذا كانت الرسالة مني (أو مطابقة)
      final optimisticIndex = _findOptimisticIndex(list, m);
      if (optimisticIndex != -1) {
        // استبدل المتفائلة بالحقيقية
        list[optimisticIndex] = _toRmMessage(m);
        _optimisticIds.remove(_getMatchKey(m)); // إزالة من التتبع
        list.sort(_messageComparator); // ترتيب محسن
        emit(ChatSuccess(list));
        debugPrint('🔄 Socket: Replaced optimistic message ${m.id}');
        return;
      }

      // أضف الرسالة لو مش موجودة (حسب id)
      if (m.id != null && _seenIds.contains(m.id!)) {
        emit(ChatSuccess(list)); // لا شيء جديد
        return;
      }

      if (m.id != null) _seenIds.add(m.id!);

      final newMsg = _toRmMessage(m);
      list.add(newMsg); // أضف في النهاية (صاعد)
      list.sort(_messageComparator); // ترتيب محسن
      emit(ChatSuccess(list));
      debugPrint('📨 Socket: Added new message ${m.id}');
    }, onError: (_) {});
  }

  // ✅ جديد: comparator محسن للترتيب (createdAt أولاً، ثم ID)
  int _messageComparator(rm.Message a, rm.Message b) {
    final timeA = a.createdAt ?? '';
    final timeB = b.createdAt ?? '';
    final cmp = timeA.compareTo(timeB);
    if (cmp != 0) return cmp;
    // إذا متساوي الوقت، ضع الإيجابي (حقيقي) قبل السلبي (متفائل)
    final idA = a.id ?? 0;
    final idB = b.id ?? 0;
    return idA.compareTo(idB);
  }

  // ✅ جديد: تحويل Message إلى rm.Message
  rm.Message _toRmMessage(Message m) => rm.Message(
    id: m.id,
    senderId: m.senderId,
    receiverId: m.receiverId,
    conversationId: m.conversationId,
    messageContent: m.messageContent,
    messageType: m.messageType,
    createdAt: m.createdAt,
  );

  // ✅ جديد: البحث عن فهرس المتفائلة المطابقة
  int _findOptimisticIndex(List<rm.Message> list, Message realMsg) {
    final matchKey = _getMatchKey(realMsg);
    return list.indexWhere((x) {
      if (x.id == null || x.id! >= 0) return false; // ليست متفائلة
      // مطابقة: محتوى + مرسل + وقت (دقة ±5 ثواني)
      final xTime = DateTime.tryParse(x.createdAt ?? '') ?? DateTime.now();
      final rTime = DateTime.tryParse(realMsg.createdAt ?? '') ?? DateTime.now();
      final timeDiff = (xTime.millisecondsSinceEpoch - rTime.millisecondsSinceEpoch).abs();
      return x.senderId == realMsg.senderId &&
          x.messageContent == realMsg.messageContent &&
          timeDiff < 5000 && // 5 ثواني
          _optimisticIds[matchKey] == x.id;
    });
  }

  // ✅ جديد: مفتاح مطابقة فريد (content + sender + time)
  String _getMatchKey(Message m) {
    final time = DateTime.tryParse(m.createdAt ?? '')?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
    return '${m.messageContent}_${m.senderId}_$time';
  }

  // جلب الدفعة الأولية (آخر الرسائل)
  Future<void> _loadInitialMessages({int limit = 20}) async {
    try {
      final remoteMsgs = await remote.getConversationMessages(_conversationId!, limit: limit);

      final buffer = <rm.Message>[];
      for (final m in remoteMsgs) {
        final item = _toRmMessage(m);
        if (item.id != null) _seenIds.add(item.id!);
        buffer.add(item);
      }

      // ترتيب صاعد
      buffer.sort(_messageComparator);

      // تحديث oldest ID
      if (buffer.isNotEmpty) {
        _oldestMessageId = buffer.first.id;  // أقدم ID
        _hasMoreOlderMessages = buffer.length == limit;  // إذا كان أقل، لا مزيد
      }

      emit(ChatSuccess(buffer));
      debugPrint('📜 Initial load: ${buffer.length} messages');
    } catch (e) {
      emit(ChatFailure('فشل جلب الرسائل: $e'));
    }
  }

  // جلب الرسائل القديمة (pagination للأعلى)
  Future<void> loadOlderMessages() async {
    if (_conversationId == null || isClosed || !_hasMoreOlderMessages || _loadingOlder) return;
    _loadingOlder = true;

    try {
      final olderMsgs = await remote.getConversationMessages(
        _conversationId!,
        beforeId: _oldestMessageId,
        limit: 20,
      );

      if (olderMsgs.isEmpty) {
        _hasMoreOlderMessages = false;
        return;
      }

      final currentList = _current();
      final newOlder = <rm.Message>[];

      for (final m in olderMsgs) {
        final item = _toRmMessage(m);
        if (item.id != null && !_seenIds.contains(item.id!)) {
          _seenIds.add(item.id!);
          newOlder.add(item);
        }
      }

      // أضف في البداية (صاعد: القديمة أولاً)
      currentList.insertAll(0, newOlder);
      currentList.sort(_messageComparator); // ترتيب محسن

      // تحديث oldest ID
      if (newOlder.isNotEmpty) {
        _oldestMessageId = newOlder.first.id;
        _hasMoreOlderMessages = newOlder.length == 20;
      }

      emit(ChatSuccess(currentList));
      debugPrint('📜 Loaded ${newOlder.length} older messages');
    } catch (e) {
      debugPrint('❌ Failed to load older: $e');
    } finally {
      _loadingOlder = false;
    }
  }

  void _startPolling({required Duration interval}) {
    _pollTimer?.cancel();
    if (_conversationId == null) return;
    _pollTimer = Timer.periodic(interval, (_) => _refreshFromServer());
  }

  // تحسين: جلب الجديدة فقط (بعد أحدث ID) كل 5 ثواني
  Future<void> _refreshFromServer({bool force = false}) async {
    if (_conversationId == null || isClosed || _refreshBusy) return;
    _refreshBusy = true;

    try {
      final currentList = _current();
      final latestId = currentList.isNotEmpty ? currentList.last.id : null;  // أحدث ID

      final fresh = await remote.getNewMessages(_conversationId!, latestId ?? 0);

      if (fresh.isEmpty && !force) return;  // لا جديد

      final currentIds = currentList.where((e) => e.id != null && e.id! > 0).map((e) => e.id!).toSet();

      bool addedAny = false;
      for (final fm in fresh) {
        // ✅ تحسين: استبدال المتفائلة أولاً
        final optimisticIndex = _findOptimisticIndex(currentList, fm);
        if (optimisticIndex != -1) {
          currentList[optimisticIndex] = _toRmMessage(fm);
          _optimisticIds.remove(_getMatchKey(fm));
          addedAny = true;
          debugPrint('🔄 Polling: Replaced optimistic ${fm.id}');
          continue;
        }

        final id = fm.id;
        if (id != null && id > 0 && !currentIds.contains(id)) {
          if (id != null) _seenIds.add(id);
          final newMsg = _toRmMessage(fm);
          currentList.add(newMsg);  // أضف في النهاية
          addedAny = true;
        }
      }

      if (addedAny || force) {
        currentList.sort(_messageComparator);  // ترتيب محسن
        emit(ChatSuccess(currentList));
        debugPrint('🆕 Polling added ${fresh.length} new messages');
      }
    } catch (e) {
      debugPrint('❌ Polling error: $e');
    } finally {
      _refreshBusy = false;
    }
  }

  Future<void> sendMessage({
    required String content,
    required String messageType, // text/image/audio/voice/file
    int? adId,
  }) async {
    if (isClosed) return;
    if (_partnerId == null) {
      emit(ChatFailure('لا يمكن تحديد المستلم.'));
      return;
    }

    final now = DateTime.now();
    final optimisticId = - (now.millisecondsSinceEpoch + Random().nextInt(10000)); // ID فريد سلبي
    final matchKey = _getMatchKey(rm.Message(
      id: null,
      senderId: _meId(),
      receiverId: _partnerId,
      conversationId: _conversationId,
      messageContent: content,
      messageType: messageType,
      createdAt: now.toIso8601String(),
    ));

    // إضافة متفائلة — صاعد: أضف في النهاية
    if (state is ChatSuccess) {
      final optimistic = rm.Message(
        id: optimisticId,
        senderId: _meId(),
        receiverId: _partnerId,
        conversationId: _conversationId,
        messageContent: content,
        messageType: messageType,
        createdAt: now.toIso8601String(),
      );
      _optimisticIds[matchKey] = optimisticId; // تتبع للمطابقة لاحقًا
      final list = _current();
      list.add(optimistic);
      list.sort(_messageComparator); // ترتيب فوري
      emit(ChatSuccess(list));
      debugPrint('📤 Optimistic added: temp ID $optimisticId');
    }

    try {
      final body = rm.SendMessageRequestBody(
        receiverId: _partnerId!,
        messageContent: content,
        listingId: adId,
        messageType: messageType,
      );

      await remote.sendMessage(body, _conversationId ?? 0);

      // ✅ تحسين: تأخير قصير (500ms) للسماح للسوكيت بالوصول أولاً، ثم refresh
      await Future.delayed(const Duration(milliseconds: 500));
      await _refreshFromServer(force: true);
    } catch (e) {
      if (!isClosed) emit(ChatFailure('فشل الإرسال: $e'));
      // إزالة المتفائلة في حال الفشل
      final list = _current();
      final optIndex = list.indexWhere((x) => x.id == optimisticId);
      if (optIndex != -1) {
        list.removeAt(optIndex);
        emit(ChatSuccess(list));
      }
    }
  }

  // Wrappers اختيارية
  Future<void> sendText(String text) => sendMessage(content: text, messageType: 'text');
  Future<void> sendImage(String src, {int? adId}) => sendMessage(content: src, messageType: 'image', adId: adId);
  Future<void> sendVoice(String src, {int? adId}) => sendMessage(content: src, messageType: 'audio', adId: adId);
}