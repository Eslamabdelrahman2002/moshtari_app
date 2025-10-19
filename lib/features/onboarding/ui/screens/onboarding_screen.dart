import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Model لكل صفحة
class OnboardingModel {
  final String image;
  final String title;             // الجزء الأسود
  final String coloredTitlePart;  // الجزء الأصفر (مع underline)
  final String description;

  OnboardingModel({
    required this.image,
    required this.title,
    required this.coloredTitlePart,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingModel> _onboardingData = [
    OnboardingModel(
      image: 'assets/images/onboarding1.png',
      title: 'كل ما تحتاجه في ',
      coloredTitlePart: 'منصة واحدة',
      description:
      'منصة "مشتري" تجمع لك السيارات، المزادات، اللوازم، والخدمات في مكان واحد لتجربة شراء وبيع سهلة وسريعة.',
    ),
    OnboardingModel(
      image: 'assets/images/onboarding2.png',
      title: 'مزادات حية وعروض ',
      coloredTitlePart: 'مخصصة',
      description:
      'شارك في المزادات لحظيًا أو قدم عروضك على طلبات لعملاء مهتمين – سواء كنت بائعًا أو مقدم خدمة. فرصتك تبدأ من هنا.',
    ),
    OnboardingModel(
      image: 'assets/images/onboarding3.png',
      title: 'تسجيل آمن و',
      coloredTitlePart: 'بدء فوري',
      description:
      'أنشئ حسابك كبائع أو ابدأ الشراء أو تقديم خدماتك بثقة مع تواصل آمن داخل التطبيق وحماية كاملة لحقوقك.',
    ),
  ];

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, Routes.loginScreen);
  }

  void _goPrev() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // لو تحب يرجع للشاشة السابقة في النافجيشن:
      // Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // تكبير الهيدر عشان الصورة تكون أكبر وثابتة
    final double headerH = 1.sh * 0.55;

