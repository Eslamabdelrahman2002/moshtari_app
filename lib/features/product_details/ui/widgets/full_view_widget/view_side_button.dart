// features/product_details/ui/widgets/full_view_widget/view_side_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class ViewSideButton extends StatelessWidget {
  final VoidCallback onTap;
  final String image;
  // <--- إضافة خاصية اللون لتغيير لون الأيقونة
  final Color? iconColor;

  const ViewSideButton({
    super.key,
    required this.onTap,
    required this.image,
    this.iconColor, // <--- إضافة اللون إلى البناء
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: onTap,
      child: MySvg(
        image: image,
        width: 32.w,
        height: 32.h,
        // <--- تمرير اللون إلى MySvg
        color: iconColor,
      ),
    );
  }
}