import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/router/routes.dart';

class AuctionCategoryPickerScreen extends StatefulWidget {
  const AuctionCategoryPickerScreen({super.key});

  @override
  State<AuctionCategoryPickerScreen> createState() => _AuctionCategoryPickerScreenState();
}

class _AuctionCategoryPickerScreenState extends State<AuctionCategoryPickerScreen> {
  String? _selected; // car | real_estate

  Widget _option(String key, String title, IconData icon) {
    final sel = _selected == key;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: () => setState(() => _selected = key),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: sel ? ColorsManager.primary400 : ColorsManager.dark200, width: 1.2),
          ),
          child: Row(
            children: [
              Icon(icon, color: sel ? ColorsManager.primary400 : ColorsManager.darkGray, size: 28.sp),
              SizedBox(width: 12.w),
              Expanded(child: Text(title, style: TextStyles.font16Black500Weight)),
              Radio<String>(
                value: key,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v),
                activeColor: ColorsManager.primary400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _next() {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('من فضلك اختر نوع المزاد')));
      return;
    }
    if (_selected == 'car') {
      Navigator.of(context).pushNamed(Routes.createCarAuctionScreen);
    } else {
      Navigator.of(context).pushNamed(Routes.createRealEstateAuctionScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.white,
      appBar: AppBar(
        title: const Text('اختَر نوع المزاد'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('اختر المجال', style: TextStyles.font16Dark300Grey400Weight),
              SizedBox(height: 12.h),
              _option('car', 'سيارات', Icons.directions_car_rounded),
              SizedBox(height: 12.h),
              _option('real_estate', 'عقارات', Icons.home_work_rounded),
              const Spacer(),
              PrimaryButton(
                text: 'التالي',
                onPressed: _next,
                backgroundColor: ColorsManager.primary400,
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}