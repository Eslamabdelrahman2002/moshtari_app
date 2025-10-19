import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

import '../../../core/widgets/safe_cached_image.dart';
import '../../user_profile/logic/cubit/profile_cubit.dart';
import '../../user_profile/logic/cubit/profile_state.dart';


class ProfileBox extends StatelessWidget {
  final ProfileCubit profileCubit;

  const ProfileBox({super.key, required this.profileCubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      bloc: profileCubit,
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProfileFailure) {
          return Center(child: Text(state.error));
        }

        if (state is ProfileSuccess) {
          final user = state.user;

          return InkWell(
            onTap: () {
              debugPrint("ProfileBox tapped");
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    offset: Offset(0, 2.h),
                    blurRadius: 16.r,
                  ),
                ],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  // 👇 آمن على الروابط الفاضية/غير الصالحة
                  SafeCircleAvatar(
                    url: user.profilePictureUrl,
                    radius: 20.w,
                    bg: ColorsManager.secondary50,
                  ),
                  horizontalSpace(8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(user.username ?? 'مستخدم', style: TextStyles.font14Black500Weight),
                          horizontalSpace(4),
                          if (user.isVerified ?? false)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: ColorsManager.lightTeal,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: const [
                                  Text('موثق', style: TextStyle(fontSize: 12, color: ColorsManager.teal)),
                                  SizedBox(width: 4),
                                  MySvg(image: 'verified'),
                                ],
                              ),
                            ),
                        ],
                      ),
                      verticalSpace(8),
                    ],
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: ColorsManager.dark50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Text('رابط الاحالة:', style: TextStyles.font10Dark400Grey400Weight),
                          Text(user.referral_code ?? '', style: TextStyles.font10Dark400Grey400Weight.copyWith(color: ColorsManager.black)),
                          horizontalSpace(4),
                          const MySvg(image: 'copy_icon'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
