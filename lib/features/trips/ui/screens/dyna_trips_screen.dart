import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/location/data/model/location_models.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import '../logic/cubit/dyna_trips_list_cubit.dart';
import '../logic/cubit/dyna_trips_list_state.dart';
import '../widgets/dyna_trip_card.dart';
import '../widgets/city_selector_dialog.dart';

class DynaTripsScreen extends StatefulWidget {
  const DynaTripsScreen({super.key});

  @override
  State<DynaTripsScreen> createState() => _DynaTripsScreenState();
}

class _DynaTripsScreenState extends State<DynaTripsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // تحميل أول صفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DynaTripsListCubit>().initLoad(pageSize: 5);
    });
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final c = context.read<DynaTripsListCubit>();
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      c.loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _pickCity({required bool from}) async {
    final city = await showCitySelectorDialog(context);
    if (city != null) {
      final cubit = context.read<DynaTripsListCubit>();
      if (from) {
        cubit.setFromCity(city);
      } else {
        cubit.setToCity(city);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DynaTripsListCubit>(
      create: (_) => getIt<DynaTripsListCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('إدارة رحلاتي', style: TextStyles.font20Black500Weight),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<DynaTripsListCubit, DynaTripsListState>(
          builder: (context, state) {
            final cubit = context.read<DynaTripsListCubit>();

            return Column(
              children: [
                // شريط الفلترة
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickCity(from: true),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: ColorsManager.dark100),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                          child: Text(
                            state.fromCity?.nameAr ?? 'موقع الانطلاق',
                            style: TextStyle(
                              color: state.fromCity == null ? ColorsManager.darkGray : ColorsManager.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pickCity(from: false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: ColorsManager.dark100),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                          child: Text(
                            state.toCity?.nameAr ?? 'موقع الوصول',
                            style: TextStyle(
                              color: state.toCity == null ? ColorsManager.darkGray : ColorsManager.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      SizedBox(
                        height: 44.h,
                        child: ElevatedButton(
                          onPressed: state.loading ? null : () => cubit.applyFilters(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                          child: const Text('بحث'),
                        ),
                      ),
                      if (state.fromCity != null || state.toCity != null) ...[
                        SizedBox(width: 8.w),
                        IconButton(
                          tooltip: 'مسح الفلاتر',
                          onPressed: () => cubit.clearFilters(),
                          icon: Icon(Icons.clear, color: ColorsManager.darkGray),
                        ),
                      ],
                    ],
                  ),
                ),

                Divider(color: ColorsManager.dark100, thickness: 1),

                // القائمة
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<DynaTripsListCubit>().initLoad(pageSize: state.pageSize),
                    child: state.loading && state.items.isEmpty
                        ? const Center(child: CircularProgressIndicator.adaptive())
                        : state.error != null
                        ? ListView(
                      controller: _scroll,
                      children: [
                        SizedBox(height: 100.h),
                        Center(child: Text(state.error!, style: TextStyles.font14Black500Weight)),
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: () => context.read<DynaTripsListCubit>().initLoad(pageSize: state.pageSize),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    )
                        : ListView.builder(
                      controller: _scroll,
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                      itemCount: state.items.length + (state.loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.items.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: const Center(child: CircularProgressIndicator.adaptive()),
                          );
                        }
                        final item = state.items[index];
                        return DynaTripCard(
                          item: item,
                          // onDetails: () {
                          //   // TODO: شاشة تفاصيل الطلب/الرحلة
                          // },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}