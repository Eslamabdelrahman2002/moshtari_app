import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/auth_text_form_field.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class PhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? validationError;
  const PhoneTextField({super.key, this.controller, this.validationError});

  @override
  Widget build(BuildContext context) {
    return AuthTextFormField(
      controller: controller,
      validationError: validationError ?? 'Error',
      keyboardType: TextInputType.phone,
      hint: '00000000',
      label: 'رقم الجوال',
      prefixIcon: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: MySvg(image: 'phone'),
      ),
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 24, width: 1.5, color: ColorsManager.lightGrey),
          horizontalSpace(8),
          Text('+966', style: TextStyles.font14Black400Weight),
          horizontalSpace(12),
        ],
      ),
    );
  }
}
