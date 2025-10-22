// lib/features/services/ui/screens/dinat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/sliver_app_bar_delegate.dart';
import 'package:mushtary/features/services/ui/widgets/dinat_grid_view.dart';
import 'package:mushtary/features/services/ui/widgets/dinat_section_header.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';

import '../../logic/cubit/dyna_trips_cubit.dart';
import '../../logic/cubit/dyna_trips_state.dart';

class DinatScreen extends StatefulWidget {
  const DinatScreen({super.key});

  @override
  State<DinatScreen> createState() => _DinatScreenState();
}

class _DinatScreenState extends State<DinatScreen> {
  bool isListView = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DynaTripsCubit>(
      create: (_) => getIt<DynaTripsCubit>()..loadInitial(),
      child: BlocBuilder<DynaTripsCubit, DynaTripsState>(
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

              // حالة التحميل
              if (state is DynaTripsLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),

              // حالة الخطأ
              if (state is DynaTripsFailure)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(child: Text('تعذر جلب الرحلات: ${state.error}')),
                  ),
                ),

              // حالة النجاح
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
  }
}