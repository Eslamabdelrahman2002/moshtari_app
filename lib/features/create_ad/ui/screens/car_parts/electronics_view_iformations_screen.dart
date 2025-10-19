import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/widgets/create_real_estate_ad_add_photo_video.dart';
import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';
import 'package:mushtary/features/create_ad/ui/widgets/detail_selector.dart';
import 'package:mushtary/features/create_ad/ui/widgets/next_button_bar.dart';

class ElectronicsViewIformationsScreen extends StatefulWidget {
  const ElectronicsViewIformationsScreen({super.key});

  @override
  State<ElectronicsViewIformationsScreen> createState() =>
      _ElectronicsViewIformationsScreenState();
}

class _ElectronicsViewIformationsScreenState
    extends State<ElectronicsViewIformationsScreen> {
  bool isChatAvailable = false;
  bool isWhatsAppAvailable = false;
  bool isPhoneAvailable = false;
  bool isCommentsAvailable = false;
  bool isAllowedToAdvertisingMarketing = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 535.h,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CreateRealEstateAdAddPhotoVideo(
                pickImage: () async {
                  setState(() {}); // UI only
                },
                remove: (index) {
                  setState(() {}); // UI only
                },
                pickedImages: const [],
              ),
              verticalSpace(16.h),
              SecondaryTextFormField(
                label: 'عنوان الاعلان',
                hint: 'مثال: فيلا للبيع في حي النسيم',
                maxheight: 56.h,
                minHeight: 56.h,
              ),
              verticalSpace(16.h),
              SecondaryTextFormField(
                label: 'وصف العرض',
                hint: 'أكتب وصف للمنتج...',
                maxheight: 96.w,
                minHeight: 96.w,
                maxLines: 4,
              ),
              verticalSpace(16.h),
              SecondaryTextFormField(
                label: 'رقم الهاتف',
                hint: 'مثال: 0555555555',
                maxheight: 56.h,
                minHeight: 56.h,
                isPhone: true,
                maxLength: 10,
              ),
              verticalSpace(16.h),
              DetailSelector(
                title: 'التواصل',
                widget: Row(
                  children: [
                    Expanded(
                      child: CustomizedChip(
                        title: 'محادثة',
                        isSelected: isChatAvailable,
                        onTap: () {
                          setState(() {
                            isChatAvailable = !isChatAvailable;
                          });
                        },
                      ),
                    ),
                    horizontalSpace(16),
                    Expanded(
                      child: CustomizedChip(
                        title: 'واتساب',
                        isSelected: isWhatsAppAvailable,
                        onTap: () {
                          setState(() {
                            isWhatsAppAvailable = !isWhatsAppAvailable;
                          });
                        },
                      ),
                    ),
                    horizontalSpace(16),
                    Expanded(
                      child: CustomizedChip(
                        title: 'جوال',
                        isSelected: isPhoneAvailable,
                        onTap: () {
                          setState(() {
                            isPhoneAvailable = !isPhoneAvailable;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpace(16.h),
              Row(
                children: [
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      inactiveTrackColor: ColorsManager.lightGrey,
                      thumbColor: ColorsManager.secondary500,
                      activeTrackColor: ColorsManager.secondary200,
                      value: isCommentsAvailable,
                      onChanged: (value) {
                        setState(() {
                          isCommentsAvailable = value;
                        });
                      },
                    ),
                  ),
                  Text('السماح بالتعليق على الاعلان',
                      style: TextStyles.font14Dark500Weight),
                ],
              ),
              verticalSpace(4),
              Row(
                children: [
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      inactiveTrackColor: ColorsManager.lightGrey,
                      thumbColor: ColorsManager.secondary500,
                      activeTrackColor: ColorsManager.secondary200,
                      value: isAllowedToAdvertisingMarketing,
                      onChanged: (value) {
                        setState(() {
                          isAllowedToAdvertisingMarketing = value;
                        });
                      },
                    ),
                  ),
                  Text('السماح بتسويق الاعلان',
                      style: TextStyles.font14Dark500Weight),
                ],
              ),
              verticalSpace(16),
              NextButtonBar(
                title: 'نشر الاعلان',
                onPressed: () {
                  // UI only
                },
              ),
              verticalSpace(16),
            ],
          ),
        ),
      ),
    );
  }
}
