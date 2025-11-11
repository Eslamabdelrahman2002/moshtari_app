import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

enum ServiceType { worker, satha, dinat, tanker }

class RegisterServiceDialog extends StatefulWidget {
  const RegisterServiceDialog({super.key});

  @override
  State<RegisterServiceDialog> createState() => _RegisterServiceDialogState();
}

class _RegisterServiceDialogState extends State<RegisterServiceDialog> {
  ServiceType? _selectedService = ServiceType.worker;

  String _mapServiceType(ServiceType type) {
    switch (type) {
      case ServiceType.worker:
        return 'ajir';
      case ServiceType.dinat:
        return 'dyna';
      case ServiceType.satha:
        return 'satha';
      case ServiceType.tanker:
        return 'tanker';
    }
  }

  String _mapRoute(ServiceType type) {
    switch (type) {
      case ServiceType.worker:
        return Routes.completeProfileSteps;
      case ServiceType.dinat:
        return Routes.transportServiceSteps;
      case ServiceType.satha:
        return Routes.deliveryServiceSteps;
      case ServiceType.tanker:
        return Routes.tankerServiceSteps;
    }
  }

  void _navigateToNextStep() {
    if (_selectedService == null) return;

    final serviceKey = _mapServiceType(_selectedService!);
    final routeName = _mapRoute(_selectedService!);

    Navigator.of(context).pop(<String, String>{
      'routeName': routeName,
      'serviceType': serviceKey,
    });
  }

  Widget _buildServiceOption(ServiceType type, String title, String imageName) {
    bool isSelected = _selectedService == type;

    return InkWell(
      onTap: () => setState(() => _selectedService = type),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: ColorsManager.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? ColorsManager.primaryColor : ColorsManager.dark200,
            width: 2.w,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? ColorsManager.primaryColor : ColorsManager.dark200,
                  width: 2.w,
                ),
                color: ColorsManager.white,
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorsManager.primaryColor,
                  ),
                ),
              )
                  : null,
            ),
            Center(
              child: Column(
                children: [
                  MySvg(image: imageName, width: 80.w, height: 80.w),
                  Text(title, style: TextStyles.font18Black500Weight),
                ],
              ),
            ),
            verticalSpace(8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 16.h, right: 16.w, left: 16.w, bottom: 16.h),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const MySvg(image: 'close_circle', color: ColorsManager.primaryColor),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('اختر نوع الخدمة', style: TextStyles.font20Black500Weight),
                ],
              ),
            ],
          ),
          verticalSpace(8),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
            ),
            children: [
              _buildServiceOption(ServiceType.worker, 'أجير', 'employee'),
              _buildServiceOption(ServiceType.satha, 'سطحة', 'flat'),
              _buildServiceOption(ServiceType.dinat, 'دينة', 'dinah'),
              _buildServiceOption(ServiceType.tanker, 'صهريج مياه', 'waterTank'),
            ],
          ),
          verticalSpace(16),
          PrimaryButton(
            text: 'التالي',
            onPressed: _navigateToNextStep,
            isDisabled: _selectedService == null,
          ),
        ],
      ),
    );
  }
}