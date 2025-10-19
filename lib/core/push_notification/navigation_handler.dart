// import 'package:flutter/material.dart';
// import 'package:mushtary/core/push_notification/enum.dart';
// import 'package:mushtary/core/push_notification/push_notification_bloc.dart';
// // import 'package:url_launcher/url_launcher.dart';
// import 'package:collection/collection.dart';
//
// class NavigationHandler {
//   /// Navigate based on the payload
//   void navigateBasedOnPayload(
//     Map<String, dynamic> data,
//     Function(NotificationReceived) addNotificationReceived,
//   ) {
//     String typeStr = _extractTypeStrFromData(data);
//     final NotificationTypes? type = NotificationTypes.values
//         .firstWhereOrNull((element) => element.type == typeStr);
//     addNotificationReceived(NotificationReceived(type: type, extra: data));
//   }
//
//   /// Extract the type from the data
//   String _extractTypeStrFromData(Map<String, dynamic> data) {
//     if (data.containsKey('URL')) {
//       final String url = data['URL'];
//       if (_isSpecialUrl(url)) {
//         launchUriMethod(url);
//         return '';
//       }
//     } else if (data.containsKey('screen')) {
//       return data['screen'];
//     } else if (data.containsKey('type')) {
//       return data['type'];
//     }
//     return '';
//   }
//
//   /// Check if the url is a special url
//   bool _isSpecialUrl(String url) {
//     return url.toLowerCase().contains('0') ||
//         url.toLowerCase().contains('0') ||
//         url.toLowerCase().contains('0') ||
//         url.toLowerCase().contains('0');
//   }
//
//   /// Handle navigation based on the notification type
//   void handleNavigation(
//     BuildContext context, {
//     required NotificationTypes? type,
//     required Map<String, dynamic> extra,
//   }) {}
// }
//
// /// Launch URI url
// Future<void> launchUriMethod(String url) async {
//   // await launchUrl(
//   //   Uri.parse(url),
//   //   mode: LaunchMode.externalApplication,
//   // );
// }
