import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ServiceBanners extends StatelessWidget {
  ServiceBanners({
    super.key, required banners,
  });

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 144.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 2,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: '' '',
                  width: double.infinity,
                  height: 144.h,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 144.h,
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryColor,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                  imageBuilder: (context, imageProvider) => Container(
                    width: double.infinity,
                    height: 144.h,
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryColor,
                      borderRadius: BorderRadius.circular(24.r),
                      image: DecorationImage(
                        image: NetworkImage(''),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 144.h,
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryColor,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                );
              },
            ),
          ),
          verticalSpace(4),
          SmoothPageIndicator(
            controller: _pageController,
            count: 4,
            effect: ExpandingDotsEffect(
              dotWidth: 8,
              dotHeight: 8,
              radius: 4.r,
              spacing: 4,
              expansionFactor: 2,
              activeDotColor: ColorsManager.primaryColor,
              dotColor: ColorsManager.whiteGray,
            ),
          ),
        ],
      ),
    );
  }
}
