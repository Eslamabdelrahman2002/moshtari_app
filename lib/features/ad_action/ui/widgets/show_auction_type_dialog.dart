import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

Future<void> showAuctionTypeDialog(
    BuildContext context, {
      required void Function(String key) onNext, // 'real_estate' | 'car'
      String initial = 'real_estate',
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
                  // Close
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: MySvg(image: 'ic_close', width: 20.w, height: 20.h),
                    ),
                  ),
                  // Title + info
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
                  // Cards
                  Row(
                    children: [
                      Expanded(
                        child: _AuctionTypeCard(
                          title: 'عقارات',
                          icon: 'auction_house',
                          selected: selected == 'real_estate',
                          onTap: () => setState(() => selected = 'real_estate'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _AuctionTypeCard(
                          title: 'سيارات',
                          icon: 'auction_car',
                          selected: selected == 'car',
                          onTap: () => setState(() => selected = 'car'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Next button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onNext(selected);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primary400,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        elevation: 0,
                      ),
                      child: const Text('التالي'),
                    ),
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

class _AuctionTypeCard extends StatelessWidget {
  final String title;
  final String icon; // MySvg asset name
  final bool selected;
  final VoidCallback onTap;

  const _AuctionTypeCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? ColorsManager.primary400 : ColorsManager.dark200;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          height: 130.h,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio-like circle
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
                    color: selected ? ColorsManager.primary400 : Colors.transparent,
                  ),
                ),
              ),
              const Spacer(),
              Center(child: MySvg(image: icon, width: 48.w, height: 48.h)),
              SizedBox(height: 8.h),
              Center(
                child: Text(
                  title,
                  style: TextStyles.font14Black500Weight.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}