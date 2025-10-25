import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/router/routes.dart';

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

import 'package:mushtary/features/user_profile/data/model/user_profile_model.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_state.dart';
import 'package:mushtary/features/user_profile/ui/widgets/ads_auctions_toggle.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
              title: Text('الملف الشخصي', style: TextStyles.font20Black500Weight),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                if (state is ProfileSuccess)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: ColorsManager.black),
                    color: Colors.white,
                    onSelected: (value) {
                      final cubit = context.read<ProfileCubit>();
                      switch (value) {
                        case 'تعديل الحساب':
                          context.pushNamed(Routes.updateProfileScreen, arguments: cubit)
                              .then((_) => cubit.loadProfile());
                          break;
                        case 'مشاركة الملف':
                          final user = cubit.user;
                          if (user != null) {
                            _showShareProfileDialog(context, user);
                          }
                          break;
                        case 'توثيق الحساب':
                          _showVerifyAccountSheet(context);
                          break;
                        case 'حذف الحساب':
                          _confirmDeleteAccount(context);
                          break;
                        case 'مدير الحساب':
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'تعديل الحساب',
                        child: Row(
                          children: [
                            MySvg(image: "edit", color: ColorsManager.darkGray600, height: 20),
                            const SizedBox(width: 8),
                            Text('تعديل الحساب', style: TextStyle(color: ColorsManager.darkGray600)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'مشاركة الملف',
                        child: Row(
                          children: [
                            MySvg(image: "send-1", color: ColorsManager.darkGray600, height: 20),
                            const SizedBox(width: 8),
                            Text('مشاركة الملف', style: TextStyle(color: ColorsManager.darkGray600)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'توثيق الحساب',
                        child: Row(
                          children: [
                            MySvg(image: "verified", color: ColorsManager.darkGray600, height: 20),
                            const SizedBox(width: 8),
                            Text('توثيق الحساب', style: TextStyle(color: ColorsManager.darkGray600)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'حذف الحساب',
                        child: Row(
                          children: [
                            MySvg(image: "close-square", color: ColorsManager.darkGray600, height: 20),
                            const SizedBox(width: 8),
                            Text('حذف الحساب', style: TextStyle(color: ColorsManager.darkGray600)),
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
      return _ProfileSkeleton();
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
        ],
      ),
    );
  }

  // ================= Skeletons =================

  // صفحة سكيليتون لملف المستخدم
  Widget _ProfileSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          // Header card skeleton
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(16),
            height: 140.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14.h, width: 140.w, color: Colors.white),
                      SizedBox(height: 8.h),
                      Container(height: 12.h, width: 90.w, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // List skeleton
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemBuilder: (_, __) => Container(
                height: 90.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemCount: 6,
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  // ================= Share dialog =================

  String _buildProfileShareLink(UserProfileModel user) {
    final ref = (user.referralCode ?? '').toString().trim();
    final base = 'https://mushtary.app/user';
    return ref.isEmpty ? '$base/${user.userId}' : '$base/${user.userId}?ref=$ref';
  }

  void _showShareProfileDialog(BuildContext context, UserProfileModel user) {
    final link = _buildProfileShareLink(user);
    final text = 'تعال شوف ملفي في مشتري:\n$link';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('مشاركة للملف الشخصي', style: TextStyles.font18Black500Weight, textAlign: TextAlign.center),
              verticalSpace(6),
              Text('بواسطة', style: TextStyles.font14Dark400400Weight, textAlign: TextAlign.center),
              verticalSpace(18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ShareCircle(
                    child: MySvg(image: 'logos_whatsapp-icon'),
                    onTap: () => _shareToWhatsApp(text),
                  ),
                  _ShareCircle(
                    child: MySvg(image: 'logos_telegram'),
                    onTap: () => _shareToTelegram(text, link),
                  ),
                  _ShareCircle(
                    child: MySvg(image: 'logos_facebook'),
                    onTap: () => _shareToFacebook(link, quote: 'تعال شوف ملفي في مشتري'),
                  ),
                  _ShareCircle(
                    child: MySvg(image: 'link'),
                    onTap: () => _copyToClipboard(context, link),
                  ),
                ],
              ),
              verticalSpace(24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                  child: Text('حسناً', style: TextStyles.font16White500Weight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return const _DeletingAccountLoadingDialog();
      },
    );
  }

  Future<void> _shareToWhatsApp(String text) async {
    final deep = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    final web = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    if (!await launchUrl(deep, mode: LaunchMode.externalApplication)) {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareToTelegram(String text, String link) async {
    final deep = Uri.parse('tg://msg?text=${Uri.encodeComponent(text)}');
    final web = Uri.parse('https://t.me/share/url?url=${Uri.encodeComponent(link)}&text=${Uri.encodeComponent(text)}');
    if (!await launchUrl(deep, mode: LaunchMode.externalApplication)) {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareToFacebook(String link, {String? quote}) async {
    final deep = Uri.parse('fb://facewebmodal/f?href=${Uri.encodeComponent(link)}');
    final web = Uri.parse(
      'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(link)}'
          '${quote == null ? '' : '&quote=${Uri.encodeComponent(quote)}'}',
    );
    if (!await launchUrl(deep, mode: LaunchMode.externalApplication)) {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ رابط الملف')));
    }
  }

  void _showVerifyAccountSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final idCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                      Text('توثيق الحساب', style: TextStyles.font18Black500Weight),
                      const SizedBox(width: 48),
                    ],
                  ),
                  verticalSpace(8),
                  Text(
                    'قم بإدخال رقم الهوية الخاص بك لكي تتمكن من توثيق الحساب',
                    style: TextStyles.font14Dark400400Weight,
                    textAlign: TextAlign.center,
                  ),
                  verticalSpace(16),
                  TextFormField(
                    controller: idCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(14),
                    ],
                    decoration: InputDecoration(
                      hintText: 'رقم الهوية',
                      filled: true,
                      fillColor: const Color(0xFFF7F7F7),
                      prefixIcon: const Icon(Icons.badge_outlined),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste),
                        onPressed: () async {
                          final data = await Clipboard.getData(Clipboard.kTextPlain);
                          if (data?.text != null) {
                            idCtrl.text = data!.text!.replaceAll(RegExp(r'\D'), '');
                          }
                        },
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE6ECFA)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE6ECFA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: ColorsManager.primary400),
                      ),
                    ),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'أدخل رقم الهوية';
                      if (s.length < 10) return 'رقم الهوية غير صحيح';
                      return null;
                    },
                  ),
                  verticalSpace(16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم إرسال طلب التوثيق')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: Size(double.infinity, 48.h),
                      ),
                      child: Text('تفعيل', style: TextStyles.font16White500Weight),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShareCircle extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _ShareCircle({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Center(child: child),
      ),
    );
  }
}

// Dialog تحميل لحذف الحساب كسكيليتون
class _DeletingAccountLoadingDialog extends StatelessWidget {
  const _DeletingAccountLoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Skeletonizer(
        enabled: true,
        child: Container(
          width: 140.w,
          height: 120.h,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 36.w, height: 36.w, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
              SizedBox(height: 12.h),
              Container(height: 12.h, width: 100.w, color: Colors.white),
              SizedBox(height: 6.h),
              Container(height: 12.h, width: 80.w, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}