import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/features/create_ad/ui/screens/car_parts/two_step_header.dart';
import 'package:mushtary/core/router/routes.dart';

// DI + Cubits
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/location/logic/cubit/location_cubit.dart';
import 'package:mushtary/core/location/logic/cubit/location_state.dart';

// Models (Locations/Car Catalog)
import 'package:mushtary/core/location/data/model/location_models.dart';
import 'package:mushtary/core/car/data/model/car_type.dart';
import 'package:mushtary/core/car/logic/cubit/car_catalog_cubit.dart';
import 'package:mushtary/core/car/logic/cubit/car_catalog_state.dart';


import '../../../../../core/widgets/primary/confirmation_dialog.dart';
import '../../../../../core/widgets/primary/custom_app_bar.dart';
import 'car_part_create_ad_step2_screen.dart';
import 'logic/cubit/car_part_ads_cubit.dart';

class CarPartCreateAdStep1Screen extends StatefulWidget {
  const CarPartCreateAdStep1Screen({super.key});

  @override
  State<CarPartCreateAdStep1Screen> createState() => _CarPartCreateAdStep1ScreenState();
}

class _CarPartCreateAdStep1ScreenState extends State<CarPartCreateAdStep1Screen> {
  final _partNameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  int? _brandId;
  String? _brandName;
  final List<String> _selectedModels = [];

  Region? _selectedRegion;
  City? _selectedCity;

  String _condition = 'used'; // new | used

