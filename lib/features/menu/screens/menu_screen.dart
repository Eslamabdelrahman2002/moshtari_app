import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/sliver_app_bar_delegate.dart';

// Models/Widgets
import 'package:mushtary/features/menu/data/menu_screen_args.dart';
import 'package:mushtary/features/menu/widgets/menu_app_bar.dart';
import 'package:mushtary/features/menu/widgets/menu_item.dart';
import 'package:mushtary/features/menu/widgets/profile_box.dart';
import 'package:mushtary/features/menu/widgets/register_box.dart';

// Cubits
import 'package:mushtary/features/register_service/logic/cubit/service_registration_cubit.dart';
import 'package:mushtary/features/user_profile/logic/cubit/profile_cubit.dart';

// Register service flows
import '../../register_service/dyna/ui/screens/CompleteProfileScreenSteps.dart';
import '../../register_service/flatbed/ui/screens/delivery_service_steps.dart';
import '../../register_service/labour/ui/screens/complete_profile_screen_steps.dart';
import '../../register_service/register_service_dialog.dart';
import '../../register_service/tanker/ui/screens/tanker_service_steps.dart';

class MenuScreen extends StatefulWidget {
  final MenuScreenArgs menuScreenArgs;

  const MenuScreen({
    super.key,
    required this.menuScreenArgs,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ScrollController scrollController = ScrollController();
  late final ProfileCubit _profileCubit;

  // تبديل واجهة "مقدّم خدمة"
  bool _isServiceMode = false;

  @override
  void initState() {
    super.initState();
    _profileCubit = getIt<ProfileCubit>()..loadProfile();
  }

  @override
  void dispose() {
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              floating: true,
              delegate: SliverAppBarDelegate(
                maxHeight: 70.h,
                minHeight: 70.h,
                child: const MenuScreenAppBar(),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                verticalSpace(24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // صندوق البروفايل / التسجيل
                      widget.menuScreenArgs.isAuthenticated
                          ? ProfileBox(profileCubit: _profileCubit)
                          : const RegisterBox(),
                      verticalSpace(16),

                      // الأقسام تبعاً للوضع المختار
                      ...(_isServiceMode
                          ? _buildProviderSections(context)
                          : _buildDefaultSections(context)),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // عنصر "الملف الشخصي" مع السويتش كـ trailing
  Widget _profileMenuItem(BuildContext context) {
    return MenuItem(
      icon: 'profile',
      title: 'الملف الشخصي',
      onTap: () {
        if (_isServiceMode) {
          // لو وضع مقدّم خدمة مفعّل، افتح لوحة مقدم الخدمة
          final providerId = _profileCubit.providerId ?? 0;
          if (providerId <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('يرجى اعتمادك كمقدم خدمة أولاً')),
            );
            return;
          }
          Navigator.of(context).pushNamed(
            Routes.serviceProviderDashboard,
            arguments: providerId,
          );
        } else {
          // البروفيـل العادي
          widget.menuScreenArgs.isAuthenticated
              ? widget.menuScreenArgs.onProfileTap()
              : widget.menuScreenArgs.onLoginTap();
        }
      },
      isHasTrailing: true,
      trailing: _buildServiceSwitchTrailing(),
    );
  }

  // سويتش وضع مقدّم خدمة كـ trailing بجانب "الملف الشخصي"
  Widget _buildServiceSwitchTrailing() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: ColorsManager.secondary50,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'شاشة تقديم الخدمات',
            style: TextStyles.font14Black500Weight.copyWith(color: ColorsManager.dark500),
          ),
          horizontalSpace(8),
          Transform.scale(
            scale: 0.9,
            child: CupertinoSwitch(
              value: _isServiceMode,
              inactiveTrackColor: ColorsManager.lightGrey,
              activeColor: ColorsManager.secondary500,
              thumbColor: Colors.black.withOpacity(0.15),
              onChanged: (v) => setState(() => _isServiceMode = v),
            ),
          ),
        ],
      ),
    );
  }

  // الواجهة الافتراضية
  List<Widget> _buildDefaultSections(BuildContext context) {
    return [
      Text('بيانات اساسية', style: TextStyles.font20Black500Weight),
      verticalSpace(20),

      _profileMenuItem(context),
      verticalSpace(16),


// جديد: العروض المستلمة
      MenuItem(
        icon: 'document-cloud',
        title: 'العروض المستلمة',
        onTap: () => Navigator.of(context).pushNamed(Routes.myReceivedOffersScreen),
      ),
      verticalSpace(16),
      MenuItem(
        icon: 'wallet',
        title: 'المحفظة',
        onTap: () => Navigator.of(context).pushNamed(Routes.walletScreen),
      ),
      verticalSpace(16),

      MenuItem(
        icon: 'chart',
        title: 'أرباحي',
        onTap: () => Navigator.of(context).pushNamed(Routes.earningsScreen),
      ),
      verticalSpace(16),

      Divider(color: ColorsManager.dark100, thickness: 1.h),
      verticalSpace(16),

      Text('انشطتي', style: TextStyles.font20Black500Weight),
      verticalSpace(20),

      MenuItem(
        icon: 'discount',
        title: 'حاسبة العمولة',
        onTap: () => Navigator.of(context).pushNamed(Routes.commissionCalculatorScreen),
      ),
      verticalSpace(16),

      MenuItem(icon: 'add_gray', title: 'إضافة أعلان', onTap: () => _soon(context)),
      verticalSpace(16),

      MenuItem(icon: 'personal_card', title: 'اعلاناتي', onTap: () => _soon(context)),
      verticalSpace(16),

      MenuItem(icon: 'judge_gray', title: 'مزاداتي ومزايداتي', onTap: () => _soon(context)),
      verticalSpace(16),

      MenuItem(
        icon: 'favorites_gray',
        title: 'قائمة المتابعة والمفضلة',
        onTap: () => Navigator.of(context).pushNamed(Routes.favoritesScreen),
      ),
      verticalSpace(16),

      MenuItem(
        icon: 'sheild',
        title: 'التسجيل كمقدم خدمة',
        onTap: () => _openRegisterServiceDialog(context),
      ),
      verticalSpace(16),

      MenuItem(
        icon: 'work',
        title: 'أعمل معنا',
        onTap: () => Navigator.of(context).pushNamed(Routes.workWithUsIntroScreen),
      ),
      verticalSpace(20),

      Divider(color: ColorsManager.dark100, thickness: 1.h),
      verticalSpace(20),

      Text('اعدادات', style: TextStyles.font20Black500Weight),
      verticalSpace(20),

      MenuItem(
        icon: 'languages',
        title: 'اللغات',
        onTap: () => Navigator.of(context).pushNamed(Routes.languagesScreen),
      ),
      verticalSpace(16),

      MenuItem(icon: 'moon', title: 'الثيم', onTap: () => _soon(context)),
      verticalSpace(16),

      MenuItem(
        icon: 'notifications_gray',
        title: 'الاشعارات',
        onTap: () => Navigator.of(context).pushNamed(Routes.notificationsScreen),
      ),
      verticalSpace(16),

      MenuItem(icon: 'settings_gray', title: 'اعدادت اضافية', onTap: () => _soon(context)),
      verticalSpace(20),

      Divider(color: ColorsManager.dark100, thickness: 1.h),
      verticalSpace(20),

      Text('اخرى', style: TextStyles.font20Black500Weight),
      verticalSpace(20),

      MenuItem(
        icon: 'help_center',
        title: 'الدعم الفني',
        onTap: () => context.pushNamed(Routes.technicalSupportScreen),
      ),
      verticalSpace(16),

      MenuItem(icon: 'info_gray', title: 'سياسات الاستخدام', onTap: () => _soon(context)),
      verticalSpace(16),

      MenuItem(icon: 'about_gray', title: 'عن التطبيق', onTap: () => _soon(context)),
      verticalSpace(16),

      MenuItem(
        icon: 'close-square',
        title: 'تسجيل الخروج',
        onTap: widget.menuScreenArgs.onLogout,
      ),
    ];
  }

  // واجهة "مقدّم خدمة"
  List<Widget> _buildProviderSections(BuildContext context) {
    return [
      Text('بيانات اساسية', style: TextStyles.font20Black500Weight),
      verticalSpace(20),

      _profileMenuItem(context),
      verticalSpace(16),

      // إدارة رحلاتي
      MenuItem(icon: 'chart', title: 'إدارة رحلاتي',
          onTap: () => Navigator.pushNamed(context, Routes.dynaTripsManagerScreen)),
      verticalSpace(16),

      // إنشاء رحلة
      MenuItem(
        icon: 'add_gray',
        title: 'إنشاء رحلة',
        onTap: () {
          final providerId = _profileCubit.providerId ?? 0;
          if (providerId <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('يرجى إكمال/قبول التسجيل كمقدم خدمة أولاً')),
            );
            return;
          }
          Navigator.of(context).pushNamed(Routes.createDynaTripScreen, arguments: providerId);
        },
      ),
      verticalSpace(16),

      // الخطة
      MenuItem(icon: 'chart', title: 'الخطة', onTap: () => _soon(context)),
      verticalSpace(16),

      // أرباحي
      MenuItem(
        icon: 'chart',
        title: 'أرباحي',
        onTap: () => Navigator.of(context).pushNamed(Routes.earningsScreen),
      ),
      verticalSpace(16),

      Divider(color: ColorsManager.dark100, thickness: 1.h),
      verticalSpace(16),

      Text('انشطتي', style: TextStyles.font20Black500Weight),
      verticalSpace(20),

      MenuItem(
        icon: 'discount',
        title: 'حاسبة العمولة',
        onTap: () => Navigator.of(context).pushNamed(Routes.commissionCalculatorScreen),
      ),
      verticalSpace(16),

      MenuItem(icon: 'sheild', title: 'توثيق الحساب', onTap: () => _soon(context)),
      verticalSpace(16),

      MenuItem(icon: 'judge_gray', title: 'مزاداتي ومزايداتي', onTap: () => _soon(context)),
      verticalSpace(16),

      MenuItem(
        icon: 'favorites_gray',
        title: 'قائمة المتابعة والمفضلة',
        onTap: () => Navigator.of(context).pushNamed(Routes.favoritesScreen),
      ),
      verticalSpace(16),

      MenuItem(
        icon: 'sheild',
        title: 'التسجيل كمقدم خدمة',
        onTap: () => _openRegisterServiceDialog(context),
      ),
      verticalSpace(16),

      MenuItem(
        icon: 'work',
        title: 'أعمل معنا',
        onTap: () => Navigator.of(context).pushNamed(Routes.workWithUsIntroScreen),
      ),
      verticalSpace(20),

      Divider(color: ColorsManager.dark100, thickness: 1.h),
      verticalSpace(20),

      Text('اعدادات', style: TextStyles.font20Black500Weight),
      verticalSpace(20),

      MenuItem(
        icon: 'languages',
        title: 'اللغات',
        onTap: () => Navigator.of(context).pushNamed(Routes.languagesScreen),
      ),
      verticalSpace(16),

      MenuItem(icon: 'moon', title: 'الثيم', onTap: () => _soon(context)),
      verticalSpace(16),

      MenuItem(
        icon: 'notifications_gray',
        title: 'الاشعارات',
        onTap: () => Navigator.of(context).pushNamed(Routes.notificationsScreen),
      ),
      verticalSpace(16),

      Divider(color: ColorsManager.dark100, thickness: 1.h),
      verticalSpace(20),

      Text('اخرى', style: TextStyles.font20Black500Weight),
      verticalSpace(20),

      MenuItem(
        icon: 'help_center',
        title: 'الدعم الفني',
        onTap: () => context.pushNamed(Routes.technicalSupportScreen),
      ),
      verticalSpace(16),

      MenuItem(icon: 'info_gray', title: 'سياسات الاستخدام', onTap: () => _soon(context)),
      verticalSpace(16),

      MenuItem(icon: 'about_gray', title: 'عن التطبيق', onTap: () => _soon(context)),
      verticalSpace(16),

      MenuItem(
        icon: 'close-square',
        title: 'تسجيل الخروج',
        onTap: widget.menuScreenArgs.onLogout,
      ),
    ];
  }

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم توفيرها قريباً')),
    );
  }

  Future<void> _openRegisterServiceDialog(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: const RegisterServiceDialog(),
      ),
    );

    if (result == null || result['routeName'] == null || result['serviceType'] == null) return;

    final routeName = result['routeName']!;
    final serviceType = result['serviceType']!;

    // نقرأ الكيوبت من الشجرة إن وجد، وإلا من getIt
    ServiceRegistrationCubit cubit;
    bool hasProvider = true;
    try {
      cubit = context.read<ServiceRegistrationCubit>();
    } catch (_) {
      cubit = getIt<ServiceRegistrationCubit>();
      hasProvider = false;
    }

    cubit.initialize(serviceType);

    if (hasProvider) {
      Navigator.of(context).pushNamed(routeName);
      return;
    }

    // تمرير نفس الكيوبت للشاشة المختارة
    Widget screen;
    switch (routeName) {
      case Routes.completeProfileSteps:
        screen = const CompleteProfileScreenSteps();
        break;
      case Routes.deliveryServiceSteps:
        screen = const DeliveryServiceSteps();
        break;
      case Routes.transportServiceSteps:
        screen = const TransportServiceProviderSteps();
        break;
      case Routes.tankerServiceSteps:
        screen = const TankerServiceSteps();
        break;
      default:
        screen = const CompleteProfileScreenSteps();
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(value: cubit, child: screen),
      ),
    );
  }
}