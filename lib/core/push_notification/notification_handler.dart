import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  NotificationHandler(this._firebaseMessaging);
  final FirebaseMessaging _firebaseMessaging;

  /// Request permissions for notifications
  Future<void> requestPermissions() async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();
    log('User granted permission: ${settings.authorizationStatus}');
    log('FCM token: $token');
  }

  /// Initialize local notifications
  Future<void> initializeLocalNotifications(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      Function(String) onNotificationTapped) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    DarwinInitializationSettings initializationSettingsDarwin =
        const DarwinInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse? notificationResponse) {
        if (notificationResponse?.payload == null) return;
        onNotificationTapped(notificationResponse!.payload!);
      },
    );
  }

  /// Listen for messages when the app is in the foreground
  void listenForForegroundMessages(Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  /// Listen for messages when the app is in the background
  void listenForMessageTap(Function(String) onNotificationTapped) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Got a message while message opened app!');
      log('Message data: ${message.data}');
      final payload = jsonEncode(message.data);
      onNotificationTapped(payload);
    });
  }

  /// Show a foreground notification
  void showForegroundNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification?.title,
      notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications',
          playSound: true,
          icon: 'mipmap/ic_launcher',
          priority: Priority.high,
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
}
