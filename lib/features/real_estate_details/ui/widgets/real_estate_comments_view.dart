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

            // استخرج الاسم من التعليق
            String? nameFromComment;
            final raw = map['user_name'] ??
                map['username'] ??
                (map['user'] is Map ? map['user']['username'] : null);
            if (raw != null) nameFromComment = raw.toString().trim();

            // fallback للبروفايل أو "مستخدم"
            final userName = (nameFromComment != null && nameFromComment.isNotEmpty)
                ? nameFromComment
                : ((currentUsername?.trim().isNotEmpty ?? false)
                ? currentUsername!.trim()
                : 'مستخدم');

            final text = (map['comment_text'] ?? map['text'] ?? '').toString();

            // created_at -> DateTime?
            final createdAtStr = (map['created_at'] ?? '').toString();
            DateTime? createdAt;
            if (createdAtStr.isNotEmpty) {
              createdAt = DateTime.tryParse(createdAtStr);
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: CommentItem(
                userName: userName,
                comment: text.isEmpty ? '...' : text,
                createdAt: createdAt,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}