import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

class CarPartSpecsCardElevated extends StatelessWidget {
  final String? condition;
  final String? brand;
  final List<String> supportedModels;
  final double elevation;

  const CarPartSpecsCardElevated({
    super.key,
    required this.condition,
    required this.brand,
    required this.supportedModels,
    this.elevation = 4,
  });

  @override
  Widget build(BuildContext context) {
    final String cond = (condition ?? '').trim().isEmpty ? '—' : condition!.trim();
    final String brnd = (brand ?? '').trim().isEmpty ? '—' : brand!.trim();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Material(
        color: ColorsManager.white,
        elevation: elevation,
        shadowColor: ColorsManager.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: ColorsManager.grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.tune, color: ColorsManager.darkGray300, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text('تفاصيل القطعة', style: TextStyles.font20Black500Weight),
                ],
              ),
              SizedBox(height: 10.h),
              Divider(height: 1, thickness: .7, color: ColorsManager.grey200),

              // حالة القطعة
              _specLine(label: 'حالة القطعة', value: cond),

              // البراند
              _specLine(label: 'البراند', value: brnd),

              // الموديلات المدعومة
              SizedBox(height: 6.h),
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('الموديلات المدعومة', style: TextStyles.font14Black400Weight),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  supportedModels.isNotEmpty
                      ? Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: supportedModels.map((m) => _modelChip(m)).toList(),
                  )
                      : Align(
                    alignment: Alignment.centerRight,
                    child: Text('—', style: TextStyles.font14Dark400400Weight),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _specLine({required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Expanded(child: Text(label, style: TextStyles.font16DarkGrey500Weight)),
            SizedBox(width: 8.w),
            Text(
              value,
              style: TextStyles.font14Black400Weight,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  Widget _modelChip(String text) {
    return Text(
      text,
      style: TextStyles.font12Black400Weight,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}