import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';

import 'package:mushtary/features/messages/data/models/messages_model.dart';
import 'package:mushtary/features/messages/logic/cubit/chat_cubit.dart';
import 'package:mushtary/features/messages/logic/cubit/chat_state.dart';

import '../../../../core/widgets/safe_cached_image.dart';
import '../widgets/chats/chat_selled_item.dart';
import '../widgets/chats/message_data_widget.dart';
import '../widgets/chats/message_input_box.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatScreenArgs {
  final MessagesModel chatModel;
  final AdInfo? adInfo;
  ChatScreenArgs({required this.chatModel, this.adInfo});
}

class ChatScreen extends StatelessWidget {
  final MessagesModel chatModel;
  final AdInfo? adInfo;

  ChatScreen({super.key, required dynamic args})
      : chatModel = args is ChatScreenArgs ? args.chatModel : args as MessagesModel,
        adInfo = args is ChatScreenArgs ? args.adInfo : null;

  int _currentUserId() {
    final token = CacheHelper.getData(key: 'token') as String?;
    if (token == null || token.isEmpty) return -1;
    final payload = JwtDecoder.decode(token);
    final id = payload['user_id'] ?? payload['id'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    if (id is String) return int.tryParse(id) ?? -1;
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final meId = _currentUserId();
    final avatarUrl = chatModel.partnerUser?.profileImage;
    final name = (chatModel.partnerUser?.name?.trim().isNotEmpty ?? false)
        ? chatModel.partnerUser!.name!
        : 'المحادثة';

    return BlocProvider(
      create: (_) => getIt<ChatCubit>()
        ..initChat(
          conversationId: chatModel.conversationId,
          partnerId: chatModel.partnerUser?.id ?? 0,
          partnerName: chatModel.partnerUser?.name,
          partnerAvatar: chatModel.partnerUser?.profileImage,
        ),
      child: Builder(
        builder: (chatContext) {
          Future<void> _safeSend(String messageContent) async {
            await chatContext.read<ChatCubit>().sendMessage(
              text: messageContent,
              adId: adInfo?.id,
            );
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0.5,
              surfaceTintColor: Colors.white,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'رجوع',
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SafeCircleAvatar(url: avatarUrl, radius: 12),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            resizeToAvoidBottomInset: true,
            body: Column(
              children: [
                ChatSelledItem(adInfo: adInfo),
                Expanded(
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      if (state is ChatLoading || state is ChatInitial) {
                        return const ChatMessagesSkeleton();
                      }
                      if (state is ChatFailure) {
                        return Center(child: Text(state.error));
                      }
                      if (state is ChatSuccess) {
                        if (state.messages.isEmpty) {
                          return const Center(child: Text('لا توجد رسائل بعد'));
                        }
                        return ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          itemCount: state.messages.length,
                          itemBuilder: (_, index) {
                            final m = state.messages[index];
                            return MessageDataWidget(
                              message: m.messageContent ?? '',
                              isSended: m.senderId == meId,
                              messageType: m.messageType ?? 'text',  // ← أضف النوع الذي يأتي من الخادم أو التحليل المحلي
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child:MessageInputBox(
                    receiverId: chatModel.partnerUser?.id ?? 0,
                    onSend: (msg, type) => _safeSend(msg),
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

class ChatMessagesSkeleton extends StatelessWidget {
  const ChatMessagesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        itemCount: 12,
        itemBuilder: (_, i) {
          final isMe = i % 2 == 0;
          final bubbleWidth = width * (isMe ? 0.58 : 0.72);
          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: bubbleWidth,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: bubbleWidth * 0.8, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 12, width: bubbleWidth * 0.55, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}