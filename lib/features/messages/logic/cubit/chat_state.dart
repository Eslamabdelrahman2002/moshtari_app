// lib/features/messages/logic/cubit/chat_state.dart
import 'package:flutter/material.dart';
import 'package:mushtary/features/messages/data/models/messages_model.dart';

@immutable
abstract class ChatState {}
class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatSuccess extends ChatState {
  final List<Message> messages;
  ChatSuccess(this.messages);
}
class ChatFailure extends ChatState {
  final String error;
  ChatFailure(this.error);
}