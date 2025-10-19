import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/features/create_ad/ui/widgets/create_ad_stepper.dart';
// import شاشاتك الحقيقية هنا

class CreateAdFlowPage extends StatefulWidget {
  const CreateAdFlowPage({super.key});

  @override
  State<CreateAdFlowPage> createState() => _CreateAdFlowPageState();
}

class _CreateAdFlowPageState extends State<CreateAdFlowPage> {
  int step = 0;

  final stepsData = [
    CreateAdStep(title: 'التصنيف', icon: Icons.category_outlined),
    CreateAdStep(title: 'التفاصيل', icon: Icons.tune_rounded),
    CreateAdStep(title: 'العرض', icon: Icons.visibility_outlined),
  ];

  void _goTo(int i) => setState(() => step = i);
  void _next() => setState(() => step = (step + 1).clamp(0, stepsData.length - 1));
  void _back() => setState(() => step = (step - 1).clamp(0, stepsData.length - 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء إعلان')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              CreateAdStepper(
                steps: stepsData,
                currentStep: step,
                onStepTapped: _goTo,
                activeColor: ColorsManager.primaryColor,
                completedColor: ColorsManager.primaryColor,
                inactiveColor: ColorsManager.lightGrey,
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _StepContent(
                    key: ValueKey(step),
                    step: step,
                    onNext: _next,
                    onBack: _back,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  final int step;
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _StepContent({super.key, required this.step, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (step) {
      case 0:
        child = _PlaceholderStep(title: 'شاشة اختيار التصنيف', onNext: onNext);
        break;
      case 1:
        child = _PlaceholderStep(title: 'شاشة التفاصيل', onNext: onNext, onBack: onBack);
        break;
      default:
        child = _PlaceholderStep(title: 'شاشة عرض المعلومات', onBack: onBack);
    }
    return child;
  }
}

class _PlaceholderStep extends StatelessWidget {
  final String title;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  const _PlaceholderStep({required this.title, this.onNext, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 12,
        alignment: WrapAlignment.center,
        children: [
          if (onBack != null)
            ElevatedButton(onPressed: onBack, child: const Text('السابق')),
          Text(title),
          if (onNext != null)
            ElevatedButton(onPressed: onNext, child: const Text('التالي')),
        ],
      ),
    );
  }
}