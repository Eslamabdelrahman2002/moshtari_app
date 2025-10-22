import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/features/service_request/ui/widgets/received_offer_card.dart';

import '../logic/cubit/received_offers_cubit.dart';
import '../logic/cubit/received_offers_state.dart';

class MyReceivedOffersScreen extends StatelessWidget {
  const MyReceivedOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReceivedOffersCubit>(
      create: (_) => getIt<ReceivedOffersCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('العروض المستلمة', style: TextStyles.font20Black500Weight),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: ColorsManager.darkGray300),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocConsumer<ReceivedOffersCubit, ReceivedOffersState>(
          listener: (context, state) {
            // لو فيه خطأ بعد محاولة قبول
            if (state.error != null && !(state.loading)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          builder: (context, state) {
            if (state.loading && state.offers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null && state.offers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('تعذّر جلب العروض', style: TextStyles.font14Black500Weight),
                    SizedBox(height: 6.h),
                    Text(state.error!, style: TextStyles.font12DarkGray400Weight),
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
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                itemCount: state.offers.length,
                itemBuilder: (_, i) {
                  final offer = state.offers[i];
                  return ReceivedOfferCard(
                    offer: offer,
                    isAccepting: state.actingOfferId == offer.offerId,
                    onAccept: () async {
                      final ok = await context.read<ReceivedOffersCubit>().accept(offer.offerId);
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم قبول العرض بنجاح')),
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