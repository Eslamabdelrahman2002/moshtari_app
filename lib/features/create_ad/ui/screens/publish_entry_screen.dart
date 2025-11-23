import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

import '../../../ad_action/ui/widgets/bid_type_dialog.dart';
import '../../../services/ui/widgets/service_app_bar.dart';
String _normalizeAuctionType(dynamic type) {
  final s = type?.toString().toLowerCase().trim() ?? 'single';
  if (s.contains('multi')) return 'multiple';       // يدعم: 'multi', 'multiple', 'multiple_auction'...
  if (s == 'true' || s == '1') return 'multiple';   // لو رجعت بوليني أو رقم
  return 'single';
}
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

              // الأزرار جنب بعض تحت البانر
              Row(
                children: [
                  Expanded(
                    child: _MiniFilledButton(
                      title: 'إنشاء إعلان',
                      icon: Icons.campaign_rounded,
                      onPressed: () => Navigator.of(context).pushNamed(Routes.createAdScreen),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _MiniOutlinedButton(
                      title: 'بدء مزاد',
                      icon: Icons.gavel_rounded,
                      onPressed: () async {
                        // 1) اختر التصنيف (سيارات/عقارات)
                        final selectedCategory = await showAuctionCategoryDialog(context);
                        if (selectedCategory == null) return;

                        // 2) اختر نوع المزاد (فردي/متعدد)
                        await showBidTypeDialog(
                          context,
                          initial: 'single',
                          onContinue: (type) {
                            final t = _normalizeAuctionType(type);
                            debugPrint('[PUBLISH] selectedCategory=$selectedCategory, type(raw)=$type, normalized=$t');

                            final route = (selectedCategory == 'cars')
                                ? Routes.createCarAuctionScreen
                                : Routes.createRealEstateAuctionScreen;

                            Navigator.of(context).pushNamed(
                              route,
                              arguments: {
                                'auctionType': t,           // 'single' أو 'multiple'
                                'isMultiple': t == 'multiple', // تأكيد إضافي
                              },
                            );
                          },
                          onBackHome: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              const Spacer(),

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

/* =================== Header =================== */

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

/* =================== Mini buttons (side-by-side) =================== */

class _MiniFilledButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const _MiniFilledButton({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ColorsManager.primaryColor, ColorsManager.primary400],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.primaryColor.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          height: 64.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Row(
            children: [


              Expanded(
                child: Text(title, style: TextStyles.font16White500Weight, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _MiniOutlinedButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const _MiniOutlinedButton({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        side: BorderSide(color: ColorsManager.dark200, width: 1.2),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
      child: Container(
        height: 64.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Row(
          children: [
            // Container(
            //   width: 30.w,
            //   height: 30.w,
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: ColorsManager.primary50,
            //     border: Border.all(color: ColorsManager.dark200),
            //   ),
            //   child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: ColorsManager.primary400, textDirection: TextDirection.ltr),
            // ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(title, style: TextStyles.font16Black500Weight, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: ColorsManager.dark50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: ColorsManager.dark200),
              ),
              child: Icon(icon, color: ColorsManager.primary400, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

/* =================== Info strip =================== */

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

/* =================== مزاد: اختيار التصنيف (BottomSheet) =================== */

Future<String?> showAuctionCategoryDialog(BuildContext context) async {
  String? selected; // 'cars' | 'real_estate'

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h + MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // عنوان
                Row(
                  children: [
                    const Spacer(),
                    Text('اختر نوع المزاد', style: TextStyles.font16Black500Weight),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(ctx).pop()),
                  ],
                ),
                SizedBox(height: 12.h),

                // خيارات
                Row(
                  children: [
                    Expanded(
                      child: _AuctionChoiceCard(
                        title: 'عقارات',
                        selected: selected == 'real_estate',
                        onTap: () => setState(() => selected = 'real_estate'),
                        iconSvg: 'real_state_actions',
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _AuctionChoiceCard(
                        title: 'سيارات',
                        selected: selected == 'cars',
                        onTap: () => setState(() => selected = 'cars'),
                        iconSvg: 'car_actions',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                PrimaryButton(
                  text: 'التالي',
                  onPressed: () {
                    if (selected == null) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('الرجاء اختيار نوع المزاد')),
                      );
                      return;
                    }
                    Navigator.of(ctx).pop(selected);
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _AuctionChoiceCard extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final String? iconSvg;

  const _AuctionChoiceCard({
    required this.title,
    required this.selected,
    required this.onTap,
    this.iconSvg,
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
                    decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
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
              child: iconSvg != null
                  ? MySvg(image: iconSvg!)
                  : const Icon(Icons.category_rounded, color: ColorsManager.primary400),
            ),
            SizedBox(height: 8.h),
            Text(title, style: TextStyles.font14Dark500Weight),
          ],
        ),
      ),
    );
  }
}