    return Scaffold(
      body: Column(
        children: [
          // الهيدر (خلفية زرقاء + صورة الموبايل مثبتة أسفل)
          SizedBox(
            height: headerH,
            width: double.infinity,
            child: Stack(
              children: [
                // الخلفية الزرقاء مع انحناءة أسفل
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.r),
                      bottomRight: Radius.circular(30.r),
                    ),
                    child: Image.asset(
                      'assets/images/background_onboarding.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // زر "تخطي"
                Positioned(
                  top: 8.h,
                  left: 20.w,
                  child: SafeArea(
                    child: TextButton(
                      onPressed: _navigateToLogin,
                      child: Text('تخطي', style: TextStyles.font16White500Weight),
                    ),
                  ),
                ),

                // زر السهم للرجوع لصفحة قبلها
                Positioned(
                  top: 8.h,
                  right: 20.w,
                  child: SafeArea(
                    child: IconButton(
                      icon: Icon(Icons.keyboard_arrow_right,
                          color: Colors.white, size: 30.w),
                      onPressed: _goPrev,
                    ),
                  ),
                ),

                // صورة الموبايل كبيرة ومثبتة أسفل
                Positioned.fill(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _onboardingData.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          widthFactor: 0.75, // كبّر/صغّر من 0.70–0.80 حسب الحاجة
                          child: Image.asset(
                            _onboardingData[index].image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // الجزء السفلي
          Expanded(
            child: Container(
              color: Colors.white,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      // العنوان بالشكل المطلوب
                      TitleWithSvgUnderline(
                        prefix: _onboardingData[_currentPage].title,
                        highlight: _onboardingData[_currentPage].coloredTitlePart,
                        normalStyle: TextStyles.font24Black700Weight,
                        highlightStyle: TextStyles.font24Yellow700Weight,
                        underlineAsset: 'onboadring_underline',
                        underlineHeight: 12,
                        underlineGap: 8, // ابعاد العلامة شوية (زد/قلّل الرقم)
                      ),

                      verticalSpace(16.h),

                      // الوصف
                      Text(
                        _onboardingData[_currentPage].description,
                        style: TextStyles.font16DarkGrey400Weight,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: _onboardingData.length,
                        effect: ExpandingDotsEffect(
                          dotWidth: 8.w,
                          dotHeight: 8.h,
                          radius: 16.r,
                          spacing: 6.w,
                          expansionFactor: 3,
                          activeDotColor: ColorsManager.primary500,
                          dotColor: ColorsManager.grey200,
                        ),
                      ),
                      verticalSpace(32.h),
                      PrimaryButton(
                        text: _currentPage == _onboardingData.length - 1
                            ? 'ابدأ'
                            : 'التالي',
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            _navigateToLogin();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ويدجت العنوان: الجزء الأصفر + خط أصفر تحته بمسافة قابلة للتعديل
class TitleWithSvgUnderline extends StatelessWidget {
  const TitleWithSvgUnderline({
    super.key,
    required this.prefix,
    required this.highlight,
    required this.normalStyle,
    required this.highlightStyle,
    required this.underlineAsset,
    this.underlineHeight = 12,
    this.horizontalPadding = 0,
    this.underlineGap = 6, // المسافة الإضافية بين النص والخط الأصفر
  });

  final String prefix;               // النص الأسود
  final String highlight;            // النص الأصفر
  final TextStyle normalStyle;
  final TextStyle highlightStyle;
  final String underlineAsset;       // اسم/مسار SVG للخط الأصفر
  final double underlineHeight;
  final double horizontalPadding;
  final double underlineGap;

  @override
  Widget build(BuildContext context) {
    const dir = TextDirection.rtl;

    // دعم وجود مسافات قبل الجزء الأصفر (لو كتبت " منصة")
    final trimmed = highlight.trimLeft();
    final leadingSpaces = highlight.length - trimmed.length;

    // نحسب المقاسات بالحجم الأصلي
    final prefixPainter = TextPainter(
      text: TextSpan(text: prefix, style: normalStyle),
      textDirection: dir,
      maxLines: 1,
    )..layout();

    final spacesPainter = TextPainter(
      text: TextSpan(text: ' ' * leadingSpaces, style: highlightStyle),
      textDirection: dir,
      maxLines: 1,
    )..layout();

    final trimmedPainter = TextPainter(
      text: TextSpan(text: trimmed, style: highlightStyle),
      textDirection: dir,
      maxLines: 1,
    )..layout();

    final fullPainter = TextPainter(
      text: TextSpan(children: [
        TextSpan(text: prefix, style: normalStyle),
        TextSpan(text: highlight, style: highlightStyle),
      ]),
      textDirection: dir,
      maxLines: 1,
    )..layout();

    final startX = prefixPainter.width + spacesPainter.width; // بداية الجزء الأصفر
    final underlineW = trimmedPainter.width;                  // عرض الجزء الأصفر
    final totalW = fullPainter.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth - horizontalPadding * 2;

        // الـStack بالحجم الطبيعي
        final titleStack = SizedBox(
          width: totalW,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // النص (سطر واحد)
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: prefix, style: normalStyle),
                  TextSpan(text: highlight, style: highlightStyle),
                ]),
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                textDirection: dir,
              ),

              // الخط الأصفر: أبعدناه بمقدار underlineGap
              PositionedDirectional(
                start: startX,                           // من اليمين في RTL
                bottom: -(underlineHeight * 0.45 + underlineGap),
                child: SizedBox(
                  width: underlineW,
                  height: underlineHeight,
                  child: MySvg(
                    image: underlineAsset,               // تأكد من المسار داخل MySvg
                  ),
                ),
              ),
            ],
          ),
        );

        // تصغير تلقائي لو المساحة أقل
        if (totalW > maxW && maxW > 0) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: titleStack,
              ),
            ),
          );
        }

        return Center(child: titleStack);
      },
    );
  }
}