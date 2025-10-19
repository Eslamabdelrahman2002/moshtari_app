// lib/features/create_ad/ui/widgets/customized_chip.dart (تعديل مقترح)
import 'package:flutter/material.dart';
import 'package:mushtary/core/theme/colors.dart';

class CustomizedChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;
  const CustomizedChip({
    super.key,
    required this.title,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primaryColor : ColorsManager.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? ColorsManager.white : ColorsManager.grey200),
        ),
        child: Text(title, style: TextStyle(color: isSelected ? ColorsManager.white : Colors.black)),
      ),
    );
  }
}