import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_item_datails.dart';
import 'package:timeago/timeago.dart' as timeago;

class RealEstateApplicationsDetailsPanel extends StatelessWidget {
  final String title;
  final DateTime time;
  final String location;
  const RealEstateApplicationsDetailsPanel(
      {super.key,
      required this.title,
      required this.time,
      required this.location});

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Text(
            title,
            style: TextStyles.font20Black500Weight,
          ),
        ),
        verticalSpace(8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MySvg(
                            image: 'location-yellow',
                            width: 20.w,
                            height: 20.w),
                        horizontalSpace(2),
                        Text(
                          location,
                          style: TextStyles.font16Black500Weight,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                    const Spacer(),
                    RealEstateItemDatails(
                      text: timeago.format(time, locale: 'ar'),
                      image: 'clock-yellow',
                      width: 20.w,
                      height: 20.h,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        verticalSpace(12),
      ],
    );
  }
}
