import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';

class TransferBalanceSheet extends StatelessWidget {
  const TransferBalanceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تحويل رصيد', style: TextStyles.font18Black500Weight),
          verticalSpace(24),
          const SecondaryTextFormField(
            label: 'رقم الجوال',
            hint: '+965 562651653',
            isPhone: true,
            maxheight: 56,
            minHeight: 56,
          ),
          verticalSpace(16),
          const SecondaryTextFormField(
            label: 'مبلغ التحويل',
            hint: '1500',
            isNumber: true,
            maxheight: 56,
            minHeight: 56,
          ),
          verticalSpace(24),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'إلغاء',
                  onPressed: () => Navigator.of(context).pop(),
                  backgroundColor: ColorsManager.dark50,
                  textColor: ColorsManager.darkGray600,
                ),
              ),
              horizontalSpace(16),
              Expanded(
                child: PrimaryButton(
                  text: 'إتمام التحويل',
                  onPressed: () {
                    // TODO: Handle transfer logic
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}