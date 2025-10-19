import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/location/data/model/location_models.dart';
import 'package:mushtary/core/location/logic/cubit/location_cubit.dart';
import 'package:mushtary/core/location/logic/cubit/location_state.dart';

Future<City?> showCitySelectorDialog(BuildContext context) {
  return showModalBottomSheet<City>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return BlocProvider<LocationCubit>(
        create: (_) {
          final c = getIt<LocationCubit>();
          c.loadRegions();
          return c;
        },
        child: _CitySelectorBody(),
      );
    },
  );
}

class _CitySelectorBody extends StatefulWidget {
  @override
  State<_CitySelectorBody> createState() => _CitySelectorBodyState();
}

class _CitySelectorBodyState extends State<_CitySelectorBody> {
  Region? _region;
  City? _city;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        child: BlocBuilder<LocationCubit, LocationState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 44.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(100))),
                SizedBox(height: 12.h),
                Text('اختر المدينة', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 16.h),

                DropdownButtonFormField<Region>(
                  value: _region,
                  isExpanded: true,
                  items: state.regions.map((r) => DropdownMenuItem(value: r, child: Text(r.nameAr))).toList(),
                  onChanged: state.regionsLoading
                      ? null
                      : (r) {
                    setState(() { _region = r; _city = null; });
                    if (r != null) context.read<LocationCubit>().loadCities(r.id);
                  },
                  decoration: InputDecoration(
                    labelText: 'المنطقة',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 12.h),

                DropdownButtonFormField<City>(
                  value: _city,
                  isExpanded: true,
                  items: state.cities.map((c) => DropdownMenuItem(value: c, child: Text(c.nameAr))).toList(),
                  onChanged: (_region == null || state.citiesLoading) ? null : (c) => setState(() => _city = c),
                  decoration: InputDecoration(
                    labelText: 'المدينة',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop<City>(null),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _city == null ? null : () => Navigator.of(context).pop<City>(_city),
                        child: const Text('اختيار'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}