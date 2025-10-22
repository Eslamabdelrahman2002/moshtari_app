// lib/features/product_details/ui/widgets/publish_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

import '../../../ad_action/ui/widgets/bid_type_dialog.dart';
import '../../../home/ui/widgets/home_screen_app_bar.dart';
import '../../../services/ui/widgets/service_app_bar.dart';

class PublishEntryScreen extends StatelessWidget {
  const PublishEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ServiceAppBar(),
              _ProHeader(),
              SizedBox(height: 16.h),

              // كرت إنشاء إعلان
              _ActionCard(
                title: 'إنشاء إعلان',
                subtitle: 'اعرض منتجك أو خدمتك بسرعة واحترافية',
                icon: Icons.campaign_rounded,
                filled: true,
                onTap: () => Navigator.of(context).pushNamed(Routes.createAdScreen),
              ),
              SizedBox(height: 12.h),

              // كرت بدء مزاد (يستخدم الديالوج لتحديد النوع أولاً)
              _ActionCard(
                title: 'بدء مزاد',
                subtitle: 'إدارة مزاد بسيط أو متعدد العناصر',
                icon: Icons.gavel_rounded,
                filled: false,
                onTap: () async {
                  // 1) اختر التصنيف (سيارات/عقارات)
                  final selectedCategory = await showAuctionCategoryDialog(context);
                  if (selectedCategory == null) return;

                  // 2) اختر نوع المزاد (فردي/متعدد)
                  await showBidTypeDialog(
                    context,
                    initial: 'single',
                    onContinue: (type) {
                      if (selectedCategory == 'cars') {
                        Navigator.of(context).pushNamed(
                          Routes.createCarAuctionScreen,
                          // تمرير نوع المزاد المختار: single أو multiple
                          arguments: {'auctionType': type},
                        );
                      } else if (selectedCategory == 'real_estate') {
                        Navigator.of(context).pushNamed(
                          Routes.createRealEstateAuctionScreen,
                          // تمرير نوع المزاد المختار: single أو multiple
                          arguments: {'auctionType': type},
                        );
                      }
                    },
                    onBackHome: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  );
                },
              ),

              const Spacer(),

              // شريط معلومات
              _InfoStrip(
                text: 'يمكنك متابعة حالة المزادات والإعلانات من لوحة التحكم.',
                icon: Icons.info_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          colors: [ColorsManager.primaryColor, ColorsManager.primary400],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primary400.withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -10,
            child: _CircleBlur(size: 90, color: Colors.white.withOpacity(.08)),
          ),
          Positioned(
            bottom: -18,
            left: -8,
            child: _CircleBlur(size: 70, color: Colors.white.withOpacity(.10)),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ابدأ الآن ✨', style: TextStyles.font20White500Weight),
                      SizedBox(height: 6.h),
                      Text(
                        'اختَر ما تريد نشره: إعلان سريع أو مزاد احترافي.',
                        style: TextStyles.font12White400Weight,
                      ),
                      SizedBox(height: 12.h),
                      const Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _Pill(text: 'سهل وسريع'),
                          _Pill(text: 'واجهة احترافية'),
                          _Pill(text: 'نتائج أفضل'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyles.font12White400Weight),
    );
  }
}

class _CircleBlur extends StatelessWidget {
  final double size;
  final Color color;
  const _CircleBlur({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? LinearGradient(
      colors: [ColorsManager.primaryColor, ColorsManager.primaryColor.withOpacity(0.9)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    )
        : null;

    final Color textColor = filled ? Colors.white : Colors.black;
    final Color subColor = filled ? Colors.white.withOpacity(0.85) : ColorsManager.darkGray;
    final Color borderColor = filled ? Colors.transparent : ColorsManager.dark200;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Ink(
        decoration: BoxDecoration(
          color: filled ? null : Colors.white,
          gradient: bg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            if (filled)
              BoxShadow(
                color: ColorsManager.primaryColor.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: filled ? Colors.white.withOpacity(0.18) : ColorsManager.primary50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: filled ? Colors.white : ColorsManager.primaryColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: filled ? TextStyles.font16White500Weight : TextStyles.font16Black500Weight),
                    SizedBox(height: 2.h),
                    Text(subtitle, style: TextStyle(color: subColor, fontSize: 12.sp)),
                  ],
                ),
              ),
              _ArrowCircle(filled: filled),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowCircle extends StatelessWidget {
  final bool filled;
  const _ArrowCircle({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? Colors.white.withOpacity(0.2) : ColorsManager.primary50,
        border: Border.all(
          color: filled ? Colors.white.withOpacity(0.35) : ColorsManager.primaryColor,
        ),
      ),
      child: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 16.sp,
        color: filled ? Colors.white : ColorsManager.primary400,
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  final String text;
  final IconData icon;
  const _InfoStrip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: ColorsManager.primary50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: ColorsManager.primary100),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: ColorsManager.primary400),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: TextStyles.font12DarkGray400Weight)),
        ],
      ),
    );
  }
}

/// دايالوج اختيار نوع المزاد (تصنيف رئيسي)
Future<String?> showAuctionCategoryDialog(BuildContext context) async {
  String? selected; // 'cars' | 'real_estate'

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text('اختر نوع المزاد', style: TextStyles.font16Black500Weight),
                            SizedBox(width: 6.w),
                            const Tooltip(
                              message: 'اختر تصنيف المزاد للمتابعة',
                              child: Icon(Icons.info_outline, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        child: _AuctionChoiceCard(
                          title: 'عقارات',
                          selected: selected == 'real_estate',
                          onTap: () => setState(() => selected = 'real_estate'),
                          icon: 'real_state_actions',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _AuctionChoiceCard(
                          title: 'سيارات',
                          selected: selected == 'cars',
                          onTap: () => setState(() => selected = 'cars'),
                          icon: 'car_actions',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'التالي',
                          onPressed: () {
                            if (selected == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('الرجاء اختيار نوع المزاد')),
                              );
                              return;
                            }
                            Navigator.of(ctx).pop(selected);
                          },
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

class _AuctionChoiceCard extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final String icon;

  const _AuctionChoiceCard({
    required this.title,
    required this.selected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? ColorsManager.primary400 : ColorsManager.dark200;
    final dotColor = selected ? ColorsManager.primary400 : Colors.transparent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor, width: 1.4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 18.w,
                height: 18.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.6),
                ),
                child: Center(
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: ColorsManager.primary50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: MySvg(image: icon),
            ),
            SizedBox(height: 8.h),
            Text(title, style: TextStyles.font14Dark500Weight),
          ],
        ),
      ),
    );
  }
}