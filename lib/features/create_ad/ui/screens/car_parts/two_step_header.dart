import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';

class TwoStepHeader extends StatelessWidget {
  final int currentStep; // 0: حدد التصنيف (يمين) | 1: معلومات العرض (يسار)
  const TwoStepHeader({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFFFFC107); // أصفر مطابق للمعاينة
    final Color idle = ColorsManager.lightGrey;

    final int clamped = currentStep.clamp(0, 1);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 32.h,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fullW = constraints.maxWidth;
                // التقدم من اليمين: 0 (لا شيء) -> 1 (كامل)
                final progress = clamped / 1; // 0 أو 1
                final progressW = fullW * progress;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // خط الخلفية
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 3.h,
                          width: fullW,
                          color: idle.withOpacity(0.45),
                        ),
                      ),
                    ),
                    // خط التقدّم (Anchored Right)
                    if (progressW > 0)
                      Positioned(
                        left: fullW - progressW,
                        right: 0,
                        child: Container(
                          height: 3.h,
                          color: primary,
                        ),
                      ),
                    // الدوائر: يسار (step 1) - يمين (step 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // يسار: معلومات العرض (step 1)

                        // يمين: حدد التصنيف (step 0)
                        _StepCircleVisual(
                          isActive: clamped == 0,
                          isDone: clamped > 0, // مكتمل عندما تنتقل للخطوة 1
                          mainColor: primary,
                          idleColor: idle,
                          size: 22.w,
                        ),
                        _StepCircleVisual(
                          isActive: clamped == 1,
                          isDone: false,
                          mainColor: primary,
                          idleColor: idle,
                          size: 22.w,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 6.h),
          // العناوين
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'حدد التصنيف',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: (clamped == 0 || clamped > 0) ? FontWeight.w600 : FontWeight.w500,
                      color: (clamped == 0 || clamped > 0) ? Colors.black : Colors.black45,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'معلومات العرض',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: (clamped == 1) ? FontWeight.w600 : FontWeight.w500,
                      color: (clamped == 1) ? Colors.black : Colors.black45,
                    ),
                  ),
                ),
              ),


            ],
          ),
        ],
      ),
    );
  }
}

class _StepCircleVisual extends StatelessWidget {
  final bool isActive;   // الحلقة + نقطة داخلية
  final bool isDone;     // دائرة ممتلئة مع صح
  final Color mainColor; // أصفر
  final Color idleColor; // رمادي
  final double size;

  const _StepCircleVisual({
    required this.isActive,
    required this.isDone,
    required this.mainColor,
    required this.idleColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      // دائرة ممتلئة + صح (يمين عندما تنتقل للخطوة 1)
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: mainColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(Icons.check, size: (size * 0.55), color: Colors.white),
      );
    }

    // حلقة + نقطة داخلية إن كانت نشطة، وإلا حلقة رمادية
    final borderColor = isActive ? mainColor : idleColor.withOpacity(0.8);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2.2),
      ),
      alignment: Alignment.center,
      child: isActive
          ? Container(
        width: (size * 0.42),
        height: (size * 0.42),
        decoration: BoxDecoration(
          color: mainColor,
          shape: BoxShape.circle,
        ),
      )
          : const SizedBox.shrink(),
    );
  }
}