import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class RealEstateCategorySelectorItem extends StatelessWidget {
  final String title;
  final String image;
  final void Function()? onTap;
  const RealEstateCategorySelectorItem({
    super.key,
    required this.title,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: MySvg(
        image: image,
        width: 24.w,
        height: 24.w,
      ),
      title: Text(title),
      trailing: const MySvg(image: 'arrow-left'),
      onTap: onTap,
    );
  }
}
