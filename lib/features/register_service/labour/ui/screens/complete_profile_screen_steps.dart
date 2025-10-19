import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

// Steps
import 'complete_profile_step1_personal.dart';
import 'complete_profile_step2_details.dart';
import 'complete_profile_step3_location.dart';

class CompleteProfileScreenSteps extends StatefulWidget {
  const CompleteProfileScreenSteps({super.key});

  @override
  State<CompleteProfileScreenSteps> createState() => _CompleteProfileScreenStepsState();
}

class _CompleteProfileScreenStepsState extends State<CompleteProfileScreenSteps> {
  int _currentStep = 1;
  final int _totalSteps = 3;

  void _nextStep() {
    setState(() {
      if (_currentStep < _totalSteps) {
        _currentStep++;
      } else if (_currentStep == _totalSteps) {
        Navigator.of(context).pushReplacementNamed(Routes.completeProfileScreen);
      }
    });
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return CompleteProfileStep1Personal(onNext: _nextStep);
      case 2:
        return CompleteProfileStep2Details(onNext: _nextStep);
      case 3:
        return CompleteProfileStep3Location(onNext: _nextStep);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepIndicator(int stepNumber) {
    bool isCompleted = stepNumber < _currentStep;
    bool isActive = stepNumber == _currentStep;

    const Color activeColor = ColorsManager.secondary500;
    const Color inactiveColor = ColorsManager.dark200;

    Color backgroundColor = isActive ? activeColor : inactiveColor;

    Border indicatorBorder = Border.all(
      color: isActive || isCompleted ? activeColor : inactiveColor,
      width: 2.w,
    );

    Color textColor = isActive ? ColorsManager.black : ColorsManager.white;

    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: indicatorBorder,
      ),
      child: Center(
        child: Text(
          '$stepNumber',
          style: TextStyles.font14Black500Weight.copyWith(
            color: textColor,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  String _getStepTitle(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return 'البيانات الشخصية';
      case 2:
        return 'بيانات العمل والتخصص';
      case 3:
        return 'الموقع ووسائل التواصل';
      default:
        return '';
    }
  }

  Widget _buildStepBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_totalSteps, (index) {
          int stepNumber = index + 1;
          bool isActive = stepNumber == _currentStep;
          bool isCompleted = stepNumber < _currentStep;

          Color lineColor = isCompleted || isActive ? ColorsManager.secondary500 : ColorsManager.dark200;
          Color textColor = isActive ? ColorsManager.primaryColor : ColorsManager.darkGray400;

          return Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (stepNumber > 1)
                      Expanded(child: Container(height: 2.h, color: lineColor)),
                    _buildStepIndicator(stepNumber),
                    if (stepNumber < _totalSteps)
                      Expanded(
                        child: Container(
                          height: 2.h,
                          color: isCompleted || isActive ? lineColor : ColorsManager.dark200,
                        ),
                      ),
                  ],
                ),
                verticalSpace(8),
                Text(
                  _getStepTitle(stepNumber),
                  textAlign: TextAlign.center,
                  style: TextStyles.font10Dark400Grey400Weight.copyWith(
                    color: textColor,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    fontSize: 10.sp,
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
        title: Text('سجل كمقدم خدمة', style: TextStyles.font18Black500Weight),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
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