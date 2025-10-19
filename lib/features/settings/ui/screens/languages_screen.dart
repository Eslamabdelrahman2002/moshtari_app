import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

// Enum to represent the available languages
enum AppLanguage { arabic, english, urdu }

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  // State variable to hold the currently selected language
  AppLanguage? _selectedLanguage = AppLanguage.arabic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اللغات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لغات التطبيق',
              style: TextStyles.font14Dark500Weight,
            ),
            verticalSpace(16),
            _buildLanguageTile(
              title: 'العربية',
              value: AppLanguage.arabic,
            ),
            const Divider(color: ColorsManager.dark100),
            _buildLanguageTile(
              title: 'English',
              value: AppLanguage.english,
            ),
            const Divider(color: ColorsManager.dark100),
            _buildLanguageTile(
              title: 'اردو',
              value: AppLanguage.urdu,
            ),
            const Spacer(),
            PrimaryButton(
              text: 'حفظ',
              onPressed: () {
                // TODO: Add logic to save the selected language using EasyLocalization
                // For example: context.setLocale(Locale('en'));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile({required String title, required AppLanguage value}) {
    return RadioListTile<AppLanguage>(
      title: Text(title, style: TextStyles.font14Black500Weight),
      value: value,
      groupValue: _selectedLanguage,
      onChanged: (AppLanguage? newValue) {
        setState(() {
          _selectedLanguage = newValue;
        });
      },
      activeColor: ColorsManager.primaryColor,
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: EdgeInsets.zero,
    );
  }
}