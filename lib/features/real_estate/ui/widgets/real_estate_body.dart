// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mushtary/core/utils/helpers/spacing.dart';
// import 'package:mushtary/features/real_estate/ui/widgets/real_estate_ads.dart';
// import 'package:mushtary/features/real_estate/ui/widgets/real_estate_app_bar.dart';
// import 'package:mushtary/features/real_estate/ui/widgets/real_estate_action_bar.dart';
// import 'package:skeletonizer/skeletonizer.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../data/model/real_estate_filter_params.dart';
// import '../../logic/cubit/real_estate_cubit.dart';
// import '../../logic/cubit/real_estate_state.dart';
// import '../../../home/ui/widgets/home_filter/home_filter_sheet.dart'; // لو محتاج شيت للمدن لاحقًا
// import 'package:mushtary/core/theme/colors.dart';
// import 'package:mushtary/core/theme/text_styles.dart';
//
// class RealEstateBody extends StatefulWidget {
//   const RealEstateBody({super.key});
//
//   @override
//   State<RealEstateBody> createState() => _RealEstateBodyState();
// }
//
// class _RealEstateBodyState extends State<RealEstateBody> {
//   // حالة العرض
//   bool isGridView = true;
//   bool isListView = false;
//   bool isMapView = false;
//
//   // نوع العقار المختار
//   String _selectedType = 'all';
//
//   // خريطة الأنواع (label -> apiValue)
//   final List<_TypeChip> _types = const [
//     _TypeChip(label: 'الكل', value: 'all'),
//     _TypeChip(label: 'شقق', value: 'apartment'),
//     _TypeChip(label: 'فلل', value: 'villa'),
//     _TypeChip(label: 'أراضي', value: 'land'),
//     _TypeChip(label: 'مكاتب', value: 'office'),
//   ];
//
//   // الفلتر الحالي
//   RealEstateFilterParams _filter = const RealEstateFilterParams(sortBy: 'latest');
//
//   @override
//   void initState() {
//     super.initState();
//     // أول مرة: جيب أحدث الإعلانات
//     context.read<RealEstateCubit>().fetchRealEstateAds(_filter);
//   }
//
//   void _applyType(String type) {
//     setState(() => _selectedType = type);
//     final apiType = type == 'all' ? null : type;
//     _filter = _filter.copyWith(realEstateType: apiType, page: 1);
//     context.read<RealEstateCubit>().fetchRealEstateAds(_filter);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Column(
//         children: [
//           const RealEstateAppBar(),
//           verticalSpace(8),
//
//           // كتوجري نوع العقار
//           _TypesBar(
//             types: _types,
//             selected: _selectedType,
//             onSelected: _applyType,
//           ),
//           verticalSpace(10),
//
//           // شريط العرض (Grid/List/Map) + اختيار مدينة/حي (لو هتفعلها)
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w),
//             child: RealEstateActionBar(
//               onGridViewTap: () => setState(() { isGridView = true; isListView = false; isMapView = false; }),
//               onListViewTap: () => setState(() { isGridView = false; isListView = true; isMapView = false; }),
//               onMapViewTap: () => setState(() { isGridView = false; isListView = false; isMapView = true; }),
//               isGridView: isGridView,
//               isListView: isListView,
//               isMapView: isMapView,
//               isApplications: false,
//             ),
//           ),
//           verticalSpace(8),
//
//           Expanded(
//             child: BlocBuilder<RealEstateCubit, RealEstateState>(
//               builder: (context, state) {
//                 if (state is RealEstateLoading) {
//                   return _RealEstateGridSkeleton();
//                 }
//                 if (state is RealEstateError) {
//                   return Center(child: Text('Error: ${state.message}'));
//                 }
//                 if (state is RealEstateLoaded) {
//                   if (state.ads.isEmpty) {
//                     return const Center(child: Text('لا يوجد عروض لهذه الفئة'));
//                   }
//                   return RealEstateAds(
//                     isApplications: false,
//                     isGridView: isGridView,
//                     isListView: isListView,
//                     isMapView: isMapView,
//                     properties: state.ads,
//                   );
//                 }
//                 return const Center(child: Text('اختر التصنيف لعرض الإعلانات.'));
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _TypeChip {
//   final String label;
//   final String value;
//   const _TypeChip({required this.label, required this.value});
// }
//
// class _TypesBar extends StatelessWidget {
//   final List<_TypeChip> types;
//   final String selected;
//   final ValueChanged<String> onSelected;
//
//   const _TypesBar({
//     super.key,
//     required this.types,
//     required this.selected,
//     required this.onSelected,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 40.h,
//       child: ListView.separated(
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         scrollDirection: Axis.horizontal,
//         itemCount: types.length,
//         separatorBuilder: (_, __) => SizedBox(width: 8.w),
//         itemBuilder: (_, i) {
//           final t = types[i];
//           final bool sel = selected == t.value;
//           return ChoiceChip(
//             label: Text(t.label),
//             selected: sel,
//             onSelected: (_) => onSelected(t.value),
//             selectedColor: ColorsManager.primary50,
//             labelStyle: sel ? TextStyles.font14Blue500Weight : TextStyles.font14Black500Weight,
//             backgroundColor: Colors.white,
//             side: BorderSide(color: sel ? ColorsManager.primary400 : ColorsManager.dark200),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _RealEstateGridSkeleton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Skeletonizer(
//       enabled: true,
//       child: GridView.builder(
//         padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
//         physics: const BouncingScrollPhysics(),
//         itemCount: 6,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           mainAxisSpacing: 12.h,
//           crossAxisSpacing: 12.w,
//           childAspectRatio: 0.78,
//         ),
//         itemBuilder: (_, __) => Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16.r),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.06),
//                 blurRadius: 12.r,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }