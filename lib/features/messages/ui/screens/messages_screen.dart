import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/features/messages/logic/cubit/messages_cubit.dart';


import '../../logic/cubit/message_state.dart';
import '../widgets/messages/message_item.dart';
import '../widgets/messages/messages_app_bar.dart';
import '../widgets/messages/messages_empty_case.dart';

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
                      return const Center(child: CircularProgressIndicator());
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