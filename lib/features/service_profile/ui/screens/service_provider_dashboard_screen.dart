import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

import '../logic/cubit/provider_cubit.dart';
import '../logic/cubit/provider_state.dart';
import '../widgets/provider_header_card.dart';
import '../widgets/service_request_card.dart';


class ServiceProviderDashboardScreen extends StatefulWidget {
  final int providerId;
  const ServiceProviderDashboardScreen({super.key, required this.providerId});

  @override
  State<ServiceProviderDashboardScreen> createState() => _ServiceProviderDashboardScreenState();
}

class _ServiceProviderDashboardScreenState extends State<ServiceProviderDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProviderCubit>(
      create: (_) => getIt<ProviderCubit>()..loadAll(widget.providerId),
      child: Scaffold(
        body: BlocListener<ProviderCubit, ProviderState>(
          listener: (context, state) {
            // استخدام الخصائص المحدثة
            if (state.updateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث حالة الطلب بنجاح.')),
              );
              // reset updateSuccess flag after showing snackbar
              context.read<ProviderCubit>().emit(state.copyWith(updateSuccess: false));

            } else if (state.requestsError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('خطأ في تحديث الحالة: ${state.requestsError}')),
              );
              // reset requestsError flag after showing snackbar
              context.read<ProviderCubit>().emit(state.copyWith(clearRequestsError: true));
            }
          },
          child: BlocBuilder<ProviderCubit, ProviderState>(
            builder: (context, state) {
              if (state.loading && state.provider == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.error != null) {
                return Center(child: Text(state.error!, style: TextStyles.font14Black500Weight));
              }

              final provider = state.provider!;
              final jobsCount = state.requests.length;
              final favoritesCount = 0; // placeholder

              return SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 10.h,),
                    ProviderHeaderCard(
                      provider: provider,
                      favoritesCount: favoritesCount,
                      jobsCount: jobsCount,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: SegmentedTabs(
                        controller: _tab,
                        tabs: const ['تقييمات معلقة', 'أرباحي', 'أعمالي'],
                      ),
                    ),
                    Divider(color: ColorsManager.dark100, thickness: 1),
                    Expanded(
                      child: TabBarView(
                        controller: _tab,
                        children: [
                          _PendingReviewsTab(comments: provider.comments),
                          _EarningsTab(
                            items: state.requests.where((r) => r.status == 'completed').toList(),
                            df: DateFormat('dd/MM/yyyy'),
                          ),
                          _WorksTab(
                            state: state,
                            // الأزرار مربوطة باستدعاء دالة updateRequestStatus في Cubit
                            onAccept: (id) => context.read<ProviderCubit>().updateRequestStatus(id, 'in_progress'),
                            onReject: (id) => context.read<ProviderCubit>().updateRequestStatus(id, 'rejected'),
                            onComplete: (id) => context.read<ProviderCubit>().updateRequestStatus(id, 'completed'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SegmentedTabs extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  const SegmentedTabs({super.key, required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: ColorsManager.dark200),
          ),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final selected = controller.index == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.animateTo(i),
                  child: Container(
                    height: 36.h,
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: selected ? ColorsManager.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: selected ? null : Border.all(color: ColorsManager.dark200),
                    ),
                    child: Text(
                      tabs[i],
                      style: TextStyle(
                        color: selected ? Colors.white : ColorsManager.darkGray,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _EarningsTab extends StatelessWidget {
  final List items; // completed requests
  final DateFormat df;
  const _EarningsTab({required this.items, required this.df});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('لا توجد أرباح حتى الآن'));
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final r = items[i];
        return Container(
          padding: EdgeInsets.all(12.w),
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: ColorsManager.whiteGray.withOpacity(.5),
                    borderRadius: BorderRadius.circular(50)
                ),

                child: MySvg(image: "money-recive",height: 30,width: 30,),
              ),
              SizedBox(width: 8.w,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('خدمات مشترك', style: TextStyles.font14Black500Weight),
                  SizedBox(height: 4.h),
                  Text(df.format(r.createdAt ?? DateTime.now()), style: TextStyles.font12DarkGray400Weight),
                ],
              ),
              Spacer(),
              Text('+350 رس', style: TextStyle(color: ColorsManager.success500, fontWeight: FontWeight.w700)),

            ],
          ),
        );
      },
    );
  }
}

class _PendingReviewsTab extends StatelessWidget {
  final List comments;
  const _PendingReviewsTab({required this.comments});

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Center(child: Text('لا توجد تقييمات معلّقة'));
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      itemCount: comments.length,
      itemBuilder: (_, i) {
        final c = comments[i];
        return Container(
          padding: EdgeInsets.all(12.w),
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: Colors.grey[200],
                backgroundImage: (c.user.personalImage?.isNotEmpty == true)
                    ? CachedNetworkImageProvider(c.user.personalImage!)
                    : null,
                child: (c.user.personalImage?.isNotEmpty ?? false) ? null : const Icon(Icons.person, color: Colors.grey),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.user.name, style: TextStyles.font14Black500Weight),
                    SizedBox(height: 4.h),
                    Text(c.comment, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyles.font12DarkGray400Weight),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              OutlinedButton(
                onPressed: () {
                  // TODO: نشر التقييم
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ColorsManager.primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text('نشر', style: TextStyle(color: ColorsManager.primaryColor, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorksTab extends StatelessWidget {
  final ProviderState state;
  final Function(int id) onAccept;
  final Function(int id) onReject;
  final Function(int id) onComplete;

  const _WorksTab({
    required this.state,
    required this.onAccept,
    required this.onReject,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (state.requestsLoading && state.requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.requestsError != null) {
      return Center(child: Text(state.requestsError!));
    }
    if (state.requests.isEmpty) {
      return const Center(child: Text('لا توجد طلبات حتى الآن'));
    }
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 16.h),
      itemCount: state.requests.length,
      itemBuilder: (_, i) {
        final r = state.requests[i];
        return ServiceRequestCard(
          req: r,
          onAccept: () => onAccept(r.id),
          onReject: () => onReject(r.id),
          onComplete: () => onComplete(r.id),
        );
      },
    );
  }
}