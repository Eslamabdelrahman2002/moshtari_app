import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/location/data/model/location_models.dart';
import 'package:mushtary/core/location/logic/cubit/location_cubit.dart';
import 'package:mushtary/core/location/logic/cubit/location_state.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/real_estate_mappers.dart';
import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';
import 'package:mushtary/features/create_ad/ui/widgets/detail_selector.dart';
import 'package:mushtary/features/create_ad/ui/widgets/next_button_bar.dart';
import 'package:mushtary/features/create_ad/ui/widgets/secondary_text_form_field_has_value.dart';

import '../cubit/real_estate_requests_cubit.dart';
import '../cubit/real_estate_requests_state.dart';

class RealEstateMappersOptionItem {
  final String label;
  final IconData icon;
  const RealEstateMappersOptionItem(this.label, this.icon);
}

class RealEstateRequestDetailsScreen extends StatefulWidget {
  final VoidCallback? onNext;
  const RealEstateRequestDetailsScreen({super.key, this.onNext});

  @override
  State<RealEstateRequestDetailsScreen> createState() =>
      _RealEstateRequestDetailsScreenState();
}

class _RealEstateRequestDetailsScreenState
    extends State<RealEstateRequestDetailsScreen> {
  bool isForSell = false; // افتراض إيجار
  String? selectedType; // نوع العقار (شقة، فيلا...)
  Region? selectedRegion;
  City? selectedCity;

  @override
  void initState() {
    super.initState();
    // ✅ افتراضي setRequestType = 'rent' (إيجار)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final requestsCubit = context.read<RealEstateRequestsCubit>();
      requestsCubit.setRequestType('rent'); // افتراضي
      print('>>> [Details] Default requestType set to: rent'); // Debug
    });
  }

  @override
  Widget build(BuildContext context) {
    final requestsCubit = context.read<RealEstateRequestsCubit>();

    // بيانات "نوع العقار" (افتراضية هنا)
    final propertyTypes = const [
      RealEstateMappersOptionItem('شقة', Icons.apartment_rounded),
      RealEstateMappersOptionItem('فيلا', Icons.villa_rounded),
      RealEstateMappersOptionItem('أرض', Icons.map_rounded),
      RealEstateMappersOptionItem('محل', Icons.store_rounded),
    ];

    return BlocProvider<LocationCubit>(
      create: (_) => getIt<LocationCubit>()..loadRegions(),
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: BlocBuilder<RealEstateRequestsCubit, RealEstateRequestsState>(
              builder: (context, state) {
                print('>>> [Details] Build - Selected: Type=$selectedType, Region=${selectedRegion?.nameAr}, City=${selectedCity?.nameAr}'); // Debug
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpace(12),

                    // نوع الطلب (بيع/إيجار)
                    Text('غرض الطلب', style: TextStyles.font16DarkGrey500Weight),
                    verticalSpace(8),
                    Row(
                      children: [
                        // ✅ زر الإيجار
                        Expanded(
                          child: CustomizedChip(
                            title: 'إيجار',
                            isSelected: !isForSell,
                            onTap: () {
                              setState(() => isForSell = false);
                              requestsCubit.setRequestType('rent'); // ✅ مطابق للـ API
                              print('>>> [Details] Rent selected');
                            },
                          ),
                        ),

                        horizontalSpace(12),

                        // ✅ زر الشراء
                        Expanded(
                          child: CustomizedChip(
                            title: 'شراء',
                            isSelected: isForSell,
                            onTap: () {
                              setState(() => isForSell = true);
                              requestsCubit.setRequestType('buy'); // ✅ مطابق للـ API
                              print('>>> [Details] Buy selected');
                            },
                          ),
                        ),
                      ],
                    ),

                    verticalSpace(16),

                    // نوع العقار
                    _buildTypeSelector(context, requestsCubit, propertyTypes),
                    verticalSpace(12),

                    // المنطقة
                    _buildRegionSelector(context, requestsCubit),
                    verticalSpace(12),

                    // المدينة
                    _buildCitySelector(context, requestsCubit),

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
                ? () {
              print('>>> [Details] Next pressed!'); // Debug
              widget.onNext?.call();
            }
                : null,
            title: 'التالي',
          ),
        ),
      ),
    );
  }

  // ✅ Dialogs كاملة (مُكمّلة من الرد السابق)
  Future<String?> _openSingleSelectDialog({
    required BuildContext context,
    required String title,
    required String hint,
    required List<RealEstateMappersOptionItem> items,
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
          final filtered = items
              .where((e) => e.label.toLowerCase().contains(query.toLowerCase()))
              .toList();
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
                          onTap: () {
                            print('>>> [Dialog] Selected: ${it.label}'); // Debug
                            Navigator.pop(ctx, it.label);
                          },
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
            final filtered = s.regions
                .where((e) => e.nameAr.toLowerCase().contains(query.toLowerCase()))
                .toList();

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
                            onTap: () {
                              print('>>> [Region Dialog] Selected: ${it.nameAr}'); // Debug
                              Future.microtask(() => Navigator.pop(ctx, it));
                            },
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
            final filtered = s.cities
                .where((e) => e.nameAr.toLowerCase().contains(query.toLowerCase()))
                .toList();

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
                            onTap: () {
                              print('>>> [City Dialog] Selected: ${it.nameAr}'); // Debug
                              Future.microtask(() => Navigator.pop(ctx, it));
                            },
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

  // Selectors (مُحدّثة لاستخدام Dialogs الكاملة)
  Widget _buildTypeSelector(BuildContext context, RealEstateRequestsCubit cubit, List<RealEstateMappersOptionItem> items) {
    return DetailSelector(
      title: '',
      widget: selectedType == null
          ? InkWell(
        onTap: () async {
          print('>>> [Type Selector] Tapped'); // Debug
          final res = await _openSingleSelectDialog(
            context: context,
            title: 'التصنيف',
            hint: 'ابحث عن التصنيف...',
            items: items,
            selected: selectedType,
          );
          if (res != null) {
            setState(() => selectedType = res);
            cubit.setRealEstateType(RealEstateMappers.type(res));
            print('>>> [Type] Set: $res'); // Debug
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
          cubit.setRealEstateType(null);
          print('>>> [Type] Cleared'); // Debug
        },
      ),
    );
  }

  Widget _buildRegionSelector(BuildContext context, RealEstateRequestsCubit cubit) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, locState) {
        final isLoading = locState.regionsLoading;
        print('>>> [Region] Loading: $isLoading, Regions count: ${locState.regions.length}'); // Debug
        return DetailSelector(
          title: '',
          widget: selectedRegion == null
              ? InkWell(
            onTap: isLoading
                ? null
                : () async {
              print('>>> [Region Selector] Tapped'); // Debug
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
                cubit.setRegionId(res.id); // غيّر إلى setRegionId إذا كان موجود
                cubit.setCityId(null); // ✅ clear City ID
                print('>>> [Region] Set: ${res.nameAr} (ID: ${res.id})'); // Debug
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
              cubit.setRegionId(null);
              cubit.setCityId(null); // ✅ clear City ID
              print('>>> [Region] Cleared'); // Debug
            },
          ),
        );
      },
    );
  }

  Widget _buildCitySelector(BuildContext context, RealEstateRequestsCubit cubit) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, locState) {
        final citiesLoading = locState.citiesLoading;
        final cannotPickCity = selectedRegion == null;
        print('>>> [City] Loading: $citiesLoading, Can pick: ${!cannotPickCity}, Cities count: ${locState.cities.length}'); // Debug
        return DetailSelector(
          title: '',
          widget: selectedCity == null
              ? InkWell(
            onTap: cannotPickCity
                ? null
                : () async {
              print('>>> [City Selector] Tapped'); // Debug
              FocusScope.of(context).unfocus();
              await context.read<LocationCubit>().loadCities(selectedRegion!.id);

              if (context.read<LocationCubit>().state.cities.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لا توجد مدن متاحة للمنطقة المحددة')),
                );
                return;
              }

              final res = await _openCityDialog(context, selectedRegion!);
              if (res != null) {
                setState(() => selectedCity = res);
                cubit.setCityId(res.id);
                print('>>> [City] Set: ${res.nameAr} (ID: ${res.id})'); // Debug
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
              cubit.setCityId(null);
              print('>>> [City] Cleared'); // Debug
            },
          ),
        );
      },
    );
  }
}