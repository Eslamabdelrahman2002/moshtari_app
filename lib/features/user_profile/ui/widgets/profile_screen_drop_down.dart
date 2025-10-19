import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/enums/gender.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class ProfileScreenDropDown extends StatefulWidget {
  final String title;
  const ProfileScreenDropDown({super.key, required this.title});

  @override
  State<ProfileScreenDropDown> createState() => _ProfileScreenDropDownState();
}

class _ProfileScreenDropDownState extends State<ProfileScreenDropDown> {
  bool isExpaned = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpaned = !isExpaned;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
            height: 42.h,
            decoration: BoxDecoration(
              color: ColorsManager.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(width: 1, color: ColorsManager.dark200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50.w,
                  child: Center(
                    child: Text(
                      widget.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: TextStyles.fontSize(12),
                        color: ColorsManager.secondary900,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                horizontalSpace(4),
                MySvg(image: 'arrow-down', width: 12.w, height: 12.w),
              ],
            ),
          ),
        ),
        if (isExpaned) verticalSpace(2),
        if (isExpaned)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
            decoration: BoxDecoration(
              color: ColorsManager.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: ColorsManager.black.withOpacity(0.03),
                  blurRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
              shape: BoxShape.rectangle,
              border: Border.all(color: ColorsManager.dark200, width: 1),
            ),
            child: Column(
              children: [
                ProfileScreenDropDownItem(
                  title: Gender.male.value,
                  onTap: () {
                    setState(() {
                      isExpaned = false;
                    });
                  },
                ),
                verticalSpace(8),
                ProfileScreenDropDownItem(
                  title: Gender.female.value,
                  onTap: () {
                    setState(() {
                      isExpaned = false;
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ProfileScreenDropDownItem extends StatelessWidget {
  final String title;
  final Function() onTap;
  const ProfileScreenDropDownItem({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [Text(title, style: TextStyles.font12Black400Weight)],
      ),
    );
  }
}