  @override
  void dispose() {
    _partNameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Widget _pickerField({
    required String label,
    required String hint,
    required VoidCallback onTap,
    String? value,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: ColorsManager.dark200, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyles.font12DarkGray400Weight),
                  SizedBox(height: 2.h),
                  Text(
                    (value != null && value.isNotEmpty) ? value : hint,
                    overflow: TextOverflow.ellipsis,
                    style: (value != null && value.isNotEmpty)
                        ? TextStyles.font14Black500Weight
                        : TextStyles.font14DarkGray400Weight,
                  ),
                ],
              ),
            ),
            MySvg(image: 'arrow-left', width: 18.w, height: 18.h, color: ColorsManager.darkGray),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: ColorsManager.dark200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: ColorsManager.primary300),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarPartAdsCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CarCatalogCubit>()..loadBrands(autoSelectFirst: false)),
        BlocProvider(create: (_) => getIt<LocationCubit>()..loadRegions()),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: CustomAppBar(
        //   title: "إنشاء إعلان قطع غيار",
        //   onBackPressed: () async {
        //     // إضافة dialog للتأكيد من الخروج
        //     final shouldExit = await ConfirmationDialog.show(
        //       context: context,
        //       title: "تأكيد الخروج",
        //       message: "هل أنت متأكد من الخروج؟ سيتم فقدان البيانات المدخلة.",
        //       confirmText: "خروج",
        //       cancelText: "البقاء",
        //       confirmColor: Colors.red,
        //       icon: Icons.warning_amber_rounded,
        //     );
        //
        //     if (shouldExit == true && context.mounted) {
        //       Navigator.pop(context);
        //     }
        //   },
        // ),
        body: SafeArea(
          child: Column(
            children: [
              // AppBar بسيط
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: MySvg(image: "arrow-right", color: ColorsManager.black),
                    ),
                    SizedBox(width: 8.w),
                    Text("إنشاء إعلان", style: TextStyles.font16Black500Weight),
                  ],
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    verticalSpace(12),
                    const TwoStepHeader(currentStep: 0),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalSpace(12),

                      _textField(
                        label: 'نوع القطعة',
                        hint: 'ادخل نوع القطعة',
                        controller: _partNameCtrl,
                        onChanged: cubit.setPartName,
                      ),
                      verticalSpace(12),

                      _segment(
                        title: 'الحالة',
                        items: const ['new', 'used'],
                        labels: const {'new': 'جديد', 'used': 'مستعمل'},
                        value: _condition,
                        onSelect: (v) {
                          setState(() => _condition = v);
                          cubit.setCondition(v);
                        },
                      ),
                      verticalSpace(12),

                      // ماركة السيارة
                      BlocBuilder<CarCatalogCubit, CarCatalogState>(
                        builder: (context, catState) {
                          return _pickerField(
                            label: 'ماركة السيارة',
                            hint: catState.brandsLoading ? 'جاري التحميل...' : 'حدد الماركة',
                            value: _brandName,
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              if (catState.brandsLoading) return;
                              if (catState.brands.isEmpty) {
                                await context.read<CarCatalogCubit>().loadBrands(autoSelectFirst: false);
                              }

                              final res = await _openCarBrandDialog(context);
                              if (res != null) {
                                setState(() {
                                  _brandId = res.id;
                                  _brandName = res.name;
                                  _selectedModels.clear();
                                });
                                cubit.setBrandId(_brandId);
                                await context.read<CarCatalogCubit>().loadModels(res.id);
                              }
                            },
                          );
                        },
                      ),
                      verticalSpace(12),

                      // الموديلات المدعومة
                      BlocBuilder<CarCatalogCubit, CarCatalogState>(
                        builder: (context, catState) {
                          final carModels = catState.models;
                          final modelsLoading = catState.modelsLoading;

                          String hintText;
                          if (_brandId == null) {
                            hintText = 'اختر الماركة أولًا';
                          } else if (modelsLoading) {
                            hintText = 'جاري تحميل الموديلات...';
                          } else if (carModels.isEmpty) {
                            hintText = 'لا توجد موديلات متاحة';
                          } else {
                            hintText = 'حدد الموديلات المدعومة';
                          }

                          return _pickerField(
                            label: 'موديلات مدعومة',
                            hint: hintText,
                            value: _selectedModels.isEmpty ? null : _selectedModels.join('، '),
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              if (_brandId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('اختر الماركة أولًا')),
                                );
                                return;
                              }

                              if (catState.models.isEmpty && !modelsLoading) {
                                await context.read<CarCatalogCubit>().loadModels(_brandId!);
                              }
                              if (context.read<CarCatalogCubit>().state.models.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('لا توجد موديلات متاحة لهذه الماركة الآن')),
                                );
                                return;
                              }

                              final carModels2 = context.read<CarCatalogCubit>().state.models;
                              final sel = await _openCarModelMultiSelectDialog(
                                context: context,
                                options: carModels2.map((m) => m.displayName).toList(),
                                initialSelected: _selectedModels.toSet(),
                              );
                              if (sel != null) {
                                setState(() {
                                  _selectedModels
                                    ..clear()
                                    ..addAll(sel);
                                });
                                cubit.setSupportedModels(_selectedModels);
                              }
                            },
                          );
                        },
                      ),
                      verticalSpace(12),

                      _textField(
                        label: 'وصف القطعة',
                        hint: 'اكتب وصف المنتج...',
                        maxLines: 3,
                        controller: _descCtrl,
                        onChanged: cubit.setDescription,
                      ),
                      verticalSpace(12),

                      // المدينة والمنطقة
                      BlocBuilder<LocationCubit, LocationState>(
                        builder: (context, locState) {
                          final isLoading = locState.regionsLoading || locState.citiesLoading;

                          return _pickerField(
                            label: 'المدينة والمنطقة',
                            hint: isLoading ? 'جاري تحميل المناطق...' : 'اختر المنطقة والمدينة',
                            value: _selectedCity != null
                                ? '${_selectedRegion?.nameAr} - ${_selectedCity?.nameAr}'
                                : null,
                            onTap: isLoading
                                ? () {}
                                : () async {
                              FocusScope.of(context).unfocus();
                              final res = await _openRegionAndCityDialog(context);
                              if (res != null) {
                                setState(() {
                                  _selectedRegion = res.region;
                                  _selectedCity = res.city;
                                });
                                cubit.setCityId(res.city.id);
                                cubit.setRegionId(res.region.id);
                              }
                            },
                          );
                        },
                      ),
                      verticalSpace(12),

                      PrimaryButton(
                        text: 'التالي',
                        onPressed: () {
                          FocusScope.of(context).unfocus();

                          final missing = <String>[];
                          if (_partNameCtrl.text.isEmpty) missing.add('نوع القطعة');
                          if (_brandId == null) missing.add('ماركة السيارة');
                          if (_selectedModels.isEmpty) missing.add('موديلات مدعومة');
                          if (_selectedCity == null) missing.add('المدينة');

                          if (missing.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('يرجى تعبئة: ${missing.join('، ')}')),
                            );
                            return;
                          }

                          cubit.setPartName(_partNameCtrl.text);
                          cubit.setDescription(_descCtrl.text);
                          cubit.setCondition(_condition);
                          cubit.setSupportedModels(_selectedModels);

                          // مرر نفس نسخة Cubit
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider<CarPartAdsCubit>.value(
                                value: cubit,
                                child: const CarPartCreateAdStep2Screen(),
                              ),
                            ),
                          );
                        },
                      ),
                      verticalSpace(12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // حوارات

  Future<CarType?> _openCarBrandDialog(BuildContext context) async {
    final catalogCubit = context.read<CarCatalogCubit>();
    String query = '';

    return showModalBottomSheet<CarType>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: catalogCubit,
          child: StatefulBuilder(
            builder: (ctx, setSheet) {
              final catState = catalogCubit.state;
              if (catState.brandsLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }

              final filtered = catState.brands
                  .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
                  .toList();

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + MediaQuery.of(ctx).viewInsets.bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                          const SizedBox(width: 8),
                          const Text('ماركة السيارة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const Spacer(),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        autofocus: false,
                        decoration: _dialogSearchDecoration('ابحث باسم الماركة...'),
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
                            final sel = it.id == _brandId;
                            return ListTile(
                              onTap: () => Future.microtask(() => Navigator.pop(ctx, it)),
                              title: Text(
                                it.name,
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
            },
          ),
        );
      },
    );
  }

  Future<Set<String>?> _openCarModelMultiSelectDialog({
    required BuildContext context,
    required List<String> options,
    required Set<String> initialSelected,
  }) async {
    final selected = <String>{...initialSelected};
    String query = '';

    return showModalBottomSheet<Set<String>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          final filtered = options.where((e) => e.toLowerCase().contains(query.toLowerCase())).toList();

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      const SizedBox(width: 8),
                      const Text('موديلات مدعومة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('يمكنك اختيار أكثر من موديل', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ),
                  SizedBox(height: 8.h),

                  TextField(
                    autofocus: false,
                    decoration: _dialogSearchDecoration('ابحث باسم الموديل...'),
                    onChanged: (q) => setSheet(() => query = q.trim()),
                  ),
                  SizedBox(height: 10.h),

                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final name = filtered[i];
                        final sel = selected.contains(name);
                        return CheckboxListTile(
                          value: sel,
                          onChanged: (v) {
                            setSheet(() {
                              if (sel) {
                                selected.remove(name);
                              } else {
                                selected.add(name);
                              }
                            });
                          },
                          title: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              name,
                              style: TextStyle(
                                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                                color: sel ? const Color(0xFF0A45A6) : Colors.black87,
                              ),
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: const Color(0xFF0A45A6),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, selected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('حفظ'),
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

  Future<({Region region, City city})?> _openRegionAndCityDialog(BuildContext context) async {
    final locCubit = context.read<LocationCubit>();
    String query = '';

    final selectedRegion = await showModalBottomSheet<Region>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return BlocProvider.value(
          value: locCubit,
          child: StatefulBuilder(builder: (ctx, setSheet) {
            final locState = locCubit.state;
            if (locState.regionsLoading) {
              return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator.adaptive()));
            }
            final filtered = locState.regions.where((e) => e.nameAr.contains(query)).toList();

            return SafeArea(child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)), const SizedBox(width: 8), const Text('اختر المنطقة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const Spacer()]),
                SizedBox(height: 8.h),
                TextField(
                  autofocus: false,
                  decoration: _dialogSearchDecoration('ابحث باسم المنطقة...'),
                  onChanged: (q) => setSheet(() => query = q.trim()),
                ),
                SizedBox(height: 10.h),
                Flexible(child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final it = filtered[i];
                    return ListTile(
                      onTap: () => Future.microtask(() => Navigator.pop(ctx, it as Region)),
                      title: Text(it.nameAr),
                      trailing: const Icon(Icons.chevron_left_rounded),
                      dense: true,
                    );
                  },
                )),
              ]),
            ));
          }),
        );
      },
    );

    if (selectedRegion == null) return null;

    await locCubit.loadCities(selectedRegion.id);
    query = '';

    final selectedCity = await showModalBottomSheet<City>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return BlocProvider.value(
          value: locCubit,
          child: StatefulBuilder(builder: (ctx, setSheet) {
            final locState = locCubit.state;
            if (locState.citiesLoading) {
              return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator.adaptive()));
            }
            final filtered = locState.cities.where((e) => e.nameAr.contains(query)).toList();

            return SafeArea(child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)), const SizedBox(width: 8), Text('اختر المدينة في ${selectedRegion.nameAr}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const Spacer()]),
                SizedBox(height: 8.h),
                TextField(
                  autofocus: false,
                  decoration: _dialogSearchDecoration('ابحث باسم المدينة...'),
                  onChanged: (q) => setSheet(() => query = q.trim()),
                ),
                SizedBox(height: 10.h),
                Flexible(child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final it = filtered[i] as City;
                    return ListTile(
                      onTap: () => Future.microtask(() => Navigator.pop(ctx, it)),
                      title: Text(it.nameAr),
                      trailing: const Icon(Icons.chevron_left_rounded),
                      dense: true,
                    );
                  },
                )),
              ]),
            ));
          }),
        );
      },
    );

    if (selectedCity == null) return null;

    return (region: selectedRegion, city: selectedCity);
  }

  InputDecoration _dialogSearchDecoration(String hint) {
    return InputDecoration(
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
    );
  }

  Widget _segment({
    required String title,
    required List<String> items,
    required String value,
    required Function(String) onSelect,
    Map<String, String>? labels,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyles.font16Dark500400Weight),
        verticalSpace(8),
        if (items.length <= 3)
          Row(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Expanded(
                  child: _segButton(
                    text: labels?[items[i]] ?? items[i],
                    selected: items[i] == value,
                    onTap: () => onSelect(items[i]),
                  ),
                ),
                if (i != items.length - 1) SizedBox(width: 8.w),
              ],
            ],
          )
        else
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: items.map((e) {
              final selected = e == value;
              return SizedBox(
                width: 140.w,
                child: _segButton(
                  text: labels?[e] ?? e,
                  selected: selected,
                  onTap: () => onSelect(e),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _segButton({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 44.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? ColorsManager.primaryColor : Colors.white,
          foregroundColor: selected ? Colors.white : Colors.black87,
          side: BorderSide(
            color: selected ? Colors.transparent : ColorsManager.dark200,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}