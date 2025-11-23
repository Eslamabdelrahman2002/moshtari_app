import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/sliver_app_bar_delegate.dart';
import 'package:mushtary/features/services/ui/widgets/dinat_grid_view.dart';
import 'package:mushtary/features/services/ui/widgets/dinat_section_header.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';

import 'package:mushtary/features/create_ad/ui/widgets/customized_chip.dart';
import 'package:mushtary/core/location/data/model/location_models.dart';

import '../../data/model/dyna_trips_filter.dart';
import '../../logic/cubit/dyna_trips_cubit.dart';
import '../../logic/cubit/dyna_trips_state.dart';
import '../widgets/city_picker_sheet.dart';

class DinatScreen extends StatefulWidget {
  const DinatScreen({super.key});

  @override
  State<DinatScreen> createState() => _DinatScreenState();
}

class _DinatScreenState extends State<DinatScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DynaTripsCubit>(
          create: (_) => getIt<DynaTripsCubit>()..loadInitial(),
        ),
      ],
      // مهم: لفّ الـ Scaffold بـ Builder عشان ناخد context داخل الـ Provider
      child: Builder(
        builder: (innerCtx) {
          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              heroTag: 'dynaFilterFAB',
              backgroundColor: ColorsManager.primaryColor,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              label: const Text('تصفية', style: TextStyle(color: Colors.white)),
              // استخدم innerCtx (تحت الـ Provider)
              onPressed: () => _openFilterSheet(innerCtx),
            ),
            body: BlocBuilder<DynaTripsCubit, DynaTripsState>(
              builder: (context, state) {
                return CustomScrollView(
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      floating: true,
                      delegate: SliverAppBarDelegate(
                        maxHeight: 70.h,
                        minHeight: 70.h,
                        child: const DinatSectionHeader(),
                      ),
                    ),

                    SliverToBoxAdapter(child: verticalSpace(8)),

                    if (state is DynaTripsLoading)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(child: CircularProgressIndicator.adaptive()),
                        ),
                      ),

                    if (state is DynaTripsFailure)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(child: Text('تعذر جلب الرحلات: ${state.error}')),
                        ),
                      ),

                    if (state is DynaTripsSuccess && state.trips.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: Text('لا توجد رحلات متاحة حالياً')),
                        ),
                      ),

                    if (state is DynaTripsSuccess && state.trips.isNotEmpty)
                      DinatGridView(trips: state.trips),

                    SliverToBoxAdapter(child: verticalSpace(16)),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    // الآن هذا context تحت الـ BlocProvider
    final cubit = context.read<DynaTripsCubit>();
    final current = cubit.currentFilter;

    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return _DynaFilterSheet(
          initial: current,
          onApply: (f) => cubit.applyFilter(f),
          onClearAll: () => cubit.resetFilter(),
        );
      },
    );
  }
}

class _DynaFilterSheet extends StatefulWidget {
  final DynaTripsFilter initial;
  final ValueChanged<DynaTripsFilter> onApply;
  final VoidCallback onClearAll;
  const _DynaFilterSheet({
    required this.initial,
    required this.onApply,
    required this.onClearAll,
  });

  @override
  State<_DynaFilterSheet> createState() => _DynaFilterSheetState();
}

class _DynaFilterSheetState extends State<_DynaFilterSheet> {
  String? _sizeLabel; // 'صغير' | 'وسط' | 'كبير'
  City? _fromCity;
  City? _toCity;
  DateTime? _date;

  final List<String> _sizes = const ['صغير', 'وسط', 'كبير'];

  @override
  void initState() {
    super.initState();
    _sizeLabel = _labelFromCapacity(widget.initial.dynaCapacity);
    _date = widget.initial.date;
  }

  int? _capacityFromLabel(String? label) {
    switch (label) {
      case 'صغير':
        return 10; // عدّل حسب الباك
      case 'وسط':
        return 15;
      case 'كبير':
        return 20;
      default:
        return null;
    }
  }

