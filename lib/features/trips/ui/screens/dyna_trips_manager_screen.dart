import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import '../logic/cubit/dyna_my_trips_cubit.dart';
import '../logic/cubit/dyna_trips_list_cubit.dart';
import '../logic/cubit/dyna_trips_list_state.dart';
import '../widgets/dyna_trip_card.dart';


class DynaTripsManagerScreen extends StatelessWidget {
  const DynaTripsManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0, // 0: رحلاتي | 1: رحلات
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
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.h),
            child: Container(
              color: Colors.white,
              child: TabBar(
                labelColor: ColorsManager.primaryColor,
                unselectedLabelColor: ColorsManager.darkGray,
                indicatorColor: ColorsManager.primaryColor,
                indicatorWeight: 3,
                labelStyle: TextStyles.font16Black500Weight,
                unselectedLabelStyle: TextStyles.font16Black500Weight,
                tabs: const [
                  Tab(text: 'رحلاتي'),
                  Tab(text: 'رحلات'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _MyTripsTabPage(), // GET /dyna-trips/my_trips
            _TripsTabPage(),   // GET /dyna-trips
          ],
        ),
      ),
    );
  }
}

// ========== تبويب "رحلاتي" ==========
class _MyTripsTabPage extends StatefulWidget {
  const _MyTripsTabPage();

  @override
  State<_MyTripsTabPage> createState() => _MyTripsTabPageState();
}

class _MyTripsTabPageState extends State<_MyTripsTabPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final c = context.read<DynaMyTripsCubit>();
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      c.loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DynaMyTripsCubit>(
      create: (_) => getIt<DynaMyTripsCubit>()..initLoad(pageSize: 10),
      child: BlocBuilder<DynaMyTripsCubit, DynaTripsListState>(
        builder: (context, state) {
          final cubit = context.read<DynaMyTripsCubit>();
          return Column(
            children: [
              Divider(color: ColorsManager.dark100, thickness: 1),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => cubit.initLoad(pageSize: state.pageSize),
                  child: state.loading && state.items.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : state.error != null
                      ? ListView(
                    controller: _scroll,
                    children: [
                      SizedBox(height: 100.h),
                      Center(child: Text(state.error!, style: TextStyles.font14Black500Weight)),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () => cubit.initLoad(pageSize: state.pageSize),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  )
                      : ListView.builder(
                    controller: _scroll,
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                    itemCount: state.items.length + (state.loadingMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= state.items.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }
                      final item = state.items[i];
                      return DynaTripCard(
                        item: item,
                        onDetails: () {
                          // TODO: تفاصيل رحلتك
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ========== تبويب "رحلات" ==========
class _TripsTabPage extends StatefulWidget {
  const _TripsTabPage();

  @override
  State<_TripsTabPage> createState() => _TripsTabPageState();
}

class _TripsTabPageState extends State<_TripsTabPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DynaTripsListCubit>(
      create: (_) => getIt<DynaTripsListCubit>()..initLoad(pageSize: 5),
      child: BlocBuilder<DynaTripsListCubit, DynaTripsListState>(
        builder: (context, state) {
          final cubit = context.read<DynaTripsListCubit>();
          return Column(
            children: [
              Divider(color: ColorsManager.dark100, thickness: 1),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => cubit.initLoad(pageSize: state.pageSize),
                  child: state.loading && state.items.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : state.error != null
                      ? ListView(
                    controller: _scroll,
                    children: [
                      SizedBox(height: 100.h),
                      Center(child: Text(state.error!, style: TextStyles.font14Black500Weight)),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () => cubit.initLoad(pageSize: state.pageSize),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  )
                      : ListView.builder(
                    controller: _scroll,
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                    itemCount: state.items.length + (state.loadingMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= state.items.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }
                      final item = state.items[i];
                      return DynaTripCard(
                        item: item,
                        onDetails: () {
                          // TODO: تفاصيل الرحلة العامة
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}