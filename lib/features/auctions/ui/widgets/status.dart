import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';

class Status extends StatelessWidget {
  const Status({
    super.key,
    this.color = Colors.green,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(right: 4.w, bottom: 4.w),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(
              color: Colors.white,
              width: 0.5.w,
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 3.65,
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3.r),
                border: Border.all(
                  color: Colors.white,
                  width: 0.5.w,
                ),
              ),
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 3.65,
          child: Padding(
            padding: EdgeInsets.only(left: 4.w, top: 4.w),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2.r),
                border: Border.all(
                  color: Colors.white,
                  width: 0.5.w,
                ),
              ),
              alignment: Alignment.center,
              child: Baseline(
                baseline: 3.w,
                baselineType: TextBaseline.alphabetic,
                child: Text(
                  'مزاد متعدد',
                  style: TextStyles.font12White400Weight.copyWith(height: 0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
