import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

Future<void> showBidTypeDialog(
    BuildContext context, {
      String initial = 'multiple', // single | multiple
      required void Function(String type) onContinue,
      VoidCallback? onBackHome,
    }) async {
  String selected = initial;
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: MySvg(image: 'ic_close', width: 22.w, height: 22.h),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: MySvg(image: 'info-circle', width: 16.w, height: 15.h,color: ColorsManager.black,)),
                      SizedBox(width: 6.w),
                      Text(
                        'اختر نوع المزاد',
                        style: TextStyles.font16Dark400Weight
                            .copyWith(fontWeight: FontWeight.w700, fontSize: 18.sp),
                      ),
                      SizedBox(width: 6.w),

                    ],
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Expanded(
                        child: _BidTypeCard(
                          title: 'مزاد فردي',
                          icon: 'single_action', // أيقونة مناسبة
                          selected: selected == 'single',
                          onTap: () => setState(() => selected = 'single'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _BidTypeCard(
                          title: 'مزاد متعدد',
                          icon: 'multi_actions', // أيقونة مناسبة
                          selected: selected == 'multiple',
                          onTap: () => setState(() => selected = 'multiple'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onBackHome ?? () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: ColorsManager.primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: const Text('العودة للرئيسية'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onContinue(selected);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.primaryColor,
                            shape:
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            elevation: 0,
                          ),
                          child: const Text('عرض المزاد'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

class _BidTypeCard extends StatelessWidget {
  final String title;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  const _BidTypeCard(
      {required this.title, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? ColorsManager.primaryColor : ColorsManager.dark200;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          height: 140.h,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1.6),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 1.8),
                    color: Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? ColorsManager.primaryColor : Colors.transparent,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: MySvg(image: 'info-circle', width: 16.w, height: 16.h),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MySvg(image: icon, width: 64.w, height: 50.h),
                  SizedBox(height: 8.h),
                  Text(title, style: TextStyles.font16Black500Weight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}