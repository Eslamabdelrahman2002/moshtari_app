import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_divider.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';

class RealEstateCitySelectorBottomSheetView extends StatefulWidget {
  const RealEstateCitySelectorBottomSheetView({
    super.key,
    required this.cities,
    required this.onSelectCity,
  });

  final List<String> cities;
  final void Function(String city) onSelectCity;

  @override
  State<RealEstateCitySelectorBottomSheetView> createState() =>
      _RealEstateCitySelectorBottomSheetViewState();
}

class _RealEstateCitySelectorBottomSheetViewState
    extends State<RealEstateCitySelectorBottomSheetView> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filteredCities = widget.cities
        .where((city) => city.contains(query))
        .toList();

    return Padding(
      padding: EdgeInsets.only(right: 16.w, top: 16.w, left: 16.w),
      child: Column(
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
          SecondaryTextFormField(
            hint: 'ابحث بأسم المدينة...',
            maxheight: 48.h,
            minHeight: 48.w,
            prefixIcon: 'search-normal',
            onChanged: (value) {
              setState(() => query = value);
            },
          ),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: filteredCities.length,
              scrollDirection: Axis.vertical,
              separatorBuilder: (context, index) => MyDivider(height: 4.w),
              itemBuilder: (context, index) {
                final city = filteredCities[index];
                return ListTile(
                  title: Text(city),
                  trailing: const MySvg(image: 'arrow-left'),
                  onTap: () => widget.onSelectCity(city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
