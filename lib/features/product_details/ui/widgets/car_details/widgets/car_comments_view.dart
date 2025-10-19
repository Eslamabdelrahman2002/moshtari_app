import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/product_details/data/model/car_details_model.dart';
import 'package:mushtary/features/product_details/ui/widgets/comment_item.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

// انتبه لمسار الموديل عندك (models وليست model)

class CarCommentsView extends StatelessWidget {
  final List<CommentModel> comments;

  const CarCommentsView({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    final currentUsername =
    context.select<ProfileCubit, String?>((cubit) => cubit.user?.username);

    if (comments.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Text(
          "لا توجد تعليقات بعد 👀",
          style: TextStyles.font14DarkGray400Weight,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("التعليقات", style: TextStyles.font16Dark300Grey400Weight),
          verticalSpace(8),
          ...comments.map((c) {
            final cName = (c.userName).trim();
            final userName = cName.isNotEmpty
                ? cName
                : ((currentUsername?.trim().isNotEmpty ?? false)
                ? currentUsername!.trim()
                : 'مستخدم');

            final text = c.text.trim();

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: CommentItem(
                userName: userName,
                comment: text.isEmpty ? '...' : text,
                // CommentModel لا يحتوي createdAt، لذلك نمرر null
                createdAt: null,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}