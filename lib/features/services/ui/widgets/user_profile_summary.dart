import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class UserProfileSummary extends StatelessWidget {
  final String name; // من provider.fullName
  final String serviceType; // من provider.serviceType
  final String cityName; // من provider.cityName
  final String nationality; // من provider (إذا موجود، أو static)
  final String worksCount; // مثال: '15 عمل' – يمكن جعله ديناميكي إذا كان في model

  const UserProfileSummary({
    super.key,
    required this.name,
    required this.serviceType,
    required this.cityName,
    required this.nationality,
    this.worksCount = '0 عمل', // default إذا مش متوفر
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            name, // ديناميكي
            style: TextStyles.font20Black500Weight,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        verticalSpace(16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MySvg(
                            image: 'element-equal-secondary',
                            width: 20.w,
                            height: 20.w),
                        horizontalSpace(4),
                        Text(serviceType, style: TextStyles.font14Black500Weight), // ديناميكي
                      ],
                    ),
                    verticalSpace(8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MySvg(
                            image: 'location-secondary',
                            width: 20.w,
                            height: 20.w),
                        horizontalSpace(4),
                        Text(cityName, style: TextStyles.font14Black500Weight), // ديناميكي
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MySvg(
                            image: 'clock-secondary',
                            width: 20.w,
                            height: 20.w),
                        horizontalSpace(4),
                        Text(worksCount, style: TextStyles.font14Black400Weight), // ديناميكي
                      ],
                    ),
                    verticalSpace(8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MySvg(
                            image: 'user-secondary', width: 20.w, height: 20.w),
                        horizontalSpace(4),
                        Text(nationality, style: TextStyles.font14Black400Weight), // ديناميكي
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}