import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/screens/real_estate/real_estate_mappers.dart';
import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';
import 'package:mushtary/features/create_ad/ui/widgets/detail_selector.dart';
import 'package:mushtary/features/create_ad/ui/widgets/next_button_bar.dart';
import 'package:mushtary/features/create_ad/ui/widgets/secondary_text_form_field_has_value.dart';

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

  String? selectedType;        // نوع العقار
  String? selectedRegion;      // المنطقة
  String? selectedCity;        // المدينة
  List<String> selectedHoods = []; // الأحياء (متعدد)

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RealEstateAdsCubit>();

    // بيانات وهمية للعرض (بدّلها بمصدر بياناتك)
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

    final regions = <_OptionItem>[
      _OptionItem('منطقة مكة', Icons.place_rounded),
      _OptionItem('منطقة الرياض', Icons.place_rounded),
      _OptionItem('الشرقية', Icons.place_rounded),
    ];

    final citiesMap = <String, List<String>>{
      'منطقة مكة': ['مكة', 'جدة', 'الطائف'],
      'منطقة الرياض': ['الرياض', 'الدرعية', 'الخرج'],
      'الشرقية': ['الدمام', 'الخبر', 'الأحساء'],
    };

    final hoodsMap = <String, List<String>>{
      'مكة': ['الزهراء', 'النزهة', 'العزيزية', 'الشوقية', 'العوالي'],
      'جدة': ['النسيم', 'الصالحية', 'السلامة', 'البوادي', 'الفيصلية'],
      'الطائف': ['القيم', 'السيل', 'الحوية'],
      'الرياض': ['الفردوس', 'الملقا', 'الياسمين', 'النرجس', 'قرطبة'],
      'الدرعية': ['البجيري', 'عرقة'],
      'الخرج': ['السهباء', 'الخزامى'],
      'الدمام': ['الشاطئ', 'الإسكان', 'البادية'],
      'الخبر': ['العقربية', 'الثقبة', 'الخزامى'],
      'الأحساء': ['الهفوف', 'المبرز'],
    };

    // دوال فتح الحوارات
    Future<void> pickType() async {
      final res = await _openSingleSelectDialog(
        context: context,
        title: 'التصنيف',
        hint: 'ابحث عن التصنيف...',
        items: propertyTypes,
        selected: selectedType,
      );
      if (res != null) {
        setState(() => selectedType = res);
        cubit.setRealEstateType(RealEstateMappers.type(res));
      }
    }

    Future<void> pickRegion() async {
      final res = await _openSingleSelectDialog(
        context: context,
        title: 'المنطقة',
        hint: 'ابحث باسم المنطقة...',
        items: regions,
        selected: selectedRegion,
      );
      if (res != null) {
        setState(() {
          selectedRegion = res;
          selectedCity = null;
          selectedHoods = [];
        });
        // TODO: cubit.setRegion(res);
      }
    }

    Future<void> pickCity() async {
      if (selectedRegion == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر المنطقة أولًا')));
        return;
      }
      final cities = (citiesMap[selectedRegion] ?? []).map((e) => _OptionItem(e, Icons.chevron_left_rounded)).toList();
      final res = await _openSingleSelectDialog(
        context: context,
        title: 'المدينة',
        hint: 'ابحث باسم المدينة...',
        items: cities,
        selected: selectedCity,
      );
      if (res != null) {
        setState(() {
          selectedCity = res;
          selectedHoods = [];
        });
        // TODO: cubit.setCity(res);
      }
    }

    Future<void> pickHoods() async {
      if (selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر المدينة أولًا')));
        return;
      }
      final hoods = hoodsMap[selectedCity] ?? [];
      final res = await _openMultiSelectDialog(
        context: context,
        title: 'اختر الحي',
        hint: 'ابحث باسم الحي...',
        note: 'يمكنك اختيار أكثر من حي',
        options: hoods,
        initialSelected: selectedHoods.toSet(),
      );
      if (res != null) {
        setState(() => selectedHoods = res.toList());
        // TODO: cubit.setHoods(selectedHoods);
      }
    }

    return Scaffold(
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

                  // نوع الطلب
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
                            cubit.setPurpose(false);
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
                            cubit.setPurpose(true);
                          },
                        ),
                      ),
                    ],
                  ),
                  verticalSpace(16),

                  // نوع العقار
                  DetailSelector(
                    title: 'نوع العقار',
                    widget: selectedType == null
                        ? InkWell(
                            onTap: pickType,
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
                            },
                          ),
                  ),
                  verticalSpace(12),

                  // المنطقة
                  DetailSelector(
                    title: 'المنطقة',
                    widget: selectedRegion == null
                        ? InkWell(
                            onTap: pickRegion,
                            child: SecondaryTextFormField(
                              label: 'المنطقة',
                              hint: 'اختر المنطقة',
                              maxheight: 56.h,
                              minHeight: 56.h,
                              suffexIcon: 'arrow-left',
                              isEnabled: false,
                            ),
                          )
                        : SecondaryTextFormFieldHasValue(
                            title: selectedRegion!,
                            onTap: () {
                              setState(() {
                                selectedRegion = null;
                                selectedCity = null;
                                selectedHoods = [];
                              });
                            },
                          ),
                  ),
                  verticalSpace(12),

                  // المدينة
                  DetailSelector(
                    title: 'المدينة',
                    widget: selectedCity == null
                        ? InkWell(
                            onTap: pickCity,
                            child: SecondaryTextFormField(
                              label: 'المدينة',
                              hint: 'اختر المدينة',
                              maxheight: 56.h,
                              minHeight: 56.h,
                              suffexIcon: 'arrow-left',
                              isEnabled: false,
                            ),
                          )
                        : SecondaryTextFormFieldHasValue(
                            title: selectedCity!,
                            onTap: () {
                              setState(() {
                                selectedCity = null;
                                selectedHoods = [];
                              });
                            },
                          ),
                  ),
                  verticalSpace(12),

                  // الحي (متعدد)
                  DetailSelector(
                    title: 'الحي',
                    widget: selectedHoods.isEmpty
                        ? InkWell(
                            onTap: pickHoods,
                            child: SecondaryTextFormField(
                              label: 'الحي',
                              hint: 'يمكنك اختيار أكثر من حي',
                              maxheight: 56.h,
                              minHeight: 56.h,
                              suffexIcon: 'arrow-left',
                              isEnabled: false,
                            ),
                          )
                        : SecondaryTextFormFieldHasValue(
                            title: selectedHoods.join('، '),
                            onTap: () => pickHoods(),
                          ),
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
          onPressed: (selectedType != null) ? widget.onNext : null,
          title: 'التالي',
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
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // شريط أعلى + زر إغلاق
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      const SizedBox(width: 8),
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // البحث
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

  Future<Set<String>?> _openMultiSelectDialog({
    required BuildContext context,
    required String title,
    required String hint,
    required String note,
    required List<String> options,
    required Set<String> initialSelected,
  }) async {
    final selected = <String>{...initialSelected};
    String query = '';

    return showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          final filtered = options
              .where((e) => e.toLowerCase().contains(query.toLowerCase()))
              .toList();

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      const SizedBox(width: 8),
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(note, style: const TextStyle(color: Colors.black54, fontSize: 12)),
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
                          controlAffinity: ListTileControlAffinity.leading, // لليمين في RTL
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
                        backgroundColor: const Color(0xFF0A45A6),
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
}

// عنصر داخلي لعرض الخيارات مع أيقونة
class _OptionItem {
  final String label;
  final IconData icon;
  _OptionItem(this.label, this.icon);
}