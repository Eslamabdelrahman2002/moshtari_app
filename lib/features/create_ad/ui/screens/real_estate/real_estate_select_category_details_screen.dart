import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/real_estate_mappers.dart';
import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';
import 'package:mushtary/features/create_ad/ui/widgets/detail_selector.dart';
import 'package:mushtary/features/create_ad/ui/widgets/next_button_bar.dart';
import 'package:mushtary/features/create_ad/ui/widgets/secondary_text_form_field_has_value.dart';

// Location
import 'package:mushtary/core/location/logic/cubit/location_cubit.dart';
import 'package:mushtary/core/location/logic/cubit/location_state.dart';
import 'package:mushtary/core/location/data/model/location_models.dart';

// Real estate Ads
import 'logic/cubit/real_estate_ads_cubit.dart';
import 'logic/cubit/real_estate_ads_state.dart';

class RealEstateSelectCategoryDetailsScreen extends StatefulWidget {
  final VoidCallback? onNext;
  const RealEstateSelectCategoryDetailsScreen({super.key, this.onNext});

  @override
  State<RealEstateSelectCategoryDetailsScreen> createState() =>
      _RealEstateSelectCategoryDetailsScreenState();
}

class _RealEstateSelectCategoryDetailsScreenState
    extends State<RealEstateSelectCategoryDetailsScreen> {
  bool isForSell = true;

  String? selectedType; // نوع العقار
  Region? selectedRegion; // المنطقة (كيان)
  City? selectedCity; // المدينة (كيان)

  // فلاغات لتطبيق الـ prefill مرة واحدة فقط
  bool _appliedRegionPrefill = false;
  bool _appliedCityPrefill = false;

  @override
  void initState() {
    super.initState();
    // تهيئة قيم أولية من الكيوبت (وضع التعديل)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<RealEstateAdsCubit>().state;
      if (s.purpose != null) {
        setState(() => isForSell = RealEstateMappers.purposeToIsForSell(s.purpose));
      }
      if (s.realEstateType != null) {
        setState(() => selectedType = RealEstateMappers.typeToLabel(s.realEstateType!));
      }
    });
  }

  void _maybePrefill(LocationState locState) {
    final adsCubit = context.read<RealEstateAdsCubit>();

    // Prefill للمنطقة بالاسم بعد تحميل المناطق
    if (!_appliedRegionPrefill) {
      final preRegionName = adsCubit.state.preselectedRegionName;
      if (preRegionName != null &&
          preRegionName.trim().isNotEmpty &&
          !locState.regionsLoading &&
          locState.regions.isNotEmpty &&
          selectedRegion == null) {
        Region? match;
        for (final r in locState.regions) {
          if (r.nameAr.trim() == preRegionName.trim()) {
            match = r;
            break;
          }
        }
        if (match != null) {
          setState(() {
            selectedRegion = match;
            selectedCity = null;
          });
          adsCubit.setRegionId(match.id);
          // حمّل مدن المنطقة المختارة
          context.read<LocationCubit>().loadCities(match.id);
        }
        _appliedRegionPrefill = true;
      }
    }

    // Prefill للمدينة بالاسم بعد تحميل مدن المنطقة
    if (!_appliedCityPrefill) {
      final preCityName = adsCubit.state.preselectedCityName;
      if (preCityName != null &&
          preCityName.trim().isNotEmpty &&
          selectedRegion != null &&
          !locState.citiesLoading &&
          locState.cities.isNotEmpty &&
          selectedCity == null) {
        City? match;
        for (final c in locState.cities) {
          if (c.nameAr.trim() == preCityName.trim()) {
            match = c;
            break;
          }
        }
        if (match != null) {
          setState(() => selectedCity = match);
          adsCubit.setCityId(match.id);
        }
        _appliedCityPrefill = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adsCubit = context.read<RealEstateAdsCubit>();

    final propertyTypes = <_OptionItem>[
      _OptionItem('شقة', Icons.apartment_rounded),
      _OptionItem('فيلا', Icons.villa_rounded),
      _OptionItem('أرض سكنية', Icons.map_rounded),
      _OptionItem('أراضي', Icons.terrain_rounded),
      _OptionItem('شقق و غرف', Icons.meeting_room_rounded),
      _OptionItem('فلل وقصور', Icons.holiday_village_rounded),
      _OptionItem('دور', Icons.home_work_rounded),
      _OptionItem('عمائر و أبراج', Icons.apartment_rounded),
      _OptionItem('شاليهات و استراحات', Icons.cabin_rounded),
    ];

    return BlocProvider<LocationCubit>(
      create: (_) => getIt<LocationCubit>()..loadRegions(),
      child: BlocListener<LocationCubit, LocationState>(
        listener: (context, locState) {
          // نفّذ الـ prefill بعد انتهاء البناء
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _maybePrefill(locState);
          });
        },
        child: Scaffold(
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: BlocBuilder<RealEstateAdsCubit, RealEstateAdsState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalSpace(12),

                      // نوع الطلب (بيع/إيجار)
                      Text('نوع الطلب', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      verticalSpace(8),
                      Row(
                        children: [
                          Expanded(
                            child: CustomizedChip(
                              title: 'إيجار',
                              isSelected: !isForSell,
                              onTap: () {
                                setState(() => isForSell = false);
                                adsCubit.setPurpose(false);
                              },
                            ),
                          ),
                          horizontalSpace(12),
                          Expanded(
                            child: CustomizedChip(
                              title: 'بيع',
                              isSelected: isForSell,
                              onTap: () {
                                setState(() => isForSell = true);
                                adsCubit.setPurpose(true);
                              },
                            ),
                          ),
                        ],
                      ),
                      verticalSpace(16),

                      // نوع العقار
                      DetailSelector(
                        title: '',
                        widget: selectedType == null
                            ? InkWell(
                          onTap: () async {
                            final res = await _openSingleSelectDialog(
                              context: context,
                              title: 'التصنيف',
                              hint: 'ابحث عن التصنيف...',
                              items: propertyTypes,
                              selected: selectedType,
                            );
                            if (res != null) {
                              setState(() => selectedType = res);
                              adsCubit.setRealEstateType(RealEstateMappers.type(res));
                            }
                          },
                          child: SecondaryTextFormField(
                            label: 'نوع العقار',
                            hint: 'اختر نوع العقار',
                            maxheight: 56.h,
                            minHeight: 56.h,
                            suffexIcon: 'arrow-left',
                            isEnabled: false,
                          ),
                        )
                            : SecondaryTextFormFieldHasValue(
                          title: selectedType!,
                          onTap: () {
                            setState(() => selectedType = null);
                            adsCubit.setRealEstateType(null);
                          },
                        ),
                      ),
                      verticalSpace(12),

                      // المنطقة
                      BlocBuilder<LocationCubit, LocationState>(
                        builder: (context, locState) {
                          final isLoading = locState.regionsLoading;
                          return DetailSelector(
                            title: '',
                            widget: selectedRegion == null
                                ? InkWell(
                              onTap: isLoading
                                  ? null
                                  : () async {
                                FocusScope.of(context).unfocus();
                                if (locState.regions.isEmpty && !locState.regionsLoading) {
                                  await context.read<LocationCubit>().loadRegions();
                                }
                                final res = await _openRegionDialog(context);
                                if (res != null) {
                                  setState(() {
                                    selectedRegion = res;
                                    selectedCity = null;
                                  });
                                  adsCubit.setRegionId(res.id);
                                }
                              },
                              child: SecondaryTextFormField(
                                label: 'المنطقة',
                                hint: isLoading ? 'جاري تحميل المناطق...' : 'اختر المنطقة',
                                maxheight: 56.h,
                                minHeight: 56.h,
                                suffexIcon: 'arrow-left',
                                isEnabled: false,
                              ),
                            )
                                : SecondaryTextFormFieldHasValue(
                              title: selectedRegion!.nameAr,
                              onTap: () {
                                setState(() {
                                  selectedRegion = null;
                                  selectedCity = null;
                                });
                                adsCubit.setRegionId(null);
                                adsCubit.setCityId(null);
                              },
                            ),
                          );
                        },
                      ),
                      verticalSpace(12),

                      // المدينة
                      BlocBuilder<LocationCubit, LocationState>(
                        builder: (context, locState) {
                          final citiesLoading = locState.citiesLoading;
                          final cannotPickCity = selectedRegion == null;

                          return DetailSelector(
                            title: '',
                            widget: selectedCity == null
                                ? InkWell(
                              onTap: cannotPickCity
                                  ? null
                                  : () async {
                                FocusScope.of(context).unfocus();

                                // فحص آمن قبل الوصول إلى id
                                final regionId = selectedRegion?.id;
                                if (regionId == null) return;

                                await context.read<LocationCubit>().loadCities(regionId);

                                if (context.read<LocationCubit>().state.cities.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('لا توجد مدن متاحة للمنطقة المحددة')),
                                  );
                                  return;
                                }

                                final res = await _openCityDialog(context, selectedRegion!);
                                if (res != null) {
                                  setState(() => selectedCity = res);
                                  adsCubit.setCityId(res.id);
                                }
                              },
                              child: SecondaryTextFormField(
                                label: 'المدينة',
                                hint: cannotPickCity
                                    ? 'اختر المنطقة أولًا'
                                    : (citiesLoading ? 'جاري تحميل المدن...' : 'اختر المدينة'),
                                maxheight: 56.h,
                                minHeight: 56.h,
                                suffexIcon: 'arrow-left',
                                isEnabled: false,
                              ),
                            )
                                : SecondaryTextFormFieldHasValue(
                              title: selectedCity!.nameAr,
                              onTap: () {
                                setState(() => selectedCity = null);
                                adsCubit.setCityId(null);
                              },
                            ),
                          );
                        },
                      ),

                      verticalSpace(16),
                    ],
                  );
                },
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16),
            child: NextButtonBar(
              onPressed: (selectedType != null && selectedRegion != null && selectedCity != null)
                  ? widget.onNext
                  : null,
              title: 'التالي',
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Dialogs ----------------

  Future<String?> _openSingleSelectDialog({
    required BuildContext context,
    required String title,
    required String hint,
    required List<_OptionItem> items,
    String? selected,
  }) async {
    String query = '';
    return showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          final filtered =
          items.where((e) => e.label.toLowerCase().contains(query.toLowerCase())).toList();
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  16.w, 12.h, 16.w, 16.h + MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      const SizedBox(width: 8),
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    decoration: InputDecoration(
                      hintText: hint,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                      ),
                    ),
                    onChanged: (q) => setSheet(() => query = q.trim()),
                  ),
                  SizedBox(height: 10.h),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final it = filtered[i];
                        final sel = it.label == selected;
                        return ListTile(
                          onTap: () => Navigator.pop(ctx, it.label),
                          leading: Icon(it.icon, color: const Color(0xFF0A45A6)),
                          title: Text(
                            it.label,
                            style: TextStyle(
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                              color: sel ? const Color(0xFF0A45A6) : Colors.black87,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_left_rounded),
                          dense: true,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<Region?> _openRegionDialog(BuildContext context) async {
    final locCubit = context.read<LocationCubit>();
    String query = '';

    return showModalBottomSheet<Region>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: locCubit,
          child: StatefulBuilder(builder: (ctx, setSheet) {
            final s = locCubit.state;
            if (s.regionsLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            }
            final filtered =
            s.regions.where((e) => e.nameAr.toLowerCase().contains(query.toLowerCase())).toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    16.w, 12.h, 16.w, 16.h + MediaQuery.of(ctx).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                        const SizedBox(width: 8),
                        const Text('اختر المنطقة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const Spacer(),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث باسم المنطقة...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                        ),
                      ),
                      onChanged: (q) => setSheet(() => query = q.trim()),
                    ),
                    SizedBox(height: 10.h),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final it = filtered[i];
                          return ListTile(
                            onTap: () => Future.microtask(() => Navigator.pop(ctx, it)),
                            title: Text(it.nameAr),
                            trailing: const Icon(Icons.chevron_left_rounded),
                            dense: true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Future<City?> _openCityDialog(BuildContext context, Region region) async {
    final locCubit = context.read<LocationCubit>();
    String query = '';

    return showModalBottomSheet<City>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: locCubit,
          child: StatefulBuilder(builder: (ctx, setSheet) {
            final s = locCubit.state;
            if (s.citiesLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            }
            final filtered =
            s.cities.where((e) => e.nameAr.toLowerCase().contains(query.toLowerCase())).toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    16.w, 12.h, 16.w, 16.h + MediaQuery.of(ctx).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                        const SizedBox(width: 8),
                        Text('اختر المدينة في ${region.nameAr}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const Spacer(),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث باسم المدينة...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                        ),
                      ),
                      onChanged: (q) => setSheet(() => query = q.trim()),
                    ),
                    SizedBox(height: 10.h),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final it = filtered[i];
                          return ListTile(
                            onTap: () => Future.microtask(() => Navigator.pop(ctx, it)),
                            title: Text(it.nameAr),
                            trailing: const Icon(Icons.chevron_left_rounded),
                            dense: true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _OptionItem {
  final String label;
  final IconData icon;
  _OptionItem(this.label, this.icon);
}