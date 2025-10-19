import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../data/models/banner_model.dart';



class HomeBanners extends StatefulWidget {
  const HomeBanners({super.key});

  @override
  State<HomeBanners> createState() => _HomeBannersState();
}

class _HomeBannersState extends State<HomeBanners> {
  final _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  // ✨ UPDATE: We define the number of static banners here
  final int _bannerCount = 3;

  @override
  void initState() {
    super.initState();
    // Start the timer to auto-scroll the banners
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (!mounted) return;
      if (_currentPage < _bannerCount - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        children: [
          Container(
            height: 155.h,
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: ColorsManager.secondary.withOpacity(0.5),
                width: 2.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r), // Slightly smaller to show border
              // ✨ UPDATE: Use PageView to create a scrollable banner
              child: PageView.builder(
                controller: _pageController,
                itemCount: _bannerCount,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  // This is the content for each banner page
                  return _buildBannerContent();
                },
              ),
            ),
          ),
          verticalSpace(8),
          // ✨ UPDATE: Add the page indicator
          SmoothPageIndicator(
            controller: _pageController,
            count: _bannerCount,
            effect: ExpandingDotsEffect(
              dotWidth: 8.w,
              dotHeight: 8.h,
              activeDotColor: ColorsManager.primaryColor,
              dotColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  // ✨ Helper method to build the static content, avoiding code repetition
  Widget _buildBannerContent() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // ✨ FIX: Use MainAxisAlignment.spaceBetween to push the button to the bottom
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Group the text together
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyles.font16White500Weight.copyWith(height: 1),
                        children: const [
                          TextSpan(text: 'كل شيء تبيعه أو تشتريه...\nتلقاه في '),
                          TextSpan(
                            text: 'مشترى!',
                            style: TextStyle(color: ColorsManager.secondary),
                          ),
                        ],
                      ),
                    ),
                    verticalSpace(4),
                    Text(
                      'منصة شاملة لبيع وشراء السيارات، العقارات، والمزيد.',
                      style: TextStyles.font10White500Weight,
                    ),
                  ],
                ),
                // Button at the bottom
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: ColorsManager.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                  ),
                  child: Text(
                    'إبدأ الآن',
                    style: TextStyles.font14Blue400Weight,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Car Image
        Align(
          alignment: Alignment.bottomLeft,
          child: Image.asset(
            'assets/images/car.png',
            width: 180.w,
            height: 180.h,
            fit: BoxFit.cover,
          ),
        )
      ],
    );
  }
}