import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

Future<void> showAuctionModeDialog(
    BuildContext context, {
      required void Function(String mode) onNext, // 'single' | 'multiple'
      String initial = 'single',
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
            return Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: MySvg(image: 'ic_close', width: 20.w, height: 20.h),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'اختر نوع المزاد',
                        style: TextStyles.font16Dark400Weight.copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 6.w),
                      MySvg(image: 'ic_info', width: 16.w, height: 16.h),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _ModeCard(
                          title: 'مزاد فردي',
                          icon: 'auction_single',
                          selected: selected == 'single',
                          onTap: () => setState(() => selected = 'single'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _ModeCard(
                          title: 'مزاد متعدد',
                          icon: 'auction_multi',
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
                            minimumSize: Size.fromHeight(52.h),
                          ),
                          child: const Text('العودة للرئيسية'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onNext(selected);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.primaryColor,
                            shape:
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                            elevation: 0,
                            minimumSize: Size.fromHeight(52.h),
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

class _ModeCard extends StatelessWidget {
  final String title;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? ColorsManager.primaryColor : ColorsManager.dark200;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          height: 140.h,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 18.w,
                height: 18.w,
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
              const Spacer(),
              Center(child: MySvg(image: icon, width: 56.w, height: 56.h)),
              SizedBox(height: 8.h),
              Center(
                child: Text(
                  title,
                  style: TextStyles.font14Black500Weight.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}