import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/product_details/ui/widgets/comment_item.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

class RealEstateCommentsView extends StatelessWidget {
  final List<dynamic> comments;

  const RealEstateCommentsView({super.key, required this.comments});

  String? _safeString(dynamic v) => v?.toString().trim().isEmpty ?? true ? null : v.toString();

  @override
  Widget build(BuildContext context) {
    final currentUsername =
    context.select<ProfileCubit, String?>((cubit) => cubit.user?.username);

    if (comments.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Text('لا توجد تعليقات بعد 👀', style: TextStyles.font14DarkGray400Weight),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('التعليقات', style: TextStyles.font16Dark300Grey400Weight),
          verticalSpace(8),
          ...comments.map((c) {
            final map = c as Map<String, dynamic>;

            // استخراج الاسم
            String? nameFromComment;
            final rawName = map['user_name'] ??
                map['username'] ??
                (map['user'] is Map ? map['user']['username'] : null);
            nameFromComment = _safeString(rawName);

            // ✅ الجزء الهام: استخراج رابط الصورة
            String? imageUrl;
            // 1. التحقق من المفاتيح المباشرة
            final rawImage = map['user_profile_image'] ??
                map['user_image'] ??
                map['user_avatar'];

            // 2. التحقق من مفاتيح داخل كائن "user"
            final userMap = map['user'] as Map<String, dynamic>?;
            final userRawImage = userMap?['profile_image'] ??
                userMap?['image'] ??
                userMap?['avatar']; // مفاتيح محتملة أخرى

            imageUrl = _safeString(rawImage ?? userRawImage);

            // ... (بقية منطق الاستخراج)
            final userName = (nameFromComment != null)
                ? nameFromComment
                : ((currentUsername?.trim().isNotEmpty ?? false)
                ? currentUsername!.trim()
                : 'مستخدم');

            final text = _safeString(map['comment_text'] ?? map['text'] ?? '') ?? '...';
            final createdAtStr = _safeString(map['created_at']);
            DateTime? createdAt;
            if (createdAtStr != null) {
              createdAt = DateTime.tryParse(createdAtStr);
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: CommentItem(
                userName: userName,
                comment: text,
                createdAt: createdAt,
                userImageUrl: imageUrl, // ✅ تمرير رابط الصورة
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}