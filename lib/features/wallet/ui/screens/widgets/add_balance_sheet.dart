import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_bottom_sheet.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';

import 'credit_card_details_sheet.dart';

enum PaymentMethod { applePay, card }

class AddBalanceSheet extends StatefulWidget {
  const AddBalanceSheet({super.key});

  @override
  State<AddBalanceSheet> createState() => _AddBalanceSheetState();
}

class _AddBalanceSheetState extends State<AddBalanceSheet> {
  PaymentMethod? _selectedMethod = PaymentMethod.applePay;

  void _handlePayment() {
    Navigator.of(context).pop(); // Close the current sheet first
    if (_selectedMethod == PaymentMethod.card) {
      // Open the credit card details sheet
      showPrimaryBottomSheet(
        context: context,
        child: const CreditCardDetailsSheet(),
      );
    } else {
      // TODO: Handle Apple Pay logic here
    }
  }

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
          _buildPaymentMethodTile(
            title: 'Apple Pay',
            value: PaymentMethod.applePay,
          ),
          const Divider(color: ColorsManager.dark100),
          _buildPaymentMethodTile(
            title: 'مدى - Mastercard',
            value: PaymentMethod.card,
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
                  text: 'Pay',
                  onPressed: _handlePayment,
                  backgroundColor: Colors.black,
                  prefixIcon: const Icon(Icons.apple, color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile({required String title, required PaymentMethod value}) {
    return RadioListTile<PaymentMethod>(
      title: Text(title, style: TextStyles.font14Black500Weight),
      value: value,
      groupValue: _selectedMethod,
      onChanged: (PaymentMethod? newValue) {
        setState(() {
          _selectedMethod = newValue;
        });
      },
      activeColor: ColorsManager.primaryColor,
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: EdgeInsets.zero,
    );
  }
}