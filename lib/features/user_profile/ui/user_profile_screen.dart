import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/user_profile/data/model/user_profile_model.dart';
import 'package:mushtary/features/user_profile/data/model/my_ads_model.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_state.dart';
import 'package:mushtary/features/user_profile/ui/widgets/ads_auctions_toggle.dart';
import 'package:mushtary/features/user_profile/ui/widgets/product_item.dart';
import '../../../core/dependency_injection/injection_container.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = getIt<ProfileCubit>();
    _profileCubit.loadProfile();
  }

  @override
  void dispose() {
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileCubit,
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('الملف الشخصي'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                if (state is ProfileSuccess)
                  PopupMenuButton<String>(
                    icon:  Icon(Icons.more_vert, color: ColorsManager.black), // أيقونة النقاط الثلاث
                    color: Colors.white, // خلفية القائمة
                    onSelected: (value) {
                      final _profileCubit = context.read<ProfileCubit>();
                      switch (value) {
                        case 'تعديل الحساب':
                          context.pushNamed(Routes.updateProfileScreen, arguments: _profileCubit)
                              .then((_) => _profileCubit.loadProfile());
                          break;
                        case 'مشاركة الملف':
                        // ضع هنا كود المشاركة
                          break;
                        case 'حذف الحساب':
                        // ضع هنا كود حذف الحساب
                          break;
                        case 'مدير الحساب':
                        // ضع هنا كود مدير الحساب
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'تعديل الحساب',
                        child: Row(
                          children:  [
                            MySvg(image: "edit",color: ColorsManager.darkGray600,height: 20),
                            SizedBox(width: 8),
                            Text('تعديل الحساب', style: TextStyle(color: ColorsManager.darkGray600)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'مشاركة الملف',
                        child: Row(
                          children:  [
                            MySvg(image: "send-1",color: ColorsManager.darkGray600,height: 20),
                            SizedBox(width: 8),
                            Text('مشاركة الملف', style: TextStyle(color: ColorsManager.darkGray600)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'توثيق الحساب',
                        child: Row(
                          children:  [
                            MySvg(image: "verified",color: ColorsManager.darkGray600,height: 20),
                            SizedBox(width: 8),
                            Text('توثيق الحساب', style: TextStyle(color: ColorsManager.darkGray600)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'حذف مدير الحساب',
                        child: Row(
                          children:  [
                            MySvg(image: "close-square",color: ColorsManager.darkGray600,height: 20,),
                            SizedBox(width: 8),
                            Text('حذف مدير الحساب', style: TextStyle(color: ColorsManager.darkGray600)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            body: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state is ProfileLoading || state is ProfileInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProfileFailure) {
      return Center(child: Text(state.error));
    }

    if (state is ProfileSuccess) {
      final user = state.user;
      final myAds = state.myAds;
      final myAuctions = state.myAuctions;

      return Column(
        children: [
          _buildProfileCard(user),
          _buildTopButtons(),
          verticalSpace(16),
          Expanded(
            child: AdsAuctionsToggle(
              myAds: myAds,
              myAuctions: myAuctions,
            ),
          ),
          verticalSpace(12),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProfileCard(UserProfileModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/cover.jpg'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32.w,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 30.w,
              backgroundImage: user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(user.profilePictureUrl!)
                  : const AssetImage('assets/images/prof.png') as ImageProvider,
            ),
          ),
          verticalSpace(4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.username ?? 'No Name',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              horizontalSpace(6),
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
          // const Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text('اتابعهم 120', style: TextStyle(color: Colors.white)),
          //     SizedBox(width: 16),
          //     SizedBox(height: 16, width: 1, child: VerticalDivider(color: Colors.white70)),
          //     SizedBox(width: 16),
          //     Text('يتابعوني 80', style: TextStyle(color: Colors.white)),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildTopButtons() {
    final buttons = [
      {'icon': 'heart', 'label': 'قائمة المفضلة'},
      {'icon': 'task-square', 'label': 'قائمة المتابعة'},
      {'icon': 'document-cloud', 'label': 'مرفقاتي'},
      {'icon': 'element-equals', 'label': 'إعدادات الخدمات'},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: buttons.map((btn) {
          return Container(
            width: 80.w,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsManager.primary50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                MySvg(
                  image: btn['icon'] as String,
                  color: ColorsManager.primary400,
                  width: 20.w,
                  height: 20.h,
                ),
                const SizedBox(height: 4),
                Text(
                  '${btn['label']}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyles.font10Primary400400Weight,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

