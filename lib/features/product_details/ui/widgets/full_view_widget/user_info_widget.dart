import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/product_details/ui/widgets/stars_rate.dart';

class UserInfoWidget extends StatelessWidget {
  final String username;
  final String? profilePicture;

  const UserInfoWidget({
    super.key,
    required this.username,
    this.profilePicture,
  });

  bool get _isHttpUrl {
    if (profilePicture == null) return false;
    final u = profilePicture!.toLowerCase();
    return u.startsWith('http://') || u.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: ColorsManager.black.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 40.w,
              height: 40.w,
              child: _isHttpUrl
                  ? Image.network(
                profilePicture!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => MySvg(image: "profile",fit: BoxFit.cover,)
              )
                  : MySvg(image: "profile",fit: BoxFit.cover,)
            ),
          ),
          horizontalSpace(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    username,
                    style: TextStyles.font14Black500Weight.copyWith(
                      color: ColorsManager.white,
                    ),
                  ),
                  horizontalSpace(8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: ColorsManager.lightTeal,
                      borderRadius: BorderRadius.circular(80.r),
                    ),
                    child: Row(
                      children: [
                        Text('موثق', style: TextStyles.font12Green400Weight),
                        horizontalSpace(2),
                        Icon(Icons.verified, color: ColorsManager.teal, size: 12.w),
                      ],
                    ),
                  ),
                ],
              ),
              verticalSpace(4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const StarsRate(rate: 3),
                  horizontalSpace(8),
                  Text('( 5 اراء )', style: TextStyles.font10Dark400Grey400Weight),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}