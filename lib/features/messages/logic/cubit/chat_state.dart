// lib/features/messages/logic/cubit/chat_state.dart

import 'package:flutter/material.dart';
// ❌ OLD: import 'package:mushtary/features/messages/data/models/messages_model.dart';
// ✅ NEW: توحيد مصدر النماذج ليتطابق مع MessagesRepo و ChatCubit
import 'package:mushtary/features/messages/data/models/chat_model.dart'; // FIX: استخدم chat_model.dart

@immutable
abstract class ChatState {}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}

class ChatSuccess extends ChatState {
  final List<Message> messages;
  ChatSuccess(this.messages); // الآن Message هو من chat_model.dart
}

class ChatFailure extends ChatState {
  final String error;
  ChatFailure(this.error);
}