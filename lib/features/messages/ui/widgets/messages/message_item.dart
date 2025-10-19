import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/safe_cached_image.dart';
import 'package:mushtary/features/messages/data/models/messages_model.dart';
import 'package:mushtary/features/messages/ui/screens/chat_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageItem extends StatelessWidget {
  final int index;
  final bool isLast;
  final MessagesModel message;
  const MessageItem({
    super.key,
    required this.index,
    required this.message,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('ar', timeago.ArMessages());

    DateTime dt;
    try {
      dt = DateTime.parse(message.lastMessageTime ?? '');
    } catch (_) {
      dt = DateTime.now();
    }

    final displayName = (message.partnerUser?.name?.trim().isNotEmpty ?? false)
        ? message.partnerUser!.name!
        : 'مستخدم';

    return InkWell(
      onTap: () => context.pushNamed(
        Routes.chatScreen,
        arguments: ChatScreenArgs(chatModel: message),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: !isLast ? const BorderSide(color: ColorsManager.grey100) : BorderSide.none,
            top: index == 0 ? const BorderSide(color: ColorsManager.grey100) : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            SafeCircleAvatar(
              url: message.partnerUser?.profileImage,
              radius: 32.r,
            ),
            horizontalSpace(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyles.font14Black500Weight,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(Icons.check, color: ColorsManager.black, size: 12),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          message.lastMessage ?? '',
                          style: TextStyles.font12Black400Weight,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        timeago.format(dt, locale: 'ar'),
                        style: TextStyles.font12Dark500400Weight,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}