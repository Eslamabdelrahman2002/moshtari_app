import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import '../../data/model/real_estate_filter_params.dart';

class RealEstateFilterSheet extends StatefulWidget {
  final RealEstateFilterParams initial;
  const RealEstateFilterSheet({super.key, required this.initial});

  @override
  State<RealEstateFilterSheet> createState() => _RealEstateFilterSheetState();
}

class _RealEstateFilterSheetState extends State<RealEstateFilterSheet> {
  // السعر (K للعرض فقط)
  double minK = 0, maxK = 1000;

  // المساحة (m2)
  double areaMin = 0, areaMax = 2000;

  // الغرض
  String purpose = 'all'; // all | sell | rent

  // غرف/حمامات
  int rooms = 0;       // 0 = الكل
  int bathrooms = 0;   // 0 = الكل

  // ترتيب
  String sort = 'latest';

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i.priceMin != null) minK = (i.priceMin! / 1000).clamp(0, 1000);
    if (i.priceMax != null) maxK = (i.priceMax! / 1000).clamp(0, 1000);
    if (i.areaMin != null) areaMin = (i.areaMin!).toDouble();
    if (i.areaMax != null) areaMax = (i.areaMax!).toDouble();
    purpose = i.purpose ?? 'all';
    rooms = i.roomsMin ?? 0;
    bathrooms = i.bathroomsMin ?? 0;
    sort = i.sort ?? 'latest';
  }

  Widget chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: ColorsManager.primary50,
      labelStyle: selected ? TextStyles.font14Blue500Weight : TextStyles.font14Black500Weight,
      backgroundColor: Colors.white,
      side: BorderSide(color: selected ? ColorsManager.primary400 : ColorsManager.dark200),
    );
  }

  void _clearAll() {
    setState(() {
      minK = 0; maxK = 1000;
      areaMin = 0; areaMax = 2000;
      purpose = 'all';
      rooms = 0; bathrooms = 0;
      sort = 'latest';
    });
  }

  void _apply() {
    final f = RealEstateFilterParams(
      priceMin: minK > 0 ? minK * 1000 : null,
      priceMax: maxK < 1000 ? maxK * 1000 : null,
      areaMin: areaMin > 0 ? areaMin.toInt() : null,
      areaMax: areaMax < 2000 ? areaMax.toInt() : null,
      purpose: purpose == 'all' ? null : purpose,
      roomsMin: rooms > 0 ? rooms : null,
      bathroomsMin: bathrooms > 0 ? bathrooms : null,
      sort: sort,
      cityId: widget.initial.cityId,
      areaId: widget.initial.areaId,
      realEstateType: widget.initial.realEstateType,
      page: 1,
      perPage: widget.initial.perPage,
    );
    Navigator.of(context).pop<RealEstateFilterParams>(f);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [

                const Spacer(),
                Text('تصفية العقارات', style: TextStyles.font20Black500Weight),
                const Spacer(),
                TextButton(onPressed: _clearAll, child: const Text('حذف الكل', style: TextStyle(color: Colors.red))),
                const SizedBox(width: 20),
              ],
            ),
            verticalSpace(12),

            // السعر
            Text('السعر', style: TextStyles.font16Dark400Weight),
            RangeSlider(
              values: RangeValues(minK, maxK),
              min: 0, max: 1000,
              onChanged: (v) => setState(() { minK = v.start; maxK = v.end; }),
              activeColor: ColorsManager.primaryColor,
              inactiveColor: ColorsManager.sliderInactiveColor,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${minK.round()}k', style: TextStyles.font14Blue500Weight),
                  Text('${maxK.round()}k', style: TextStyles.font14Blue500Weight),
                ],
              ),
            ),
            verticalSpace(12),

            // المساحة
            Text('المساحة (م²)', style: TextStyles.font16Dark400Weight),
            RangeSlider(
              values: RangeValues(areaMin, areaMax),
              min: 0, max: 2000,
              divisions: 40,
              onChanged: (v) => setState(() { areaMin = v.start; areaMax = v.end; }),
              activeColor: ColorsManager.primaryColor,
              inactiveColor: ColorsManager.sliderInactiveColor,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${areaMin.round()} م²', style: TextStyles.font14Blue500Weight),
                  Text('${areaMax.round()} م²', style: TextStyles.font14Blue500Weight),
                ],
              ),
            ),
            verticalSpace(12),

            // الغرض
            Text('الغرض', style: TextStyles.font16Dark400Weight),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                chip('الكل', purpose == 'all', () => setState(()=> purpose = 'all')),
                chip('بيع', purpose == 'sell', () => setState(()=> purpose = 'sell')),
                chip('إيجار', purpose == 'rent', () => setState(()=> purpose = 'rent')),
              ],
            ),
            verticalSpace(12),

            // غرف
            Text('عدد الغرف (حد أدنى)', style: TextStyles.font16Dark400Weight),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [0,1,2,3,4].map((v) {
                final sel = rooms == v;
                return chip(v == 0 ? 'الكل' : (v == 4 ? '4+' : '$v'),
                    sel, () => setState(()=> rooms = v));
              }).toList(),
            ),
            verticalSpace(12),

            // حمامات
            Text('عدد الحمامات (حد أدنى)', style: TextStyles.font16Dark400Weight),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [0,1,2,3,4].map((v) {
                final sel = bathrooms == v;
                return chip(v == 0 ? 'الكل' : (v == 4 ? '4+' : '$v'),
                    sel, () => setState(()=> bathrooms = v));
              }).toList(),
            ),
            verticalSpace(12),

            // ترتيب
            Text('الترتيب', style: TextStyles.font16Dark400Weight),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                chip('الأحدث', sort == 'latest', () => setState(()=> sort = 'latest')),
                chip('السعر ↑', sort == 'price_asc', () => setState(()=> sort = 'price_asc')),
                chip('السعر ↓', sort == 'price_desc', () => setState(()=> sort = 'price_desc')),
              ],
            ),
            verticalSpace(16),

            Row(
              children: [
                Expanded(child: PrimaryButton(text: 'تطبيق الفلتر', onPressed: _apply)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}