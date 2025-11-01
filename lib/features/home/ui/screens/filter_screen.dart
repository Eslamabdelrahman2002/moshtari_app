import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/features/home/data/models/ads_filter.dart';
import 'package:mushtary/features/home/logic/cubit/ads_query_cubit.dart';
import 'package:mushtary/features/home/logic/cubit/ads_query_state.dart';
import 'package:mushtary/features/home/ui/widgets/home_grid_view.dart';
import 'package:mushtary/features/home/ui/widgets/home_list_view.dart';

class FilterScreen extends StatefulWidget {
  final AdsFilter initial;
  const FilterScreen({super.key, required this.initial});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  double minK = 0, maxK = 1000;
  String condition = 'all';
  String adType = 'all';
  bool photosOnly = false;
  String sort = 'latest';
  int distanceKm = 0;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i.priceMin != null) minK = (i.priceMin! / 1000).clamp(0, 1000);
    if (i.priceMax != null) maxK = (i.priceMax! / 1000).clamp(0, 1000);
    condition = i.condition ?? 'all';
    adType = i.advertiseType ?? 'all';
    photosOnly = i.hasImages ?? false;
    sort = i.sort ?? 'latest';
    distanceKm = i.distanceKm ?? 0;
  }

  Widget chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: ColorsManager.primary50,
      labelStyle: selected ? TextStyles.font14Blue500Weight : TextStyles.font14Black500Weight,
      backgroundColor: Colors.white,
      side: BorderSide(color: selected ? ColorsManager.primary400 : ColorsManager.dark200),
    );
  }

  void _clearAll() {
    setState(() {
      minK = 0; maxK = 1000;
      condition = 'all';
      adType = 'all';
      photosOnly = false;
      sort = 'latest';
      distanceKm = 0;
    });
  }

  void _apply(BuildContext context) {
    final f = AdsFilter(
      priceMin: minK > 0 ? minK * 1000 : null,
      priceMax: maxK < 1000 ? maxK * 1000 : null,
      condition: condition == 'all' ? null : condition,
      advertiseType: adType == 'all' ? null : adType,
      hasImages: photosOnly ? true : null,
      sort: sort,
      distanceKm: distanceKm > 0 ? distanceKm : null,
      categoryId: widget.initial.categoryId,
      page: 1,
      perPage: widget.initial.perPage,
    );
    context.read<AdsQueryCubit>().applyFilter(f);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تصفية'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [ TextButton(onPressed: _clearAll, child: const Text('حذف الكل', style: TextStyle(color: Colors.red))) ]),

                  Text('السعر', style: TextStyles.font16Dark400Weight),
                  RangeSlider(
                    values: RangeValues(minK, maxK),
                    min: 0, max: 1000,
                    onChanged: (v) => setState(() { minK = v.start; maxK = v.end; }),
                    activeColor: ColorsManager.primaryColor,
                    inactiveColor: ColorsManager.sliderInactiveColor,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${minK.round()}k', style: TextStyles.font14Blue500Weight),
                        Text('${maxK.round()}k', style: TextStyles.font14Blue500Weight),
                      ],
                    ),
                  ),
                  verticalSpace(12),

                  Text('الحالة', style: TextStyles.font16Dark400Weight),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      chip('الكل', condition == 'all', () => setState(()=> condition = 'all')),
                      chip('مستخدم', condition == 'used', () => setState(()=> condition = 'used')),
                      chip('جديد', condition == 'new', () => setState(()=> condition = 'new')),
                    ],
                  ),
                  verticalSpace(12),

                  Text('نوع الإعلان', style: TextStyles.font16Dark400Weight),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      chip('الكل', adType == 'all', () => setState(()=> adType = 'all')),
                      chip('مزاد', adType == 'auction', () => setState(()=> adType = 'auction')),
                      chip('مساومة', adType == 'bargain', () => setState(()=> adType = 'bargain')),
                      chip('سعر محدد', adType == 'fixed', () => setState(()=> adType = 'fixed')),
                    ],
                  ),
                  verticalSpace(12),

                  Text('أخرى', style: TextStyles.font16Dark400Weight),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('صور فقط'),
                        selected: photosOnly,
                        onSelected: (v)=> setState(()=> photosOnly = v),
                        selectedColor: ColorsManager.primary50,
                      ),
                      chip('الأحدث', sort == 'latest', () => setState(()=> sort = 'latest')),
                      chip('القريب', sort == 'nearest', () => setState(()=> sort = 'nearest')),
                    ],
                  ),
                  verticalSpace(8),

                  Text('محيط المسافة', style: TextStyles.font16Dark400Weight),
                  Slider(
                    value: distanceKm.toDouble(),
                    min: 0, max: 1000, divisions: 20,
                    onChanged: (v)=> setState(()=> distanceKm = v.round()),
                    activeColor: ColorsManager.primaryColor,
                    inactiveColor: ColorsManager.sliderInactiveColor,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(distanceKm == 0 ? 'بدون' : '$distanceKm كم', style: TextStyles.font14Blue500Weight),
                  ),
                  verticalSpace(12),

                  Row(
                    children: [
                      Expanded(child: PrimaryButton(text: 'تطبيق الفلتر', onPressed: () => _apply(context))),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: CustomScrollView(
                slivers: [
                  BlocBuilder<AdsQueryCubit, AdsQueryState>(
                    builder: (context, state) {
                      if (state is AdsQueryLoading) {
                        return const SliverFillRemaining(child: Center(child: CircularProgressIndicator.adaptive()));
                      }
                      if (state is AdsQueryFailure) {
                        return SliverFillRemaining(child: Center(child: Text(state.message)));
                      }
                      if (state is AdsQueryEmpty) {
                        return const SliverFillRemaining(child: Center(child: Text('لا توجد نتائج مطابقة')));
                      }
                      if (state is AdsQuerySuccess) {
                        return SliverPadding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          sliver: state.isListView
                              ? HomeListView(ads: state.items)
                              : HomeGridView(ads: state.items),
                        );
                      }
                      return const SliverFillRemaining(child: SizedBox());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}