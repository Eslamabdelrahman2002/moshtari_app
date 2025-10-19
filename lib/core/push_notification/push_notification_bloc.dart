// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:mushtary/core/push_notification/enum.dart';
// import 'package:mushtary/core/push_notification/navigation_handler.dart';
// import 'package:mushtary/core/push_notification/notification_handler.dart';
//
// part 'push_notification_event.dart';
// part 'push_notification_state.dart';
//
// class PushNotificationBloc
//     extends Bloc<PushNotificationEvent, PushNotificationState> {
//   PushNotificationBloc({
//     required this.flutterLocalNotificationsPlugin,
//     required this.firebaseMessaging,
//     required this.notificationHandler,
//     required this.navigationHandler,
//   }) : super(const InitialPushNotificationState()) {
//     _initializeListeners();
//   }
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//   final FirebaseMessaging firebaseMessaging;
//   final NotificationHandler notificationHandler;
//   final NavigationHandler navigationHandler;
//
//   /// Initialize notification listeners
//   void _initializeListeners() {
//     on<PushNotificationCheckRequested>(_handlePushNotificationCheckRequested);
//     on<NotificationReceived>(_handleNotificationReceived);
//     on<InitialNotificationCheckRequested>(
//         _handleInitialNotificationCheckRequested);
//   }
//
//   /// Handle push notification check requested
//   Future<void> _handlePushNotificationCheckRequested(
//     PushNotificationCheckRequested event,
//     Emitter<PushNotificationState> emit,
//   ) async {
//     await notificationHandler.requestPermissions();
//     await notificationHandler.initializeLocalNotifications(
//       flutterLocalNotificationsPlugin,
//       _onNotificationTapped,
//     );
//     notificationHandler
//         .listenForForegroundMessages(_firebaseOnMessageForegroundReceived);
//     notificationHandler.listenForMessageTap(
//       _onNotificationTapped,
//     );
//   }
//
//   /// Handle notification received
//   void _handleNotificationReceived(
//     NotificationReceived event,
//     Emitter<PushNotificationState> emit,
//   ) {
//     emit(NavigateToParticularRouteState(extra: event.extra, type: event.type));
//   }
//
//   /// Handle initial notification check requested
//   Future<void> _handleInitialNotificationCheckRequested(
//     InitialNotificationCheckRequested event,
//     Emitter<PushNotificationState> emit,
//   ) async {
//     final RemoteMessage? initialNotification =
//         await firebaseMessaging.getInitialMessage();
//     if (initialNotification != null) {
//       _onNotificationTapped(jsonEncode(initialNotification.data));
//     }
//   }
//
//   /// Handle foreground message received
//   void _firebaseOnMessageForegroundReceived(RemoteMessage message) {
//     log('Got a message whilst in the foreground!');
//     log('Message data: ${message.data}');
//     notificationHandler.showForegroundNotification(
//       flutterLocalNotificationsPlugin,
//       message,
//     );
//   }
//
//   /// Handle notification tap
//   void _onNotificationTapped(String payload) {
//     log('notification payLoad $payload');
//     final Map<String, dynamic> data = jsonDecode(payload);
//     navigationHandler.navigateBasedOnPayload(data, add);
//   }
// }
