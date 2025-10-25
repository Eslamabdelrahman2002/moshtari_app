import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/features/messages/logic/cubit/messages_cubit.dart';

import '../../logic/cubit/message_state.dart';
import '../widgets/messages/message_item.dart';
import '../widgets/messages/messages_app_bar.dart';
import '../widgets/messages/messages_empty_case.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MessagesCubit>()..fetchConversations(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const MessagesAppBar(),
              Expanded(
                child: BlocBuilder<MessagesCubit, MessagesState>(
                  builder: (context, state) {
                    if (state is MessagesLoading || state is MessagesInitial) {
                      return const ConversationsListSkeleton();
                    }
                    if (state is MessagesFailure) {
                      return Center(child: Text(state.error));
                    }
                    if (state is MessagesSuccess) {
                      if (state.conversations.isEmpty) {
                        return const MessagesEmptyCase();
                      }
                      return ListView.builder(
                        itemCount: state.conversations.length,
                        itemBuilder: (context, index) {
                          return MessageItem(
                            index: index,
                            isLast: index == state.conversations.length - 1,
                            message: state.conversations[index],
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConversationsListSkeleton extends StatelessWidget {
  const ConversationsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        itemCount: 8,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFECECEC)),
        itemBuilder: (_, __) {
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 140, color: Colors.white),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(height: 10, width: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Expanded(child: Container(height: 10, color: Colors.white)),
                          const SizedBox(width: 8),
                          Container(height: 10, width: 60, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}