import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/service_request/ui/widgets/provider_request_card.dart';

import '../../../service_profile/ui/logic/cubit/provider_cubit.dart';
import '../../../service_profile/ui/logic/cubit/provider_state.dart';
import 'package:mushtary/features/service_profile/data/model/service_request_models.dart';

class MyReceivedOffersScreen extends StatelessWidget {
  const MyReceivedOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProviderCubit>(
      create: (_) => getIt<ProviderCubit>()..loadRequests(),
      child: Scaffold(
        appBar: AppBar(
          title:
          Text('الطلبات المستلمة', style: TextStyles.font20Black500Weight),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon:
            Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocConsumer<ProviderCubit, ProviderState>(
          listener: (context, state) {
            if (state.requestsError != null &&
                !state.requestsLoading &&
                state.requests.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.requestsError!)),
              );
            }
          },
          builder: (context, state) {
            // تحميل أولي
            if (state.requestsLoading && state.requests.isEmpty) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            // خطأ ولم يأتِ أي بيانات
            if (state.requestsError != null && state.requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('تعذّر جلب الطلبات',
                        style: TextStyles.font14Black500Weight),
                    SizedBox(height: 6.h),
                    Text(
                      state.requestsError!,
                      style: TextStyles.font12DarkGray400Weight,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ProviderCubit>().loadRequests(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            // ✅ فلترة الطلبات إلى pending فقط
            final List<ServiceRequest> pendingRequests = state.requests
                .where((r) => r.status == 'pending')
                .toList();

            if (pendingRequests.isEmpty) {
              return const Center(
                child: Text('لا توجد طلبات بانتظار العروض حالياً'),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<ProviderCubit>().loadRequests(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                itemCount: pendingRequests.length,
                itemBuilder: (ctx, i) {
                  final ServiceRequest r = pendingRequests[i];
                  final bool busy =
                      state.isUpdating && state.actingRequestId == r.id;

                  return ProviderRequestCard(
                    request: r,
                    isBusy: busy,
                    onSubmit: (price, message) async {
                      final cubit = ctx.read<ProviderCubit>();
                      final ok = await cubit.submitOffer(
                        requestId: r.id,
                        price: price,
                        message: message,
                      );
                      if (ok && ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('تم إرسال العرض بنجاح'),
                          ),
                        );
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
  }
}