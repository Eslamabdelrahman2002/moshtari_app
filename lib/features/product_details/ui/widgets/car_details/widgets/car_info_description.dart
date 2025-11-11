// lib/features/car_details/ui/widgets/car_info_description.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/features/product_details/ui/widgets/show_more.dart';

class CarInfoDescription extends StatefulWidget {
  final String description;
  const CarInfoDescription({super.key, required this.description});

  @override
  State<CarInfoDescription> createState() => _CarInfoDescriptionState();
}

class _CarInfoDescriptionState extends State<CarInfoDescription> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Align(
              alignment: Alignment.centerRight,
              child: Text("الوصف", style: TextStyles.font16Dark300Grey400Weight)),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Text(widget.description,
                style: TextStyles.font14Black500Weight,
                overflow: TextOverflow.ellipsis,
                maxLines: 10),
          ),
        ),
      ],
    );
  }
}