// lib/features/services/ui/widgets/city_picker_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

import 'package:mushtary/core/location/data/model/location_models.dart';
import 'package:mushtary/core/location/logic/cubit/location_cubit.dart';
import 'package:mushtary/core/location/logic/cubit/location_state.dart';

class CitySelection {
  final Region region;
  final City city;
  const CitySelection({required this.region, required this.city});
}

class CityPickerSheet extends StatefulWidget {
  final String title;
  final Region? initialRegion;
  final City? initialCity;

  const CityPickerSheet({
    super.key,
    this.title = 'اختيار المدينة',
    this.initialRegion,
    this.initialCity,
  });

  static Future<CitySelection?> show(
      BuildContext context, {
        String title = 'اختيار المدينة',
        Region? initialRegion,
        City? initialCity,
      }) {
    return showModalBottomSheet<CitySelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => getIt<LocationCubit>()..loadRegions(),
        child: CityPickerSheet(
          title: title,
          initialRegion: initialRegion,
          initialCity: initialCity,
        ),
      ),
    );
  }

  @override
  State<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<CityPickerSheet> {
  Region? _region;
  City? _city;

  @override
  void initState() {
    super.initState();
    _region = widget.initialRegion;
    _city = widget.initialCity;
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyles.font14DarkGray400Weight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: ColorsManager.grey200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: ColorsManager.grey200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: ColorsManager.primaryColor),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    filled: true,
    fillColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    final pad = EdgeInsets.only(
      left: 16.w,
      right: 16.w,
      top: 12.h,
      bottom: MediaQuery.of(context).viewInsets.bottom + 12.h,
    );

    return BlocConsumer<LocationCubit, LocationState>(
      listenWhen: (p, c) => p.regionsLoading != c.regionsLoading || p.citiesLoading != c.citiesLoading,
      listener: (context, state) async {
        // أول مرة نحمّل المدن لو فيه قيمة ابتدائية للمنطقة
        if (_region != null && state.cities.isEmpty && !state.citiesLoading) {
          context.read<LocationCubit>().loadCities(_region!.id);
        }
      },
      builder: (context, state) {
        final cubit = context.read<LocationCubit>();

        return Padding(
          padding: pad,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // شريط علوي
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyles.font18Black500Weight,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    splashRadius: 22,
                  ),
                ],
              ),
              verticalSpace(8),

              // المنطقة
              Align(
                alignment: Alignment.centerRight,
                child: Text('المنطقة', style: TextStyles.font16Dark500400Weight),
              ),
              verticalSpace(8),
              state.regionsLoading
                  ? const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator.adaptive(),
              ))
                  : DropdownButtonFormField<Region>(
                value: _region,
                items: state.regions
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.nameAr, style: TextStyles.font16Black500Weight)))
                    .toList(),
                onChanged: (r) {
                  setState(() {
                    _region = r;
                    _city = null;
                  });
                  if (r != null) cubit.loadCities(r.id);
                },
                decoration: _dec('اختر المنطقة'),
                validator: (v) => v == null ? 'الرجاء اختيار المنطقة' : null,
              ),

              if (state.regionsError != null) ...[
                verticalSpace(6),
                Align(alignment: Alignment.centerRight, child: Text(state.regionsError!, style: TextStyles.font14Red500Weight)),
              ],

              verticalSpace(16),

              // المدينة
              Align(
                alignment: Alignment.centerRight,
                child: Text('المدينة', style: TextStyles.font16Dark500400Weight),
              ),
              verticalSpace(8),
              state.citiesLoading
                  ? const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator.adaptive(),
              ))
                  : DropdownButtonFormField<City>(
                value: _city,
                items: state.cities
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.nameAr, style: TextStyles.font16Black500Weight)))
                    .toList(),
                onChanged: (c) => setState(() => _city = c),
                decoration: _dec('اختر المدينة'),
                validator: (v) => v == null ? 'الرجاء اختيار المدينة' : null,
              ),

              if (state.citiesError != null) ...[
                verticalSpace(6),
                Align(alignment: Alignment.centerRight, child: Text(state.citiesError!, style: TextStyles.font14Red500Weight)),
              ],

              verticalSpace(20),

              // الأزرار
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, null),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: ColorsManager.grey200),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('رجوع', style: TextStyles.font16Dark500400Weight),
                    ),
                  ),
                  horizontalSpace(12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_region != null && _city != null)
                          ? () => Navigator.pop(context, CitySelection(region: _region!, city: _city!))
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primaryColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('تأكيد الاختيار', style: TextStyles.font16White500Weight),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}