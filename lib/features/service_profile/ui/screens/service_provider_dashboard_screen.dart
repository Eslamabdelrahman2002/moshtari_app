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
import 'package:mushtary/features/service_profile/data/model/received_offer.dart';
import 'package:mushtary/features/service_request/ui/logic/cubit/received_offers_state.dart';

import '../../../service_request/ui/logic/cubit/received_offers_cubit.dart';
import '../../../service_request/ui/widgets/received_offer_card.dart';
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
    // 💡 Initial index set to 2 (الأعمال) to match expected flow
    _tab = TabController(length: 3, vsync: this, initialIndex: 2);
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
        appBar: AppBar(
          title: Text("الملف الشخصي", style: TextStyles.font20Black500Weight),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, color: ColorsManager.darkGray300),
          ),
        ),
        body: BlocListener<ProviderCubit, ProviderState>(
          listener: (context, state) {
            final cubit = context.read<ProviderCubit>();

            if (state.updateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث حالة الطلب بنجاح.')),
              );
              cubit.ackUpdateSuccess();
            } else if (state.requestsError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('خطأ في تحديث الحالة: ${state.requestsError}')),
              );
              cubit.clearRequestsError();
            }
          },
          child: BlocBuilder<ProviderCubit, ProviderState>(
            builder: (context, state) {
              if (state.loading && state.provider == null) {
                return const Center(child: CircularProgressIndicator.adaptive());
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
                    SizedBox(height: 10.h),
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

                          // 🔁 هنا بدل أرباحي القديمة بـ MyReceivedOffersTab
                          BlocProvider<ReceivedOffersCubit>(
                            create: (_) => getIt<ReceivedOffersCubit>()..load(),
                            child: const _MyReceivedOffersTab(),
                          ),

                          _WorksTab(
                            state: state,
                            onAccept: (id) => context.read<ProviderCubit>().acceptRequest(id),
                            onReject: (id) => context.read<ProviderCubit>().rejectRequest(id),
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
  final List<ReceivedOffer> items; // عروض مستلمة من الـ API
  final DateFormat df;
  const _EarningsTab({required this.items, required this.df});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('لا توجد أرباح حتى الآن'));
    }

    final total = items.fold<double>(0.0, (sum, o) => sum + o.price);

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      itemCount: items.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Container(
            padding: EdgeInsets.all(12.w),
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('إجمالي الأرباح', style: TextStyles.font14Black500Weight),
                Text(
                  '+${total.toStringAsFixed(0)} رس',
                  style: TextStyle(color: ColorsManager.success500, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          );
        }

        final r = items[i - 1];
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorsManager.whiteGray.withOpacity(.5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: MySvg(image: "money-recive", height: 30, width: 30),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.serviceType.isEmpty ? 'خدمة' : r.serviceType,
                      style: TextStyles.font14Black500Weight,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${df.format(r.createdAt ?? DateTime.now())} • ${r.fullName}',
                      style: TextStyles.font12DarkGray400Weight,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '+${r.price.toStringAsFixed(0)} رس',
                style: TextStyle(color: ColorsManager.success500, fontWeight: FontWeight.w700),
              ),
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

  const _WorksTab({
    required this.state,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (state.requestsLoading && state.requests.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
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
        final isUpdating = state.isUpdating && state.actingRequestId == r.id;

        return ServiceRequestCard(
          req: r,
          isLoading: isUpdating,
          onAccept: () => onAccept(r.id),
          onReject: () => onReject(r.id),
        );
      },
    );
  }
}
class _MyReceivedOffersTab extends StatelessWidget {
  const _MyReceivedOffersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReceivedOffersCubit, ReceivedOffersState>(
      listener: (context, state) {
        if (state.error != null && !state.loading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        if (state.loading && state.offers.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (state.error != null && state.offers.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('تعذّر جلب العروض', style: TextStyles.font14Black500Weight),
                SizedBox(height: 6.h),
                Text(
                  state.error!,
                  style: TextStyles.font12DarkGray400Weight,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: () => context.read<ReceivedOffersCubit>().load(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (state.offers.isEmpty) {
          return const Center(child: Text('لا توجد عروض مستلمة'));
        }

        return RefreshIndicator(
          onRefresh: () => context.read<ReceivedOffersCubit>().load(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            itemCount: state.offers.length,
            itemBuilder: (_, i) {
              final offer = state.offers[i];
              final isBusy = state.actingOfferId == offer.offerId;

              return ReceivedOfferCard(
                offer: offer,
                isBusy: isBusy,
                onAccept: () async {
                  final ok = await context.read<ReceivedOffersCubit>().accept(offer.offerId);
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم قبول العرض بنجاح')),
                    );
                  }
                },
                onReject: () async {
                  final ok = await context.read<ReceivedOffersCubit>().reject(offer.offerId);
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم رفض العرض')),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}