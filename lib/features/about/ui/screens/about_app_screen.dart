import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.white,
      appBar: AppBar(
        backgroundColor: ColorsManager.white,
        elevation: 0,
        centerTitle: true,
        title: Text('عن التطبيق', style: TextStyles.font20Black500Weight),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderCard(),
            verticalSpace(16),
            Text('إحصائيات سريعة', style: TextStyles.font18Black500Weight),
            verticalSpace(10),
            const _StatsRow(),
            verticalSpace(16),
            Text('ماذا يقدّم مشتري؟', style: TextStyles.font18Black500Weight),
            verticalSpace(10),
            const _FeaturesGrid(),
            verticalSpace(20),

            verticalSpace(20),
            const _ContactCard(),
            verticalSpace(24),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'الموقع الرسمي',
                    onPressed: () => _openUrl('https://mushtary.sa/'),
                    isOutlineButton: true,
                    backgroundColor: Colors.white,
                    borderColor: ColorsManager.primaryColor,
                    textColor: ColorsManager.primaryColor,
                    // استخدمت MySvg
                    prefixIcon: const MySvg(image: 'globe'),
                  ),
                ),
                horizontalSpace(12),
                Expanded(
                  child: PrimaryButton(
                    text: 'سياسة الاستخدام',
                    onPressed: () {
                      // افتح شاشة سياسة الاستخدام لو مسجلة في الراوتر
                      // Navigator.of(context).pushNamed(Routes.usagePolicyScreen);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('سياسة الاستخدام ستتوفر قريبًا')),
                      );
                    },
                    isOutlineButton: true,
                    backgroundColor: Colors.white,
                    borderColor: ColorsManager.primaryColor,
                    textColor: ColorsManager.primaryColor,
                    prefixIcon: const MySvg(image: 'help_center'),
                  ),
                ),
              ],
            ),
            verticalSpace(12),
            PrimaryButton(
              text: 'قيّم التطبيق',
              onPressed: () => _openUrl('https://play.google.com/store/apps/details?id=com.mushtary.app'),
              prefixIcon: const Icon(Icons.star, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  static void _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ---------------- Header ----------------
class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: Stack(
        children: [
          Container(
            height: 190.h, // زودت الارتفاع لتفادي أي overflow
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColorsManager.primaryColor, ColorsManager.primary400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            right: -50.w,
            top: -50.w,
            child: _CircleBlur(size: 160.w, color: Colors.white.withOpacity(0.08)),
          ),
          Positioned(
            left: -30.w,
            bottom: -30.w,
            child: _CircleBlur(size: 120.w, color: Colors.white.withOpacity(0.07)),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
              child: Container(color: Colors.transparent),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Center(
                    // MySvg من ملفاتك
                    child: MySvg(image: 'logo', color: Colors.white, width: 32.w, height: 32.w),
                  ),
                ),
                horizontalSpace(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('مشتري', style: TextStyles.font24White500Weight),
                      verticalSpace(4),
                      Text(
                        'منصة موحّدة للإعلانات والمزادات وطلب الخدمات.',
                        style: TextStyles.font12Primary100400Weight.copyWith(color: Colors.white.withOpacity(0.95)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      verticalSpace(6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text('الإصدار v1.0.0', style: TextStyles.font12Primary100400Weight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBlur extends StatelessWidget {
  final double size;
  final Color color;
  const _CircleBlur({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }
}

// ---------------- Stats ----------------
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _StatBadge(icon: 'user', label: 'مستخدمون', value: '85K+')),
        SizedBox(width: 10),
        Expanded(child: _StatBadge(icon: 'chart', label: 'مزادات', value: '3.2K+')),
        SizedBox(width: 10),
        Expanded(child: _StatBadge(icon: 'discount', label: 'إعلانات', value: '12.4K+')),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _StatBadge({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96.h, // زيادة بسيطة لتفادي Overflow
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: ColorsManager.dark100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: ColorsManager.primary50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(child: MySvg(image: icon, color: ColorsManager.primaryColor, width: 22.w, height: 22.w)),
            ),
            horizontalSpace(10),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(value, style: TextStyles.font16Black500Weight),
                    verticalSpace(2),
                    Text(label, style: TextStyles.font12DarkGray400Weight, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Features ----------------
class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid();

  @override
  Widget build(BuildContext context) {
    final items = [
      _FeatureData('الإعلانات', 'انشر إعلانك بسهولة للوصول للجمهور المناسب.', 'discount'),
      _FeatureData('المزادات', 'شارك أو أنشئ مزادك وحدد الشروط.', 'chart'),
      _FeatureData('طلب خدمة', 'اطلب نقل/عامل/مزود خدمة بخطوات بسيطة.', 'work'),
      _FeatureData('الرسائل الآمنة', 'محادثات مشفّرة وإبلاغ للمخالفات.', 'message'),
      _FeatureData('محفظة ودفع', 'شحن وسحب عبر وسائل دفع موثوقة.', 'wallet'),
      _FeatureData('تتبّع العروض', 'تابع عروضك واستجابات العملاء.', 'send-1'),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        mainAxisExtent: 146.h, // زوّدتها لعلاج bottom overflow
      ),
      itemBuilder: (_, i) => _FeatureCard(data: items[i]),
    );
  }
}

class _FeatureData {
  final String title;
  final String desc;
  final String icon;
  _FeatureData(this.title, this.desc, this.icon);
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;
  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: ColorsManager.dark100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w, height: 40.w,
              decoration: BoxDecoration(
                color: ColorsManager.secondary50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(child: MySvg(image: data.icon, color: ColorsManager.secondary500, width: 22.w, height: 22.w)),
            ),
            verticalSpace(8),
            Text(
              data.title,
              style: TextStyles.font14Black500Weight,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            verticalSpace(6),
            Expanded(
              // لتفادي overflow نخلي الوصف ياخد المساحة المتبقية
              child: Text(
                data.desc,
                style: TextStyles.font12DarkGray400Weight,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Social & Contact ----------------



class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: ColorsManager.dark100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تواصل معنا', style: TextStyles.font16Black500Weight),
          verticalSpace(12),
          _ContactRow(
            icon: Icons.email_outlined,
            label: 'البريد',
            value: 'support@mushtary.sa',
            onTap: () => launchUrl(Uri.parse('mailto:support@mushtary.sa'), mode: LaunchMode.externalApplication),
          ),
          verticalSpace(8),
          _ContactRow(
            icon: Icons.call_outlined,
            label: 'الهاتف',
            value: '+966 50 000 0000',
            onTap: () => launchUrl(Uri.parse('tel:+966500000000'), mode: LaunchMode.externalApplication),
          ),
          verticalSpace(8),
          _ContactRow(
            icon: Icons.public,
            label: 'الموقع',
            value: 'mushtary.sa',
            onTap: () => launchUrl(Uri.parse('https://mushtary.sa/'), mode: LaunchMode.externalApplication),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: ColorsManager.primary50,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: ColorsManager.primaryColor, size: 18.w),
          ),
          horizontalSpace(10),
          Expanded(
            child: Text('$label: $value', style: TextStyles.font14DarkGray400Weight, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Icon(Icons.chevron_left, color: ColorsManager.darkGray300),
        ],
      ),
    );
  }
}