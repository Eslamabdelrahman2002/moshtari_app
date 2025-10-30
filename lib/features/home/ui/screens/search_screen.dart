import 'dart:async';
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

import '../../../../core/widgets/primary/my_svg.dart';

class SearchScreen extends StatefulWidget {
  final AdsFilter? initial;
  const SearchScreen({super.key, this.initial});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial?.query ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _doSearch(BuildContext context) {
    final txt = _controller.text.trim();
    if (txt.isEmpty) return;
    context.read<AdsQueryCubit>().searchByText(txt);
    _focus.unfocus();
  }

  void _onChanged(BuildContext context, String text) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final t = text.trim();
      if (t.isNotEmpty) {
        context.read<AdsQueryCubit>().searchByText(t);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.black12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: {
                          const SizedBox(width: 8),
                          const Icon(Icons.search_rounded, color: Colors.black45),
                          Expanded(
                            child: TextField(
                              focusNode: _focus,
                              controller: _controller,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _doSearch(context),
                              onChanged: (t) => _onChanged(context, t),
                              decoration: const InputDecoration(
                                hintText: 'ابحث باسم الإعلان',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              ),
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: () { _controller.clear(); setState(() {}); },
                            ),
                        }.toList(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    height: 44,
                    width: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        backgroundColor: ColorsManager.primaryColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              BlocBuilder<AdsQueryCubit, AdsQueryState>(
                builder: (context, state) {
                  final isList = state is AdsQuerySuccess ? state.isListView : false;
                  final count = state is AdsQuerySuccess ? state.items.length : 0;
                  return Row(
                    children: [
                      _ViewToggle(
                        isList: isList,
                        onList: () => context.read<AdsQueryCubit>().setLayout(true),
                        onGrid: () => context.read<AdsQueryCubit>().setLayout(false),
                      ),
                      const Spacer(),
                      Text('نتائج البحث ($count)', style: TextStyles.font14Dark500Weight),
                    ],
                  );
                },
              ),

              SizedBox(height: 8.h),

              Expanded(
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
                        return SliverFillRemaining(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                             MySvg(image: "search-status",height: 120.sp,),
                              Text('ابحث باسم الإعلان', style: TextStyles.font14Dark500Weight),
                              SizedBox(height: 4.h),
                              Text('ابدأ بالكتابة بالأعلى لعرض النتائج', style: TextStyles.font12DarkGray400Weight),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final bool isList;
  final VoidCallback onList;
  final VoidCallback onGrid;
  const _ViewToggle({super.key, required this.isList, required this.onList, required this.onGrid});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _segBtn(icon: Icons.view_agenda, selected: isList, onTap: onList),
        const SizedBox(width: 6),
        _segBtn(icon: Icons.grid_view_rounded, selected: !isList, onTap: onGrid),
      ],
    );
  }
  Widget _segBtn({required IconData icon, required bool selected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 36, width: 36, alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? ColorsManager.secondary: ColorsManager.secondary200.withOpacity(.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? ColorsManager.primary400 : Colors.black12),
        ),
        child: Icon(icon, size: 18, color: selected ? ColorsManager.white: ColorsManager.secondary),
      ),
    );
  }
}