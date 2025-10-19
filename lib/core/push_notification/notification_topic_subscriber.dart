import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationTopicSubscriber {
  NotificationTopicSubscriber(this._firebaseMessaging);
  final FirebaseMessaging _firebaseMessaging;

  final List<String> _topics = [];

  static String userId = 'user_id';
  static String userEmail = 'user_email';
  static String userMobile = 'user_mobile';

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      _topics.add(topic);
      await _firebaseMessaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic: $e');
    }
  }

  /// Subscribe to multiple topics
  Future<void> subscribeToTopics(List<String> topics) async {
    for (var topic in topics) {
      subscribeToTopic(topic);
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic: $e');
    }
  }

  /// Unsubscribe from all topics
  Future<void> unsubscribeFromTopics() async {
    for (var topic in _topics) {
      unsubscribeFromTopic(topic);
    }
  }
}
