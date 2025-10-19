// lib/features/work_with_us/ui/screens/tanker_service_steps.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

// Steps and Success screen
import 'tanker_step1_personal_data.dart';
import 'tanker_step2_specs.dart';
import 'tanker_step3_documents.dart';
import '../../../complete_profile_success_screen.dart'; // افترض مسار الشاشة الناجحة

class TankerServiceSteps extends StatefulWidget {
  const TankerServiceSteps({super.key});

  @override
  State<TankerServiceSteps> createState() => _TankerServiceStepsState();
}

class _TankerServiceStepsState extends State<TankerServiceSteps> {
  int _currentStep = 1;
  final int _totalSteps = 3;

  void _nextStep() {
    setState(() {
      if (_currentStep < _totalSteps) {
        _currentStep++;
      } else if (_currentStep == _totalSteps) {
        // Navigate to success screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CompleteProfileSuccessScreen()),
        );
      }
    });
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return TankerStep1PersonalData(onNext: _nextStep);
      case 2:
        return TankerStep2Specs(onNext: _nextStep);
      case 3:
        return TankerStep3Documents(onNext: _nextStep);
      default:
        return const SizedBox.shrink();
    }
  }

  String _getStepTitle(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return 'البيانات الشخصية';
      case 2:
        return 'مواصفات الصهريج';
      case 3:
        return 'الصور المطلوبة';
      default:
        return '';
    }
  }

  // Step Indicator UI (reused)
  Widget _buildStepIndicator(int stepNumber) {
    bool isCompleted = stepNumber < _currentStep;
    bool isActive = stepNumber == _currentStep;

    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        color: isCompleted
            ? ColorsManager.secondary500
            : isActive
            ? ColorsManager.secondary500
            : ColorsManager.dark200,
        shape: BoxShape.circle,
        border: isActive ? Border.all(color: ColorsManager.secondary500, width: 2.w) : null,
      ),
    );
  }

  Widget _buildStepBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_totalSteps, (index) {
          int stepNumber = index + 1;
          return Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (stepNumber > 1)
                      Expanded(
                        child: Container(
                          height: 2.h,
                          color: stepNumber <= _currentStep
                              ? ColorsManager.secondary500
                              : ColorsManager.dark200,
                        ),
                      ),
                    _buildStepIndicator(stepNumber),
                    if (stepNumber < _totalSteps)
                      Expanded(
                        child: Container(
                          height: 2.h,
                          color: stepNumber < _currentStep
                              ? ColorsManager.secondary500
                              : ColorsManager.dark200,
                        ),
                      ),
                  ],
                ),
                verticalSpace(8),
                Text(
                  _getStepTitle(stepNumber),
                  textAlign: TextAlign.center,
                  style: TextStyles.font10Dark400Grey400Weight.copyWith(
                    color: stepNumber == _currentStep
                        ? ColorsManager.primaryColor
                        : ColorsManager.darkGray400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سجل كمقدم خدمة',
          style: TextStyles.font18Black500Weight,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ColorsManager.black),
          onPressed: _previousStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildStepContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}