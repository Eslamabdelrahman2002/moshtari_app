import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';

class ElectronicsCitySlectorBottomSheetView extends StatefulWidget {
  const ElectronicsCitySlectorBottomSheetView({super.key});

  @override
  State<ElectronicsCitySlectorBottomSheetView> createState() =>
      _ElectronicsCitySlectorBottomSheetViewState();
}

class _ElectronicsCitySlectorBottomSheetViewState
    extends State<ElectronicsCitySlectorBottomSheetView> {
  List<String> cities = [
    "القاهرة",
    "الإسكندرية",
    "الرياض",
    "جدة",
    "دبي",
    "الدوحة",
  ];

  String searchValue = "";

  @override
  Widget build(BuildContext context) {
    final filteredCities = cities
        .where((city) =>
        city.toLowerCase().contains(searchValue.toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        right: 16.w,
        top: 16.w,
        left: 16.w,
      ),
      child: Column(
        children: [
          Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  Text('المدينة', style: TextStyles.font20Black500Weight),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('أختر المدينة', style: TextStyles.font14Dark500Weight),
                ],
              ),
              verticalSpace(24.h),
            ],
          ),
          SecondaryTextFormField(
            hint: 'ابحث بأسم المدينة...',
            maxheight: 48.h,
            minHeight: 48.w,
            prefixIcon: 'search-normal',
            onChanged: (value) {
              setState(() {
                searchValue = value;
              });
            },
          ),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: filteredCities.length,
              scrollDirection: Axis.vertical,
              separatorBuilder: (context, index) => MyDivider(
                height: 4.w,
              ),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredCities[index]),
                  trailing: const MySvg(image: 'arrow-left'),
                  onTap: () {
                    Navigator.pop(context, filteredCities[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
