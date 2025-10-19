import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class MessageDataWidget extends StatelessWidget {
  final String message;
  final bool isSended;
  const MessageDataWidget({
    super.key,
    required this.message,
    this.isSended = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isSended ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(bottom: 16.h, start: 16.w, end: 16.w, top: 16.h),
          child: Stack(
            children: [
              if (isSended)
                Positioned(
                  bottom: 6.h,
                  left: 0,
                  child: const MySvg(image: 'sended_message_tail'),
                ),
              if (!isSended)
                Positioned(
                  bottom: 6.h,
                  right: 0,
                  child: const MySvg(image: 'recieved_message_tail'),
                ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(right: isSended ? 5.w : 0, left: isSended ? 0 : 5.w),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSended ? ColorsManager.primary400 : ColorsManager.dark100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    message,
                    style: isSended
                        ? TextStyles.font14Black400Weight.copyWith(color: Colors.white)
                        : TextStyles.font14Black400Weight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}