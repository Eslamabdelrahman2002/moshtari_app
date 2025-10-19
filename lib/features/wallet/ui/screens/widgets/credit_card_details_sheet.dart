import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';

class CreditCardDetailsSheet extends StatelessWidget {
  const CreditCardDetailsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('شحن الرصيد', style: TextStyles.font18Black500Weight),
          verticalSpace(24),
          const SecondaryTextFormField(
            label: 'مبلغ الشحن',
            hint: '1500',
            isNumber: true,
            maxheight: 56,
            minHeight: 56,
          ),
          verticalSpace(16),
          // You can replace these with your actual payment card logos
          Image.asset('assets/images/payment_cards.png'),
          verticalSpace(16),
          const SecondaryTextFormField(
            label: 'رقم البطاقة',
            hint: '.... .... .... ....',
            isNumber: true,
            maxheight: 56,
            minHeight: 56,
          ),
          verticalSpace(16),
          const SecondaryTextFormField(
            label: 'الاسم علي البطاقة',
            hint: 'أدخل الاسم',
            maxheight: 56,
            minHeight: 56,
          ),
          verticalSpace(16),
          Row(
            children: [
              const Expanded(
                child: SecondaryTextFormField(
                  label: 'CVV',
                  hint: '123',
                  isNumber: true,
                  maxheight: 56,
                  minHeight: 56,
                ),
              ),
              horizontalSpace(16),
              const Expanded(
                child: SecondaryTextFormField(
                  label: 'تاريخ الانتهاء',
                  hint: 'MM/YY',
                  isNumber: true,
                  maxheight: 56,
                  minHeight: 56,
                ),
              ),
            ],
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
                  text: 'إتمام العملية',
                  onPressed: () {
                    // TODO: Handle card payment processing
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