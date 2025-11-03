import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:special_text_between_marks/special_text_between_marks.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class CommentItem extends StatelessWidget {
  final String userName;
  final String comment;
  final DateTime? createdAt;
  final String? userImageUrl;

  const CommentItem({
    super.key,
    required this.userName,
    required this.comment,
    this.createdAt,
    this.userImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    final timeString = createdAt == null
        ? ''
        : timeago.format(createdAt!.toLocal(), locale: 'ar');

    Widget buildUserAvatar() {
      const double radius = 16;
      final image = userImageUrl;

      if (image != null && image.isNotEmpty) {
        return CachedNetworkImage(
          imageUrl: image,
          // ✅ التأكد من استخدام imageProvider كـ backgroundImage
          imageBuilder: (context, imageProvider) => CircleAvatar(
            radius: radius,
            backgroundImage: imageProvider,
          ),
          placeholder: (context, url) => const CircleAvatar(
            radius: radius,
            backgroundColor: ColorsManager.darkGray400,
          ),
          // ✅ عند فشل التحميل، يتم عرض أيقونة شخص
          errorWidget: (context, url, error) => const CircleAvatar(
            radius: radius,
            backgroundColor: ColorsManager.darkGray400,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        );
      } else {
        // إذا كان الرابط فارغاً، يتم عرض الصورة الافتراضية
        return const CircleAvatar(
          radius: radius,
          backgroundColor: ColorsManager.darkGray400,
          backgroundImage: AssetImage('assets/images/img.png'),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ColorsManager.grey100, width: 1),
          ),
          child: buildUserAvatar(),
        ),

        horizontalSpace(4),

        Expanded( // ✅ ضروري لتصحيح الـ Overflow
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Row(
                  children: [
                    Text(userName.isEmpty ? 'مستخدم' : userName,
                        style: TextStyles.font14Black500Weight),
                    const Spacer(),
                    MySvg(
                      image: 'more',
                      width: 24.w,
                      height: 24.h,
                    ),
                  ],
                ),
              ),
              verticalSpace(4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorsManager.dark50,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(4.r),
                  ),
                ),
                child: SpecialTextBetweenMarks(
                  text: comment.isEmpty
                      ? '...'
                      : comment,
                  openMark: '"',
                  closeMark: '"',
                  normalStyle: TextStyles.font14Black500Weight,
                  specialStyle: TextStyles.font14secondary600yellow400Weight,
                ),
              ),
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      timeString,
                      style: TextStyles.font12DarkGray400Weight,
                    ),
                  ),
                ),
              ),
              verticalSpace(12)
            ],
          ),
        ),
      ],
    );
  }
}