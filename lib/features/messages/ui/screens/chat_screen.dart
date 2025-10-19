import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/cache_helper.dart';

import 'package:mushtary/features/messages/data/models/messages_model.dart';
import 'package:mushtary/features/messages/data/repo/messages_repo.dart';
import 'package:mushtary/features/messages/logic/cubit/chat_cubit.dart';
import 'package:mushtary/features/messages/logic/cubit/chat_state.dart';

import '../../../../core/widgets/safe_cached_image.dart';
import '../widgets/chats/chat_selled_item.dart';
import '../widgets/chats/message_data_widget.dart';
import '../widgets/chats/message_input_box.dart';

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

  // استنتاج receiverId لو partnerUser.id مش موجود
  int? _resolveReceiverId(BuildContext context, int meId) {
    final partnerId = chatModel.partnerUser?.id;
    if (partnerId != null && partnerId > 0) return partnerId;

    final st = context.read<ChatCubit>().state;
    if (st is ChatSuccess) {
      for (final m in st.messages) {
        if (m.senderId != null && m.senderId != meId) return m.senderId;
        if (m.receiverId != null && m.receiverId != meId) return m.receiverId;
      }
    }
    return null;
  }

  // استنتاج chatId لو ناقص
  int? _resolveChatId(BuildContext context) {
    final id = chatModel.conversationId;
    if (id != null && id > 0) return id;

    final st = context.read<ChatCubit>().state;
    if (st is ChatSuccess && st.messages.isNotEmpty) {
      return st.messages.first.conversationId;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final meId = _currentUserId();
    final avatarUrl = chatModel.partnerUser?.profileImage;
    final name = (chatModel.partnerUser?.name?.trim().isNotEmpty ?? false)
        ? chatModel.partnerUser!.name!
        : 'المحادثة';

    return BlocProvider(
      create: (_) => getIt<ChatCubit>()..fetchMessages(chatModel.conversationId ?? 0),
      child: Builder(
        builder: (chatContext) {
          Future<void> _safeSend(String messageContent) async {
            // 1) استنتاج المستلم
            int? receiverId = _resolveReceiverId(chatContext, meId);
            if (receiverId == null || receiverId == 0) {
              ScaffoldMessenger.of(chatContext).showSnackBar(
                const SnackBar(content: Text('لا يمكن تحديد المستلم الآن، انتظر تحميل الرسائل ثم حاول مجددًا.')),
              );
              return;
            }

            // 2) استنتاج/إنشاء chatId
            int? chatId = _resolveChatId(chatContext);
            if (chatId == null || chatId == 0) {
              try {
                final repo = getIt<MessagesRepo>();
                final newChatId = await repo.initiateChat(receiverId);
                if (newChatId == null) {
                  ScaffoldMessenger.of(chatContext).showSnackBar(
                    const SnackBar(content: Text('تعذر بدء المحادثة الآن.')),
                  );
                  return;
                }
                chatId = newChatId;
                await chatContext.read<ChatCubit>().fetchMessages(chatId);
              } catch (e) {
                ScaffoldMessenger.of(chatContext).showSnackBar(
                  SnackBar(content: Text('خطأ في بدء المحادثة: $e')),
                );
                return;
              }
            }

            // 3) الإرسال مع message_type='text'
            chatContext.read<ChatCubit>().sendMessage(
              SendMessageRequestBody(
                receiverId: receiverId,
                messageContent: messageContent,
                listingId: adInfo?.id,
                messageType: 'text',
              ),
              chatId!,
            );
          }

          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0.5,
                surfaceTintColor: Colors.white,
                leading: IconButton(
                  icon:  Icon(Icons.arrow_back_ios,color: ColorsManager.darkGray300,),
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
                        return const Center(child: CircularProgressIndicator());
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
                  child: MessageInputBox(
                    receiverId: chatModel.partnerUser?.id ?? 0,
                    onSend: (msg) => _safeSend(msg),
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