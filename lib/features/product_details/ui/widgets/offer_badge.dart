// lib/features/offers/ui/widgets/offer_badge.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import '../../data/model/offer_details.dart';
import '../../data/repo/offers_repo.dart';

String _fmt(num v) {
  final s = v.toString();
  return s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class OfferBadge extends StatelessWidget {
  final num amount;
  const OfferBadge({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: ColorsManager.primary50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: ColorsManager.primary400.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.price_check_rounded, color: ColorsManager.primary400, size: 16.sp),
          SizedBox(width: 6.w),
          Text('﷼ ${_fmt(amount)}', style: TextStyles.font12Primary400400Weight),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: ColorsManager.primary400,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Text('سوم', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class OfferByIdBadge extends StatelessWidget {
  final int offerId;
  const OfferByIdBadge({super.key, required this.offerId});

  @override
  Widget build(BuildContext context) {
    final repo = getIt<OffersRepo>();
    return FutureBuilder<OfferDetails>(
      future: repo.getOfferById(offerId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(
            width: 90.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: ColorsManager.primary50,
              borderRadius: BorderRadius.circular(8.r),
            ),
          );
        }
        if (snap.hasError || !snap.hasData) {
          return const SizedBox.shrink(); // أو Text('—')
        }
        return OfferBadge(amount: snap.data!.amount);
      },
    );
  }
}