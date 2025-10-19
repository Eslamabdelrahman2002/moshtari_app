// lib/features/work_with_us/ui/screens/service_provider_steps_transport.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/router/routes.dart';

// Steps
import '../../../complete_profile_success_screen.dart';
import 'transport_step1_personal.dart';
import 'transport_step2_details.dart';
import 'transport_step3_car_data.dart';

class TransportServiceProviderSteps extends StatefulWidget {
  const TransportServiceProviderSteps({super.key});

  @override
  State<TransportServiceProviderSteps> createState() => _TransportServiceProviderStepsState();
}

class _TransportServiceProviderStepsState extends State<TransportServiceProviderSteps> {
  int _currentStep = 1;
  final int _totalSteps = 3;

  void _nextStep() {
    setState(() {
      if (_currentStep < _totalSteps) {
        _currentStep++;
      } else if (_currentStep == _totalSteps) {
        // Navigate to success screen using its route
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
        return TransportStep1Personal(onNext: _nextStep);
      case 2:
        return TransportStep2Details(onNext: _nextStep);
      case 3:
        return TransportStep3CarData(onNext: _nextStep);
      default:
        return const SizedBox.shrink();
    }
  }

  // Helper functions for Step Bar (reused from previous answer)
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
            ? ColorsManager.secondary500 // Yellow for active step
            : ColorsManager.dark200,
        shape: BoxShape.circle,
        border: isActive ? Border.all(color: ColorsManager.secondary500, width: 2.w) : null,
      ),
      child: Center(
        child: isCompleted
            ? Icon(Icons.check, color: ColorsManager.white, size: 16.sp)
            : Text(
          // Use a visible number/dot styling
          '', // The image doesn't show numbers, just dots/circles
          style: isActive
              ? TextStyles.font14Black500Weight.copyWith(color: ColorsManager.primaryColor)
              : TextStyles.font14Dark200400Weight.copyWith(color: ColorsManager.white),
        ),
      ),
    );
  }

  String _getStepTitle(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return 'البيانات الشخصية';
      case 2:
        return 'مواصفات نص النقل';
      case 3:
        return 'بيانات السيارة';
      default:
        return '';
    }
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
                    // Connecting Line (Before the first step)
                    if (stepNumber > 1)
                      Expanded(
                        child: Container(
                          height: 2.h,
                          color: stepNumber <= _currentStep
                              ? ColorsManager.secondary500
                              : ColorsManager.dark200,
                        ),
                      ),
                    // Step Indicator
                    _buildStepIndicator(stepNumber),
                    // Connecting Line (After the last step)
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