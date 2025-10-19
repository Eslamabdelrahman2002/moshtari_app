import 'package:flutter/material.dart';
import 'package:mushtary/core/widgets/primary/auth_text_form_field.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label; // Allow passing a custom label

  const PasswordTextField({
    super.key,
    this.controller,
    this.label, // Add label to the constructor
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool isPassword = true;
  @override
  Widget build(BuildContext context) {
    return AuthTextFormField(
      controller: widget.controller,
      validationError: 'كلمة المرور مطلوبة',
      label: widget.label ?? 'كلمة المرور', // Use the provided label or a default one
      prefixIcon: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: MySvg(image: 'lock'),
      ),
      isPassword: isPassword,
      suffixIcon: InkWell(
        onTap: () {
          setState(() {
            isPassword = !isPassword;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: MySvg(image: isPassword ? 'eye_off' : 'eye'), // Change icon based on state
        ),
      ),
    );
  }
}
