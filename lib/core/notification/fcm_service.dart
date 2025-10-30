import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';

class FcmService {
  static bool _inited = false;

  static GlobalKey<NavigatorState>? _navKey;
  static String? _notificationRoute;
  static RemoteMessage? _pendingMessage;

  static void attachNavigator(
      GlobalKey<NavigatorState> key, {
        String? onOpenNotificationRoute,
      }) {
    _navKey = key;
    _notificationRoute = onOpenNotificationRoute;

    if (_pendingMessage != null) {
      _openFromMessage(_pendingMessage!);
      _pendingMessage = null;
    }
  }

  static Future<void> init() async {
    if (_inited) return;

    // لا تستدعي Firebase.initializeApp هنا
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (_) {}

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await CacheHelper.saveData(key: 'fcm_token', value: token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen(
          (t) => CacheHelper.saveData(key: 'fcm_token', value: t),
    );

    final initialMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMsg != null) _openFromMessage(initialMsg);

    FirebaseMessaging.onMessageOpenedApp.listen(_openFromMessage);

    _inited = true;
  }

  static void _openFromMessage(RemoteMessage msg) {
    final nav = _navKey?.currentState;
    if (nav == null) {
      _pendingMessage = msg;
      return;
    }
    final deeplink = msg.data['deeplink'] as String?;
    final target = deeplink ?? _notificationRoute;
    if (target != null && target.isNotEmpty) {
      nav.pushNamed(target, arguments: msg.data);
    }
  }

  static Future<String?> currentToken() async {
    final cached = CacheHelper.getData(key: 'fcm_token') as String?;
    return cached ?? await FirebaseMessaging.instance.getToken();
  }
}