import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/home/data/models/ads_filter.dart';
import 'package:mushtary/features/home/logic/cubit/ads_query_cubit.dart';
import 'package:mushtary/features/home/logic/cubit/ads_query_state.dart';
import 'package:mushtary/features/home/ui/widgets/home_grid_view.dart';
import 'package:mushtary/features/home/ui/widgets/home_list_view.dart';
import 'package:mushtary/features/home/ui/widgets/home_filter/home_filter_sheet.dart';

class FilterResultsScreen extends StatelessWidget {
  final AdsFilter initial;
  const FilterResultsScreen({super.key, required this.initial});

  Future<void> _editFilters(BuildContext context) async {
    final current = context.read<AdsQueryCubit>().filter;
    final f = await showModalBottomSheet<AdsFilter>(
      context: context,
      isScrollControlled: true,
      builder: (_) => HomeFilterSheet(initial: current),
    );
    if (f != null) {
      context.read<AdsQueryCubit>().applyFilter(f);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:  SizedBox(
          height: 22,
          width: 22,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              backgroundColor: ColorsManager.white,
            ),
            onPressed: () => Navigator.pop(context),
            child:  Icon(Icons.arrow_back_ios_new, color: ColorsManager.darkGray300, size: 20),
          ),
        ),
        centerTitle: true,
        title:  Text('نتائج التصفية',style: TextStyles.font20Black500Weight,),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: ColorsManager.primary400),
            onPressed: () => _editFilters(context),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            BlocBuilder<AdsQueryCubit, AdsQueryState>(
              builder: (context, state) {
                if (state is AdsQueryLoading) {
                  return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
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
      floatingActionButton: BlocBuilder<AdsQueryCubit, AdsQueryState>(
        builder: (context, state) {
          final isList = state is AdsQuerySuccess ? state.isListView : false;
          return FloatingActionButton(
            backgroundColor: ColorsManager.secondary,
            onPressed: () => context.read<AdsQueryCubit>().setLayout(!isList),
            child: Icon(
              isList ? Icons.grid_view_rounded : Icons.view_agenda,
              color: ColorsManager.white,
            ),
          );
        },
      ),
    );
  }
}