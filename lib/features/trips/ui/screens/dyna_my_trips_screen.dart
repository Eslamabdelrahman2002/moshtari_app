import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';

import '../logic/cubit/dyna_my_trips_cubit.dart';
import '../logic/cubit/dyna_trips_list_state.dart';
import '../widgets/dyna_trip_card.dart';
import 'dyna_trip_create_screen.dart';


class DynaMyTripsScreen extends StatelessWidget {
  const DynaMyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DynaMyTripsCubit>()..initLoad(),
      child: BlocConsumer<DynaMyTripsCubit, DynaTripsListState>(
        listener: (ctx, st) {
          if (st.error != null) {
            ScaffoldMessenger.of(ctx)
                .showSnackBar(SnackBar(content: Text(st.error!)));
          }
        },
        builder: (ctx, st) {
          final cubit = ctx.read<DynaMyTripsCubit>();

          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text('رحلاتي', style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              actions: [
                IconButton(
                  tooltip: 'إضافة رحلة',
                  icon: const Icon(Icons.add_circle_outline, color: ColorsManager.primaryColor),
                  onPressed: () async {
                    final added = await Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => CreateDynaTripScreen(providerId: 1),
                      ),
                    );
                    if (added == true && ctx.mounted) cubit.initLoad();
                  },
                ),
              ],
            ),
            body: st.loading && st.items.isEmpty
                ? const Center(child: CircularProgressIndicator.adaptive())
                : st.error != null && st.items.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('حدث خطأ أثناء تحميل الرحلات'),
                  Text(st.error!, style: const TextStyle(color: Colors.red)),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () => cubit.initLoad(),
                    style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.primaryColor),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () => cubit.initLoad(),
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: st.items.length + (st.loadingMore ? 1 : 0),
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (ctx, i) {
                  if (i >= st.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Center(child: CircularProgressIndicator.adaptive()),
                    );
                  }
                  final item = st.items[i];
                  return DynaTripCard(
                    item: item,
                    busy: st.actingId == item.id,
                    onEdit: () async {
                      final updated = await Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => CreateDynaTripScreen(providerId: item.providerRequestId),
                        ),
                      );
                      if (updated == true && ctx.mounted) cubit.initLoad();
                    },
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: ctx,
                        builder: (_) => AlertDialog(
                          title: const Text('تأكيد الحذف'),
                          content: const Text('هل أنت متأكد من حذف هذه الرحلة؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('إلغاء'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('حذف'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) cubit.deleteTrip(item.id);
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}