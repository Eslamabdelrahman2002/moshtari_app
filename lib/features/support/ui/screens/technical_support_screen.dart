import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';

import '../../../../core/utils/helpers/spacing.dart';
import '../../../../core/widgets/primary/primary_button.dart';

enum TicketType { complaint, suggestion }

class TechnicalSupportScreen extends StatefulWidget {
  const TechnicalSupportScreen({super.key});

  @override
  State<TechnicalSupportScreen> createState() => _TechnicalSupportScreenState();
}

class _TechnicalSupportScreenState extends State<TechnicalSupportScreen> {
  TicketType? _selectedType;
  String? _selectedDepartment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدعم الفني'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نوع التذكرة', style: TextStyles.font14Black500Weight),
            verticalSpace(16),
            Row(
              children: [
                Expanded(
                  child: _buildTypeChip('شكوى', TicketType.complaint),
                ),
                horizontalSpace(16), // Adds space between the buttons
                Expanded(
                  child: _buildTypeChip('إقتراح', TicketType.suggestion),
                ),
              ],
            ),
            verticalSpace(24),
            // Conditionally display the correct form fields
            if (_selectedType == TicketType.complaint)
              _buildComplaintForm(),
            if (_selectedType == TicketType.suggestion)
              _buildSuggestionForm(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.w),
        child: PrimaryButton(
          text: 'إرسال رسالة',
          onPressed: () {
            // TODO: Add logic to send support message
          },
        ),
      ),
    );
  }

  // ✨ FIX: This method is updated to use styled buttons instead of ActionChip
  Widget _buildTypeChip(String label, TicketType type) {
    bool isSelected = _selectedType == type;
    return SizedBox(
      height: 48.h,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedType = type;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? ColorsManager.primaryColor : Colors.white,
          foregroundColor: isSelected ? Colors.white : ColorsManager.darkGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: isSelected
                ? BorderSide.none
                : const BorderSide(color: ColorsManager.dark200),
          ),
          elevation: 0,
        ),
        child: Text(label, style: TextStyles.font14Black500Weight.copyWith(
          color: isSelected ? Colors.white : ColorsManager.darkGray,
        )),
      ),
    );
  }

  Widget _buildComplaintForm() {
    final List<String> departments = ['القسم الأول', 'القسم الثاني', 'القسم الثالث'];
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedDepartment,
          hint: Text('القسم المختار', style: TextStyles.font14Dark200400Weight),
          decoration: InputDecoration(
            labelText: 'الشكوي في قسم',
            labelStyle: TextStyles.font12Dark500400Weight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: ColorsManager.dark200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: ColorsManager.dark200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: ColorsManager.primaryColor),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          items: departments.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedDepartment = newValue;
            });
          },
        ),
        verticalSpace(16),
        const SecondaryTextFormField(
          label: 'تفاصيل الشكوى',
          hint: 'اكتب تفاصيل شكوتك هنا...',
          maxLines: 5,
          maxheight: 120,
          minHeight: 120,
        ),
      ],
    );
  }

  Widget _buildSuggestionForm() {
    return const Column(
      children: [
        SecondaryTextFormField(
          label: 'تفاصيل الإقتراح',
          hint: 'اكتب تفاصيل إقتراحك هنا...',
          maxLines: 5,
          maxheight: 120,
          minHeight: 120,
        ),
      ],
    );
  }
}