  String? _labelFromCapacity(int? cap) {
    switch (cap) {
      case 10:
        return 'صغير';
      case 15:
        return 'وسط';
      case 20:
        return 'كبير';
      default:
        return null;
    }
  }

  String _fmtDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom + 16;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(child: Text('تصفية', style: TextStyles.font18Black500Weight)),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _sizeLabel = null;
                        _fromCity = null;
                        _toCity = null;
                        _date = null;
                      });
                      widget.onClearAll();
                      Navigator.of(context).pop();
                    },
                    child: Text('حذف الكل', style: TextStyles.font14Red500Weight),
                  ),
                ],
              ),
              verticalSpace(16),

              Align(
                alignment: Alignment.centerRight,
                child: Text('حجم الدينا', style: TextStyles.font16Dark500400Weight),
              ),
              verticalSpace(8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sizes.map((e) {
                  final selected = _sizeLabel == e;
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 20 * 3 - 16) / 3,
                    child: CustomizedChip(
                      title: e,
                      isSelected: selected,
                      onTap: () => setState(() => _sizeLabel = selected ? null : e),
                    ),
                  );
                }).toList(),
              ),
              verticalSpace(16),

              Align(
                alignment: Alignment.centerRight,
                child: Text('اتجاه الرحلة', style: TextStyles.font16Dark500400Weight),
              ),
              verticalSpace(8),
              Row(
                children: [
                  Expanded(
                    child: _SelectTile(
                      label: 'من',
                      value: _fromCity?.nameAr ?? 'اختر مدينة الانطلاق',
                      onTap: () async {
                        final picked = await _openCityPicker(context, title: 'مدينة الانطلاق');
                        if (picked != null) setState(() => _fromCity = picked);
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _SelectTile(
                      label: 'إلى',
                      value: _toCity?.nameAr ?? 'اختر مدينة الوصول',
                      onTap: () async {
                        final picked = await _openCityPicker(context, title: 'مدينة الوصول');
                        if (picked != null) setState(() => _toCity = picked);
                      },
                    ),
                  ),
                ],
              ),
              verticalSpace(16),

              Align(
                alignment: Alignment.centerRight,
                child: Text('وقت الرحلة', style: TextStyles.font16Dark500400Weight),
              ),
              verticalSpace(8),
              _SelectTile(
                label: 'تاريخ',
                value: _date == null ? 'اختر التاريخ' : _fmtDate(_date!),
                icon: Icons.calendar_today,
                onTap: () async {
                  final now = DateTime.now();
                  final res = await showDatePicker(
                    context: context,
                    firstDate: now,
                    lastDate: DateTime(now.year + 2),
                    initialDate: _date ?? now,
                    helpText: 'اختر تاريخ الرحلة',
                  );
                  if (res != null) setState(() => _date = res);
                },
              ),
              verticalSpace(24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        foregroundColor: Colors.black,
                        minimumSize: Size.fromHeight(48.h),
                      ),
                      child: const Text('رجوع'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final filter = DynaTripsFilter(
                          dynaCapacity: _capacityFromLabel(_sizeLabel),
                          fromCityId: _fromCity?.id,
                          toCityId: _toCity?.id,
                          date: _date,
                        );
                        widget.onApply(filter);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: Size.fromHeight(48.h),
                      ),
                      child: const Text('تطبيق الفلتر'),
                    ),
                  ),
                ],
              ),
              verticalSpace(12),
            ],
          ),
        ),
      ),
    );
  }

  Future<City?> _openCityPicker(BuildContext context, {required String title}) async {
    // استخدم النسخة التي تضيف LocationCubit داخلياً
    final sel = await CityPickerSheet.show(context, title: title);
    return sel?.city; // نعيد City فقط
  }
}

class _SelectTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData icon;
  const _SelectTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.icon = Icons.place_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyles.font12DarkGray400Weight),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.font14Black500Weight,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}