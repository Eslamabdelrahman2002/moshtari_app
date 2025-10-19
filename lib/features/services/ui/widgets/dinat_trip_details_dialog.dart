// lib/features/services/ui/widgets/dinat_trip_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';

import 'join_request_sent_dialog.dart';

class DinatTripDetails {
  final String title;
  final String fromCity;
  final String toCity;
  final String pickUpAddress;
  final String dropOffAddress;
  final String mapImage;

  DinatTripDetails({
    required this.title,
    this.fromCity = 'جدة',
    this.toCity = 'مكة',
    this.pickUpAddress = 'الرياض',
    this.dropOffAddress = 'جدة',
    this.mapImage = 'assets/images/map_image',
  });
}

class DinatTripDetailsDialog extends StatelessWidget {
  final DinatTripDetails details;

  const DinatTripDetailsDialog({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  verticalSpace(14),

                  // عنوان أعلى: تفاصيل الرحلة
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Center(
                      child: Text(
                        'تفاصيل الرحلة',
                        style: TextStyles.font18Black500Weight,
                      ),
                    ),
                  ),
                  verticalSpace(12),

                  // كارت الخريطة
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        color: Colors.grey.shade100,
                        child: Image.asset(
                          details.mapImage,
                          height: 160.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  verticalSpace(12),
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                  verticalSpace(8),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        // عنوان الطلب
                        Row(
                          children: [
                            Text(
                              details.title,
                              style: TextStyles.font18Black500Weight,
                            ),
                          ],
                        ),
                        verticalSpace(14),
                        _buildLine(iconName: 'comment', text: 'يوجد كمية كبيرة تتطلب تحميل حذر'),

                        verticalSpace(8),

                        // حالاً  |  أثاث
                        Row(
                          children: [
                            _buildDoubleSpec(
                              leftIcon: 'clock',
                              leftText: 'حالاً',
                              rightIcon: 'archive',
                              rightText: 'أثاث',
                            ),
                            horizontalSpace(16),
                            _buildDoubleSpec(
                              leftIcon: 'maximize-3',
                              leftText: 'متوسطة',
                              rightIcon: 'truck',
                              rightText: 'مقطورة',
                            ),
                          ],
                        ),




                        verticalSpace(8),

                        // العناوين التفصيلية
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.place_outlined,
                            size: 18, color: ColorsManager.primaryColor),
                            horizontalSpace(8),

                            Expanded(
                              child:
                              RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  style: TextStyles.font14Black500Weight, // النمط الافتراضي
                                  children: [
                                    TextSpan(text: 'جدة - حي الصفا'), // المدينة الأولى
                                    TextSpan(
                                      text: ' ---> ', // علامة المسار
                                      style: TextStyles.font14Black500Weight.copyWith(
                                        color: ColorsManager.primaryColor, // 💡 اللون الأساسي
                                      ),
                                    ),
                                    TextSpan(text: "مكة - حي الزاهر"), // المدينة الثانية
                                  ],
                                ),
                              ),

                            ),
                          ],
                        ),
                        verticalSpace(16),

                        // بيانات المستخدم
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16.r,
                              backgroundImage:
                              const AssetImage('assets/images/prof.png'),
                            ),
                            horizontalSpace(8),
                            Text('ناصر الغامدي', style: TextStyles.font16Black500Weight),
                          ],
                        ),

                        verticalSpace(20),

                        // شريط الإجراءات بالأسفل: أيقونات يسار + زر الانضمام يمين
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 52.h,
                                child: MyButton(
                                  label: 'الانضمام إلى الرحلة',
                                  onPressed: () async {
                                    // 1) نفّذ منطق الإرسال (API) هنا
                                    // await sendJoinRequest();

                                    // 2) اغلق Dialog التفاصيل
                                    final rootNav = Navigator.of(context, rootNavigator: true);
                                    rootNav.pop();

                                    // 3) اعرض Dialog النجاح كودجت خارجي
                                    JoinRequestSentDialog.show(
                                      rootNav.context,
                                      successIcon: 'join_success',
                                      // successIcon: 'success_check', // لو عندك SVG مخصص
                                      onPrimaryAction: () {
                                        // الذهاب للرئيسية
                                        rootNav.popUntil((route) => route.isFirst);

                                      },
                                    );
                                  },
                                  backgroundColor: ColorsManager.primaryColor,
                                  radius: 12.r,
                                  labelStyle: TextStyles.font16White500Weight,
                                ),
                              ),
                            ),
                            horizontalSpace(12),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildContactIcon('message_icon', () {}),
                                    horizontalSpace(16),
                                    _buildContactIcon('callCalling', () {}),
                                    horizontalSpace(16),
                                    _buildContactIcon('mingcute_whatsapp-line', () {}),
                                  ],
                                ),
                              ),
                            ),



                            // زر الانضمام

                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // زر الإغلاق أعلى يمين
            Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: MySvg(
                  image: 'close_circle',
                  height: 22.w,
                  width: 22.w,
                  color: ColorsManager.darkGray300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عنصر سطر أيقونة + نص
  Widget _buildLine({
    required String iconName,
    required String text,
  }) {
    return Row(
      children: [
        MySvg(image: iconName, width: 16.w, height: 16.h, color: ColorsManager.darkGray300),
        horizontalSpace(8),
        Expanded(
          child: Text(text, style: TextStyles.font14Black400Weight, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  // مواصفات مزدوجة (يسار | يمين) كما في التصميم
  Widget _buildDoubleSpec({
    required String leftIcon,
    required String leftText,
    required String rightIcon,
    required String rightText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // يسار
        MySvg(image: leftIcon, width: 16.w, height: 16.h, color: ColorsManager.darkGray300),
        horizontalSpace(8),
        Text(leftText, style: TextStyles.font14Black400Weight),
        horizontalSpace(16),
        MySvg(image: rightIcon, width: 16.w, height: 16.h, color: ColorsManager.darkGray300),
        horizontalSpace(8),
        Text(rightText, style: TextStyles.font14Black400Weight),
      ],
    );
  }

  // أيقونات التواصل
  Widget _buildContactIcon(String iconName, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: MySvg(image: iconName, width: 24.w, height: 24.w),
      ),
    );
  }
}