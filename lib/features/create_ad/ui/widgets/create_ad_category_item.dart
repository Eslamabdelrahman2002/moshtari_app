import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class CreateAdCategoryItem extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback? onTap;
  const CreateAdCategoryItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: TextStyles.font16DarkGrey400Weight),
      leading: MySvg(image: icon, width: 32.w, height: 32.w),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
      onTap: onTap,
    );
  }
}