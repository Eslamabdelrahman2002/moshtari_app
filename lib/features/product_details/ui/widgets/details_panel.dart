import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

import 'package:mushtary/features/home/ui/widgets/list_view_item_data_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class DetailsPanel extends StatelessWidget {
  final String location;
  final DateTime time;
  final String price;
  const DetailsPanel({
    super.key,
    required this.location,
    required this.time,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListViewItemDataWidget(
                      text: location,
                      image: 'location-dark',
                      width: 20.w,
                      height: 20.h,
                    ),
                    verticalSpace(8),
                    ListViewItemDataWidget(
                      text: timeago.format(time, locale: 'ar'),
                      image: 'clock',
                      width: 20.w,
                      height: 20.h,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListViewItemDataWidget(
                      text: price,
                      image: 'saudi_riyal',
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
