import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

// Steps
import '../../../complete_profile_success_screen.dart';
import 'delivery_step1_service_details.dart';
import 'delivery_step2_personal_data.dart';
import 'delivery_step3_documents.dart';

class DeliveryServiceSteps extends StatefulWidget {
  const DeliveryServiceSteps({super.key});

  @override
  State<DeliveryServiceSteps> createState() => _DeliveryServiceStepsState();
}

class _DeliveryServiceStepsState extends State<DeliveryServiceSteps> {
  int _currentStep = 1;
  final int _totalSteps = 3;

  void _nextStep() {
    setState(() {
      if (_currentStep < _totalSteps) {
        _currentStep++;
      } else if (_currentStep == _totalSteps) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CompleteProfileSuccessScreen()),
        );
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
        return DeliveryStep2PersonalData(onNext: _nextStep);
      case 2:
        return DeliveryStep1ServiceDetails(onNext: _nextStep);
      case 3:
        return DeliveryStep3Documents(onNext: _nextStep);
      default:
        return const SizedBox.shrink();
    }
  }

  String _getStepTitle(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return 'تفاصيل الخدمة';
      case 2:
        return 'البيانات الشخصية';
      case 3:
        return 'الصور المطلوبة';
      default:
        return '';
    }
  }

  Widget _buildStepIndicator(int stepNumber) {
    bool isCompleted = stepNumber < _currentStep;
    bool isActive = stepNumber == _currentStep;

    const Color activeColor = ColorsManager.secondary500;
    const Color inactiveColor = ColorsManager.white;

    Border indicatorBorder = Border.all(
      color: isActive || isCompleted ? activeColor : ColorsManager.dark200,
      width: 2.w,
    );

    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        color: inactiveColor,
        shape: BoxShape.circle,
        border: indicatorBorder,
      ),
      child: (isActive || isCompleted)
          ? Center(
        child: Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isCompleted ? activeColor : ColorsManager.dark200,
          ),
        ),
      )
          : const SizedBox.shrink(),
    );
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

          Color lineColor =
          isCompleted || isActive ? ColorsManager.secondary500 : ColorsManager.dark200;

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