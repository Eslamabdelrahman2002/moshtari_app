import 'package:equatable/equatable.dart';
import 'package:mushtary/features/messages/data/models/chat_model.dart'; // FIX: استخدم chat_model.dart

abstract class MessagesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MessagesInitial extends MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesSuccess extends MessagesState {
  final List<MessagesModel> conversations;
  MessagesSuccess(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class MessagesFailure extends MessagesState {
  final String error;
  MessagesFailure(this.error);

  @override
  List<Object?> get props => [error];
}