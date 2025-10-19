import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';

class CreateAdStep {
  final String title;
  final IconData? icon; // لم نعد نعرض الأيقونة داخل الدائرة في هذا التصميم
  CreateAdStep({required this.title, this.icon});
}

class CreateAdStepper extends StatelessWidget {
  final List<CreateAdStep> steps;
  final int currentStep; // يبدأ من 0
  final void Function(int)? onStepTapped;

  // تخصيص ألوان/أحجام
  final Color? activeColor;    // الخطوة الحالية + خط التقدم
  final Color? completedColor; // الخطوات المكتملة
  final Color? inactiveColor;  // الخطوات القادمة + خط الخلفية
  final double circleSize;
  final double lineHeight;
  final bool showCheckOnCompleted;

  const CreateAdStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.onStepTapped,
    this.activeColor,
    this.completedColor,
    this.inactiveColor,
    this.circleSize = 28, // أقرب للتصميم
    this.lineHeight = 4,
    this.showCheckOnCompleted = true,
  });

  @override
  Widget build(BuildContext context) {
    // أصفر مطابق للمعاينة إذا لم يُمرّر لون
    final Color primary = activeColor ?? const Color(0xFFFFC107);
    final Color done = completedColor ?? primary;
    final Color idle = inactiveColor ?? (ColorsManager.lightGrey);

    final int total = steps.length;
    final int clampedCurrent = currentStep.clamp(0, (total - 1).clamp(0, 999));
    final double progress =
    total <= 1 ? 1 : (clampedCurrent / (total - 1)).clamp(0.0, 1.0);

    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48.h,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double fullW = constraints.maxWidth;
                final double progressW = fullW * progress;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // خط الخلفية
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: lineHeight.h,
                          width: fullW,
                          color: idle.withOpacity(0.35),
                        ),
                      ),
                    ),
                    // خط التقدم (يتكيّف مع RTL/LTR)
                    Positioned(
                      left: isRTL ? fullW - progressW : 0,
                      right: isRTL ? 0 : fullW - progressW,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: lineHeight.h,
                          color: done,
                        ),
                      ),
                    ),
                    // الدوائر
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(total, (i) {
                        final bool isCompleted = i < clampedCurrent;
                        final bool isActive = i == clampedCurrent;
                        return _buildStepCircle(
                          index: i,
                          isActive: isActive,
                          isCompleted: isCompleted,
                          size: circleSize.w,
                          mainColor: primary,
                          idleColor: idle,
                          onTap: onStepTapped == null ? null : () => onStepTapped!(i),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
          // العناوين تحت الخط
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (i) {
              final bool isActive = i == clampedCurrent;
              return Expanded(
                child: Container(
                  alignment: i == 0
                      ? Alignment.centerLeft
                      : i == steps.length - 1
                      ? Alignment.centerRight
                      : Alignment.center,
                  child: Text(
                    steps[i].title,
                    textAlign: i == 0
                        ? TextAlign.left
                        : i == steps.length - 1
                        ? TextAlign.right
                        : TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? primary : Colors.black87,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle({
    required int index,
    required bool isActive,
    required bool isCompleted,
    required double size,
    required Color mainColor,
    required Color idleColor,
    VoidCallback? onTap,
  }) {
    // تصميم الدائرة:
    // - مكتملة: دائرة ممتلئة بلون أصفر + أيقونة صح بيضاء
    // - حالية: حلقة (حد أصفر) مع نقطة داخلية صغيرة بنفس اللون
    // - قادمة: حلقة رمادية بدون نقطة
    final borderColor = isCompleted
        ? mainColor
        : (isActive ? mainColor : idleColor.withOpacity(0.8));

    final bgColor = isCompleted
        ? mainColor
        : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 3, // حلقة واضحة
          ),
          boxShadow: isCompleted
              ? [
            BoxShadow(
              color: mainColor.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ]
              : null,
        ),
        alignment: Alignment.center,
        child: isCompleted
            ? Icon(Icons.check, size: 16.sp, color: Colors.white)
            : (isActive
            ? Container(
          width: (size * 0.38),
          height: (size * 0.38),
          decoration: BoxDecoration(
            color: mainColor,
            shape: BoxShape.circle,
          ),
        )
            : const SizedBox.shrink()),
      ),
    );
  }
}