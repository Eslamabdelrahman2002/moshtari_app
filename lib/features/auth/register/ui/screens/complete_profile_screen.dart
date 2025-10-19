import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  File? _imageFile;
  String? _selectedActivity;
  final List<String> _accountActivities = ['نشاط 1', 'نشاط 2', 'نشاط 3'];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            Text('إنشاء حساب الآن', style: TextStyles.font24Black700Weight),
            verticalSpace(8),
            Text(
              'يرجى ملء التفاصيل وإنشاء الحساب',
              style: TextStyles.font16DarkGrey400Weight,
            ),
            verticalSpace(32),
            const SecondaryTextFormField(
              label: 'الاسم',
              hint: '02020626292',
              maxheight: 56,
              minHeight: 56,
            ),
            verticalSpace(16),
            DropdownButtonFormField<String>(
              value: _selectedActivity,
              hint: const Text('نشاط الحساب'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items: _accountActivities.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedActivity = newValue;
                });
              },
            ),
            verticalSpace(16),
            const SecondaryTextFormField(
              label: 'رقم الجوال',
              hint: '562651653',
              prefixIcon: '+965',
              isPhone: true,
              maxheight: 56,
              minHeight: 56,
            ),
            verticalSpace(16),
            const SecondaryTextFormField(
              label: 'العنوان',
              hint: 'العنوان',
              maxheight: 56,
              minHeight: 56,
            ),
            verticalSpace(24),
            GestureDetector(
              onTap: _pickImage,
              child: DottedBorder(
                color: ColorsManager.primaryColor.withOpacity(0.5),
                strokeWidth: 1,
                dashPattern: const [6, 6],
                borderType: BorderType.RRect,
                radius: Radius.circular(12.r),
                child: Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: ColorsManager.primary50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                      child: _imageFile == null
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const MySvg(image: 'gallery-add'),
                          verticalSpace(8),
                          Text(
                            'رفع صورة للحساب',
                            style: TextStyles.font14PrimaryColor400Weight,
                          ),
                        ],
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity,),
                      )
                  ),
                ),
              ),
            ),
            verticalSpace(40),
            PrimaryButton(
              text: 'إنشاء حساب',
              onPressed: () {
                // TODO: Add account creation logic
              },
            ),
            verticalSpace(24),
          ],
        ),
      ),
    );
  }
}