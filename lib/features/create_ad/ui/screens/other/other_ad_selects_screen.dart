// lib/features/create_ad/ui/screens/other/other_ad_selects_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/create_ad/ui/widgets/next_button_bar.dart';

import 'logic/cubit/other_ads_cubit.dart';

class OtherAdSelectsScreen extends StatefulWidget {
  final VoidCallback? onNext;
  const OtherAdSelectsScreen({super.key, this.onNext});

  @override
  State<OtherAdSelectsScreen> createState() => _OtherAdSelectsScreenState();
}

class _OtherAdSelectsScreenState extends State<OtherAdSelectsScreen> {
  String? subCategoryName;
  String? cityName;
  String? regionsName;

  // بيانات مبدئية (استبدلها بـ API لاحقاً)
  final subCategories = const [
    {'id': 81, 'name': 'أدوات منزلية'},
    {'id': 82, 'name': 'عجلات'},
    {'id': 83, 'name': 'هواتف'},
    {'id': 84, 'name': 'كتب'},
    {'id': 85, 'name': 'مستلزمات أطفال'},
    {'id': 86, 'name': 'إلكترونيات'},
  ];

  final cities = const [
    {'id': 1, 'name': 'مكة'},
    {'id': 2, 'name': 'المدينة'},
    {'id': 3, 'name': 'الأحساء'},
    {'id': 4, 'name': 'الرياض'},
    {'id': 5, 'name': 'الدرعية'},
    {'id': 6, 'name': 'الجبيل'},
  ];

  final regionsByCity = const {
    4: [
      {'id': 11, 'name': 'الدرعية'},
      {'id': 12, 'name': 'النرجس'},
      {'id': 13, 'name': 'الدوس'},
      {'id': 14, 'name': 'اليرموك'},
    ],
    1: [
      {'id': 21, 'name': 'العوالي'},
      {'id': 22, 'name': 'النسيم'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OtherAdsCubit>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: MySvg(image: "arrow-right", color: ColorsManager.black),
                  ),
                  SizedBox(width: 6.w),
                  Text("إنشاء إعلان", style: TextStyles.font16Black500Weight),
                ],
              ),
            ),

            _OutlinedSelectorField(
              label: 'التصنيف الفرعي',
              hint: subCategoryName ?? 'اختر التصنيف الفرعي',
              onTap: () => _openSelectSheet(
                context: context,
                title: 'اختر التصنيف الفرعي',
                hint: 'ابحث اسم التصنيف...',
                items: subCategories,
                multi: true, // تقدر تخليها false لو تبغى اختيار واحد فقط
                onSaved: (ids) {
                  if (ids.isEmpty) return;
                  final id = ids.first;
                  final name = subCategories.firstWhere((e) => e['id'] == id)['name'] as String;
                  cubit.setSubCategoryId(id);
                  setState(() => subCategoryName = name);
                },
              ),
            ),
            verticalSpace(12),

            _OutlinedSelectorField(
              label: 'المدينة',
              hint: cityName ?? 'اختر المدينة',
              onTap: () => _openSelectSheet(
                context: context,
                title: 'المدينة',
                hint: 'ابحث اسم المدينة...',
                items: cities,
                multi: false,
                onSaved: (ids) {
                  if (ids.isEmpty) return;
                  final id = ids.first;
                  final name = cities.firstWhere((e) => e['id'] == id)['name'] as String;
                  cubit.setCityId(id);
                  cubit.setRegionId(null);
                  setState(() {
                    cityName = name;
                    regionsName = null;
                  });
                },
              ),
            ),
            verticalSpace(12),

            _OutlinedSelectorField(
              label: 'الحي',
              hint: regionsName ?? 'يمكنك اختيار أكثر من حي',
              onTap: (cubit.state.cityId == null)
                  ? null
                  : () {
                final regions = regionsByCity[cubit.state.cityId] ?? [];
                _openSelectSheet(
                  context: context,
                  title: 'اختر الحي',
                  hint: 'ابحث اسم الحي...',
                  items: regions,
                  multi: true,
                  multiNote: 'يمكنك اختيار أكثر من حي',
                  onSaved: (ids) {
                    if (ids.isEmpty) return;
                    final id = ids.first;
                    final names = regions
                        .where((e) => ids.contains(e['id']))
                        .map((e) => e['name'] as String)
                        .toList();
                    cubit.setRegionId(id);
                    setState(() => regionsName = names.join('، '));
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16),
        child: NextButtonBar(
          title: 'التالي',
          onPressed: (cubit.state.subCategoryId != null && cubit.state.cityId != null)
              ? widget.onNext
              : null,
        ),
      ),
    );
  }

  Future<void> _openSelectSheet({
    required BuildContext context,
    required String title,
    required String hint,
    required List<Map<String, Object>> items,
    required bool multi,
    String? multiNote,
    required ValueChanged<Set<int>> onSaved,
  }) async {
    final controller = TextEditingController();
    var filtered = List<Map<String, Object>>.from(items);
    final selected = <int>{};

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          void filter(String q) {
            filtered = items
                .where((e) => (e['name'] as String).toLowerCase().contains(q.toLowerCase()))
                .toList();
            setSheet(() {});
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 8.h,
                left: 16.w,
                right: 16.w,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: ColorsManager.black),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(title, style: TextStyles.font18Black500Weight),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  if (multiNote != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(multiNote, style: TextStyles.font12Dark500400Weight),
                    ),
                  verticalSpace(8),

                  // Search
                  TextField(
                    controller: controller,
                    onChanged: filter,
                    decoration: InputDecoration(
                      hintText: hint,
                      prefixIcon: const Icon(Icons.search, color: ColorsManager.darkGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    ),
                  ),
                  verticalSpace(8),

                  // List
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final item = filtered[i];
                        final id = item['id'] as int;
                        final name = item['name'] as String;
                        final isSelected = selected.contains(id);

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            name,
                            style: isSelected
                                ? TextStyles.font14Blue500Weight
                                .copyWith(color: const Color(0xFF0A45A6))
                                : null,
                          ),
                          trailing: multi
                              ? InkWell(
                            onTap: () {
                              setSheet(() {
                                if (isSelected) {
                                  selected.remove(id);
                                } else {
                                  selected.add(id);
                                }
                              });
                            },
                            child: MySvg(
                              image: isSelected ? 'tick-square-check' : 'tick-square',
                            ),
                          )
                              : Radio<int>(
                            value: id,
                            groupValue: selected.isEmpty ? null : selected.first,
                            onChanged: (v) {
                              setSheet(() {
                                selected
                                  ..clear()
                                  ..add(id);
                              });
                            },
                          ),
                          onTap: () {
                            if (multi) {
                              setSheet(() {
                                if (isSelected) {
                                  selected.remove(id);
                                } else {
                                  selected.add(id);
                                }
                              });
                            } else {
                              setSheet(() {
                                selected
                                  ..clear()
                                  ..add(id);
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                  verticalSpace(8),

                  // Save
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        onSaved(selected);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: const Text('حفظ', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  verticalSpace(12),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

// حقل اختيار مخصص بالشكل الظاهر بالصورة
class _OutlinedSelectorField extends StatelessWidget {
  final String label;
  final String hint;
  final VoidCallback? onTap;
  const _OutlinedSelectorField({
    required this.label,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.font12Dark500400Weight),
        SizedBox(height: 6.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 56.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: ColorsManager.dark100),
            ),
            child: Row(
              children: [
                const MySvg(image: 'arrow-left'),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyles.font14Dark400400Weight,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}