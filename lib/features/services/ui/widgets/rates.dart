import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/services/ui/widgets/starts.dart';

class Rates extends StatelessWidget {
  final double average; // من provider.rating.average
  final double price; // من provider.rating.price
  final double professionalism; // من provider.rating.professionalism
  final double speed; // من provider.rating.speed
  final double quality; // من provider.rating.quality
  final double? behavior; // من provider.rating.behavior
  final int reviewsCount; // من provider.reviewsCount (للعرض في '(18)')

  const Rates({
    super.key,
    required this.average,
    required this.price,
    required this.professionalism,
    required this.speed,
    required this.quality,
    this.behavior,
    this.reviewsCount = 0, // default
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Text(
                'التقيمات',
                style: TextStyles.font16DarkGrey500Weight,
              ),
              horizontalSpace(8),
              Text(
                '($reviewsCount)', // ديناميكي
                style: TextStyles.font16Black500Weight,
              ),
            ],
          ),
        ),
        verticalSpace(16),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
          decoration: BoxDecoration(
            color: ColorsManager.dark50,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              RateItem(text: 'السعر', rate: price), // ديناميكي
              RateItem(text: 'سرعة الانجاز', rate: speed),
              RateItem(text: 'الاحترافية بالتعامل', rate: professionalism),
              RateItem(text: 'التعامل معه مرّة أخرى', rate: behavior ?? 0),
              RateItem(text: 'جودة العمل المسلّم', rate: quality),
            ],
          ),
        )
      ],
    );
  }
}

class RateItem extends StatelessWidget {
  final String text;
  final double rate; // غيرت من ? إلى required لأنه ديناميكي

  const RateItem({
    super.key,
    required this.text,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyles.font14Black400Weight,
        ),
        StarsRate(rate: rate), // ديناميكي
      ],
    );
  }
}