import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_button.dart';
import 'package:mushtary/features/real_estate_details/ui/widgets/real_estate_peoperty_info.dart';

import '../../date/model/real_estate_details_model.dart'; // ✅ استورد الموديل

class RealEstateMoreDetails extends StatelessWidget {
  final RealEstateDetails? details;   // ⬅️ الداتا اللي هنستقبلها من الAPI
  final String city;
  final String region;

  const RealEstateMoreDetails({
    super.key,
    required this.details,
    required this.city,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    /// البيانات الأساسية نعرضها في الكارد الأولى
    final summaryData = {
      'رقم ترخيص الاعلان': details?.licenseNumber ?? 'غير متوفر',
      'نوع العقار': details?.realEstateType ?? 'غير محدد',
      'المنطقة': region,
      'المدينة': city,
      'غرض الاعلان': details?.purpose ?? 'غير محدد',
    };

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text('تفاصيل أكتر عن العقار',
                style: TextStyles.font16Dark300Grey400Weight),
          ),
          verticalSpace(16),
          Container(
            padding: EdgeInsets.all(8.w),
            width: 358.w,
            decoration: BoxDecoration(
              color: ColorsManager.dark50,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: RealEstatePropertyInfo(data: summaryData),
          ),
          verticalSpace(16),
          MyButton(
            label: 'عرض المزيد',
            onPressed: () {
              _showModalBottomSheet(context);
            },
            image: 'eye-black',
            backgroundColor: ColorsManager.dark50,
            height: 44.w,
            radius: 12.r,
          ),
        ],
      ),
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    final fullData = {
      'رقم ترخيص الاعلان': details?.licenseNumber ?? 'غير متوفر',
      'نوع العقار': details?.realEstateType ?? 'غير محدد',
      'الغرض': details?.purpose ?? 'غير محدد',
      'المساحة (م٢)': details?.areaM2.toString() ?? '-',
      'عدد الغرف': details?.roomCount.toString() ?? '-',
      'عدد الحمامات': details?.bathroomCount.toString() ?? '-',
      'عدد الصالات': details?.livingroomCount.toString() ?? '-',
      'عدد الطوابق': details?.floorCount.toString() ?? '-',
      'عدد الشوارع': details?.streetCount.toString() ?? '-',
      'عرض الشارع': details?.streetWidth.toString() ?? '-',
      'الواجهة': details?.facade ?? '-',
      'عمر المبنى': details?.buildingAge ?? '-',
      'مفروش': details?.isFurnished == true ? 'نعم' : 'لا',
      'الخدمات': (details?.services ?? []).join(', '),
    };

    showModalBottomSheet(
      constraints: BoxConstraints(
        maxHeight: 755.w,
        minHeight: 755.w,
      ),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: ColorsManager.white,
      elevation: 0,
      context: context,
      isDismissible: true,
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpace(32),
            Row(
              children: [
                const Spacer(),
                Text(
                  'تفاصيل أكتر عن العقار',
                  style: TextStyles.font18Black500Weight,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: ColorsManager.black),
                ),
              ],
            ),
            verticalSpace(24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                height: 550.w,
                child: SingleChildScrollView(
                  child: RealEstatePropertyInfo(data: fullData),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: MyButton(
                label: 'حفظ',
                onPressed: () => Navigator.pop(context),
                backgroundColor: ColorsManager.primaryColor,
                minWidth: double.infinity,
                height: 52.h,
                radius: 12.r,
                textColor: ColorsManager.white,
              ),
            ),
          ],
        );
      },
    );
  }
}