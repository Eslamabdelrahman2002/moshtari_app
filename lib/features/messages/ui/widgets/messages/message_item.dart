import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/safe_cached_image.dart';
import 'package:mushtary/features/messages/data/models/chat_model.dart';
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
      onTap: () => NavX(context).pushNamed(
        Routes.chatScreen,
        arguments: ChatScreenArgs(chatModel: message),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom:
            !isLast ? const BorderSide(color: ColorsManager.grey100) : BorderSide.none,
            top: index == 0
                ? const BorderSide(color: ColorsManager.grey100)
                : BorderSide.none,
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
                      const Icon(Icons.check,
                          color: ColorsManager.black, size: 12),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          _buildPreviewText(
                              message.lastMessage ?? '', message),
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

  /// ✅ دالة عرض معاينة الرسالة حسب النوع
  String _buildPreviewText(String raw, MessagesModel msg) {
    final lower = raw.toLowerCase();
    final type = (msg.lastMessageType ?? '').toLowerCase();

    // فارغة
    if (raw.trim().isEmpty) return 'رسالة فارغة';

    // ✅ أولاً: نوع الرسالة الرسمي من السيرفر
    switch (type) {
      case 'image':
        return '📷 صورة';
      case 'audio':
      case 'voice':
        return '🎤 تسجيل صوتي';
      case 'video':
        return '🎬 فيديو';
      case 'file':
      case 'document':
        return '📁 ملف مرفق';
      case 'text':
        break;
      default:
        break;
    }

    // ✅ ثانيًا: التعرف من الامتداد
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif')) {
      return '📷 صورة';
    }

    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv')) {
      return '🎬 فيديو';
    }

    if (lower.endsWith('.m4a') ||
        lower.endsWith('.aac') ||
        lower.endsWith('.mp3') ||
        lower.endsWith('.wav')) {
      return '🎤 تسجيل صوتي';
    }

    if (lower.startsWith('http')) return '🔗 رابط';

    // ✅ ثالثًا: التعرف من Base64 (رؤوس الصور أو الصوت)
    if (raw.startsWith('/9j/') || // JPEG
        raw.startsWith('iVBOR') || // PNG
        raw.startsWith('R0lGOD')) {
      return '📷 صورة';
    }

    if (raw.startsWith('UklGR') || raw.startsWith('SUQz')) {
      return '🎤 تسجيل صوتي';
    }

    // Base64 عام وغير معروف
    if (RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(raw) && raw.length > 100) {
      return '📎 مرفق';
    }

    // الافتراضي → نص
    return raw;
  }
}