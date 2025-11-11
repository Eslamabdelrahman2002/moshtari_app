import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

/// نتيجة الـBottomSheet:
/// - serviceIndex: يحدد أي تبويب داخل ServiceScreen
/// - openDinatApplication: افتح شاشة الطلب المباشر للدينات
class ServiceSheetResult {
  final int? serviceIndex;
  final bool openDinatApplication;
  const ServiceSheetResult.service(this.serviceIndex) : openDinatApplication = false;
  const ServiceSheetResult.directApp()
      : serviceIndex = null,
        openDinatApplication = true;
}

enum ServiceType { worker, satha, dinat, tanker }
enum DinatFlow { directRequest, joinTrip }

class ServiceBottomSheetContent extends StatelessWidget {
  const ServiceBottomSheetContent({super.key});

  int _mapIndex(ServiceType type) {
    switch (type) {
      case ServiceType.worker:
        return 0;
      case ServiceType.dinat:
        return 1;
      case ServiceType.satha:
        return 2;
      case ServiceType.tanker:
        return 3;
    }
  }

  // دينات: اعرض الديالوج ثم ارجع بنتيجة إلى الـBottomNav
  Future<void> _onDinatTap(BuildContext context) async {
    final flow = await _showDinatTypeDialog(context);
    if (flow == null) return;

    if (flow == DinatFlow.joinTrip) {
      Navigator.of(context).pop(const ServiceSheetResult.service(1)); // DinatScreen داخل ServiceScreen
    } else {
      Navigator.of(context).pop(const ServiceSheetResult.directApp()); // افتح شاشة الطلب المباشر
    }
  }

  Future<DinatFlow?> _showDinatTypeDialog(BuildContext context) {
    DinatFlow? selected = DinatFlow.joinTrip;

    Widget choice({
      required String title,
      required String iconName,
      required DinatFlow value,
      required VoidCallback onTap,
      required bool isSelected,
    }) {
      return SizedBox.expand( // يملأ مساحة Expanded + SizedBox(height)
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: ColorsManager.lightGrey,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? ColorsManager.primaryColor : ColorsManager.grey200,
                width: isSelected ? 1.6 : 1.0,
              ),
            ),
            child: Stack(
              children: [
                // زر اختيار دائري أعلى يمين
                PositionedDirectional(
                  top: 0.h,
                  end: 0.w,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? ColorsManager.primaryColor : ColorsManager.white,
                        width: 2,
                      ),
                      color: isSelected ? ColorsManager.primaryColor.withOpacity(0.1) : Colors.transparent,
                    ),
                    child: Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? ColorsManager.primaryColor : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),

                // محتوى الكارت
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MySvg(image: iconName, width: 40.w, height: 40.w),
                      verticalSpace(10),
                      Text(
                        title,
                        style: TextStyles.font16Black500Weight,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return showDialog<DinatFlow>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: StatefulBuilder(
            builder: (ctx, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ترويسة
                Row(
                  children: [
                    InkWell(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: MySvg(image: 'close_circle')),
                    Expanded(child: Center(child: Text('اختر نوع خدمة الدينا', style: TextStyles.font16Black500Weight))),
                    SizedBox(width: 48.w),
                  ],
                ),
                Divider(color: ColorsManager.grey200, height: 16.h),

                // صف الخيارات — ارتفاع ثابت يضمن توحيد حجم الكروت
                SizedBox(
                  height: 132.h, // عدّلها 120–148 حسب ذوقك
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: choice(
                          title: 'طلب مباشر',
                          iconName: 'quetion', // تأكد من اسم الأيقونة الصحيح
                          value: DinatFlow.directRequest,
                          isSelected: selected == DinatFlow.directRequest,
                          onTap: () => setState(() => selected = DinatFlow.directRequest),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: choice(
                          title: 'الإِنضمام إلى رحلة جارية',
                          iconName: 'tanker',
                          value: DinatFlow.joinTrip,
                          isSelected: selected == DinatFlow.joinTrip,
                          onTap: () => setState(() => selected = DinatFlow.joinTrip),
                        ),
                      ),
                    ],
                  ),
                ),

                verticalSpace(16),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsManager.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                    child: Text('بدء الخدمة', style: TextStyles.font16White500Weight),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile({
    required BuildContext context,
    required String title,
    required String iconName,
    required ServiceType type,
    VoidCallback? onTapOverride,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTapOverride ??
              () {
            final idx = _mapIndex(type);
            Navigator.of(context).pop(ServiceSheetResult.service(idx));
          },
      child: Container(
        decoration: BoxDecoration(
          color: ColorsManager.lightGrey,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: LayoutBuilder(
          builder: (ctx, c) {
            final iconSize = c.maxHeight * 0.66;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MySvg(image: iconName, width: iconSize, height: iconSize),
                verticalSpace(10),
                Text(title, style: TextStyles.font16Black500Weight.copyWith(
                  color: ColorsManager.darkGray600
                ), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(right: 16.w, left: 16.w),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [Text('الخدمات', style: TextStyles.font20Black500Weight)],
            ),
            verticalSpace(12),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.15,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              children: [
                _tile(
                  context: context,
                  title: 'دينات',
                  iconName: 'dinah',
                  type: ServiceType.dinat,
                  onTapOverride: () => _onDinatTap(context), // يعرض الديالوج
                ),
                _tile(context: context, title: 'أجير', iconName: 'employee', type: ServiceType.worker),
                _tile(context: context, title: 'صهريج ماء', iconName: 'waterTank', type: ServiceType.tanker),
                _tile(context: context, title: 'سطحة', iconName:'flatbed', type: ServiceType.satha),
              ],
            ),
          ],
        ),
      ),
    );
  }
}