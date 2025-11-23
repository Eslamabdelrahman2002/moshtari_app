import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/my_requests/ui/screens/widgets/request_card.dart';

import '../../../services/logic/cubit/service_offer_cubit.dart';
import '../../model/data/my_requests_models.dart';
import '../cubit/my_requests_cubit.dart';
import '../cubit/my_requests_state.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  static const _filters = ['all', 'dyna', 'flatbed', 'tanker'];

  int _indexFromFilter(String f) {
    switch (f) {
      case 'dyna':
        return 1;
      case 'flatbed':
        return 2;
      case 'tanker':
        return 3;
      default:
        return 0; // all
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // طلباتي
        BlocProvider<MyRequestsCubit>(
          create: (_) => getIt<MyRequestsCubit>()..load(),
        ),
        // ✅ Cubit خاص بالعروض: قبول/رفض
        BlocProvider<ServiceOffersCubit>(
          create: (_) => getIt<ServiceOffersCubit>(),
        ),
      ],
      child: BlocBuilder<MyRequestsCubit, MyRequestsState>(
        builder: (context, state) {
          final cubit = context.read<MyRequestsCubit>();
          final offersState = context.watch<ServiceOffersCubit>().state;

          int _requestsCount(Iterable<ServiceRequestItem> list, {String? type}) {
            final it =
            (type == null) ? list : list.where((r) => r.serviceType == type);
            return it.length;
          }

          final countAll = _requestsCount(state.requests);
          final countDyna = _requestsCount(state.requests, type: 'dyna');
          final countFlat = _requestsCount(state.requests, type: 'flatbed');
          final countTank = _requestsCount(state.requests, type: 'tanker');

          final initialIndex = _indexFromFilter(state.serviceFilter);

          return DefaultTabController(
            length: 4,
            initialIndex: initialIndex,
            child: Scaffold(
              appBar: AppBar(
                title: Text('طلباتي', style: TextStyles.font20Black500Weight),
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      color: ColorsManager.darkGray300),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(48.h),
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: TabBar(
                      onTap: (i) => cubit.setFilter(_filters[i]),
                      indicatorColor: ColorsManager.primaryColor,
                      labelColor: ColorsManager.primaryColor,
                      unselectedLabelColor: ColorsManager.darkGray300,
                      isScrollable: true,
                      tabs: [
                        Tab(text: 'الكل${countAll > 0 ? ' ($countAll)' : ''}'),
                        Tab(text: 'دينّا${countDyna > 0 ? ' ($countDyna)' : ''}'),
                        Tab(text: 'سطحه${countFlat > 0 ? ' ($countFlat)' : ''}'),
                        Tab(
                          text:
                          'صهريج ماء${countTank > 0 ? ' ($countTank)' : ''}',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: BlocConsumer<MyRequestsCubit, MyRequestsState>(
                listener: (context, st) {
                  if (st.error != null && !st.loading) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(st.error!)),
                    );
                  }
                },
                builder: (context, st) {
                  // ✅ فلترة الطلبات حسب نوع الخدمة
                  final filteredReqs = st.serviceFilter == 'all'
                      ? st.requests
                      : st.requests
                      .where((r) => r.serviceType == st.serviceFilter)
                      .toList();

                  if (st.loading && st.requests.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }

                  if (st.error != null && st.requests.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('تعذّر جلب الطلبات',
                              style: TextStyles.font14Black500Weight),
                          SizedBox(height: 6.h),
                          Text(
                            st.error!,
                            style: TextStyles.font12DarkGray400Weight,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<MyRequestsCubit>().load(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (filteredReqs.isEmpty) {
                    return const Center(
                        child: Text('لا توجد طلبات في هذه الفئة'));
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<MyRequestsCubit>().load(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding:
                      EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                      itemCount: filteredReqs.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (ctx, i) {
                        final it = filteredReqs[i];

                        return RequestCard(
                          request: it,

                          // ✅ استخدم actingOfferId من ServiceOffersCubit
                          actingOfferId: offersState.actingOfferId,

                          onAccept: (offerId) async {
                            final offersCubit =
                            ctx.read<ServiceOffersCubit>();
                            final ok = await offersCubit.accept(offerId);
                            if (ok && ctx.mounted) {
                              // إعادة تحميل الطلبات لتحديث حالة العرض/الطلب
                              await ctx
                                  .read<MyRequestsCubit>()
                                  .load();
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content: Text('تم قبول العرض')),
                              );
                            } else if (ctx.mounted) {
                              final err = offersCubit.state.error;
                              if (err != null) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text(err)),
                                );
                              }
                            }
                          },

                          onReject: (offerId) async {
                            final offersCubit =
                            ctx.read<ServiceOffersCubit>();
                            final ok = await offersCubit.reject(offerId);
                            if (ok && ctx.mounted) {
                              await ctx
                                  .read<MyRequestsCubit>()
                                  .load();
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content: Text('تم رفض العرض')),
                              );
                            } else if (ctx.mounted) {
                              final err = offersCubit.state.error;
                              if (err != null) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text(err)),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
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