import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/safe_cached_image.dart';
import 'package:mushtary/features/messages/data/models/messages_model.dart';

class ChatSelledItem extends StatelessWidget {
  final AdInfo? adInfo;
  const ChatSelledItem({super.key, this.adInfo});

  @override
  Widget build(BuildContext context) {
    if (adInfo == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            offset: const Offset(0, -2),
            blurRadius: 16.r,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 48.h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xffECECEC),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: SafeNetworkImage(url: adInfo!.imageUrl),
          ),
          horizontalSpace(16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(adInfo!.title, style: TextStyles.font16Black500Weight, maxLines: 1, overflow: TextOverflow.ellipsis),
              verticalSpace(10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: adInfo!.price, style: TextStyles.font16Primary500500Weight),
                    TextSpan(text: ' ر.س', style: TextStyles.font10Primary400Weight),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          InkWell(
            onTap: () {},
            child: const RotatedBox(
              quarterTurns: 2,
              child: MySvg(image: 'back_arrow', color: ColorsManager.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}