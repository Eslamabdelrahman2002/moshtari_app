import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

import '../../../core/widgets/safe_cached_image.dart';
import '../../user_profile/logic/cubit/profile_cubit.dart';
import '../../user_profile/logic/cubit/profile_state.dart';

class ProfileBox extends StatelessWidget {
  final ProfileCubit profileCubit;
  final VoidCallback? onProfileTap; // 🔹 جديد

  const ProfileBox({
    super.key,
    required this.profileCubit,
    this.onProfileTap,
  });

  void _copyToClipboard(BuildContext context, String? text) {
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ رمز الإحالة بنجاح!',
          style: TextStyles.font14Black500Weight.copyWith(color: Colors.white),
        ),
        backgroundColor: ColorsManager.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      bloc: profileCubit,
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (state is ProfileFailure) {
          return Center(child: Text(state.error));
        }

        if (state is ProfileSuccess) {
          final user = state.user;

          return Container(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SafeCircleAvatar(
                  url: user.profilePictureUrl,
                  radius: 20.w,
                  bg: ColorsManager.secondary50,
                ),
                horizontalSpace(8),
                // الاسم + رمز الإحالة تحت الاسم
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الاسم + توثيق
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              user.username ?? 'مستخدم',
                              style: TextStyles.font14Black500Weight,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          horizontalSpace(4),
                          if (user.isVerified ?? false)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: ColorsManager.lightTeal,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('موثق', style: TextStyle(fontSize: 12, color: ColorsManager.teal)),
                                  SizedBox(width: 4),
                                  MySvg(image: 'verified'),
                                ],
                              ),
                            ),
                        ],
                      ),
                      verticalSpace(6),
                      // رمز الإحالة تحت الاسم وقابل للنسخ
                      if ((user.referralCode ?? '').isNotEmpty)
                        InkWell(
                          onTap: () => _copyToClipboard(context, user.referralCode),
                          borderRadius: BorderRadius.circular(6.r),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('رمز الإحالة: ', style: TextStyles.font10Dark400Grey400Weight),
                              Flexible(
                                child: Text(
                                  user.referralCode!,
                                  style: TextStyles.font10Dark400Grey400Weight.copyWith(color: ColorsManager.black),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              horizontalSpace(4),
                              const MySvg(image: 'copy_icon'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // سهم يروح لملف المستخدم فقط (مش مقدم الخدمة)
                InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: ColorsManager.dark500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}