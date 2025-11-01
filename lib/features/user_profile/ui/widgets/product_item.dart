import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/navigation.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';

import '../../../user_profile/logic/cubit/profile_cubit.dart';

import '../../data/model/auction_details_model.dart';
import '../../data/model/my_ads_model.dart';
import '../../data/model/my_auctions_model.dart';
import '../../data/repo/ads_repo.dart';
import '../../data/repo/my_auctions_repo.dart';
import 'auction_review_card.dart';
class ProductItem extends StatelessWidget {
  final Object model; // MyAdsModel أو MyAuctionModel
  const ProductItem({super.key, required this.model});

  // ---------------- Helpers ----------------
  String _fmtNum(num v) =>
      v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  String _fmtPrice(String? s) {
    if (s == null || s.isEmpty) return '';
    final n = num.tryParse(s.replaceAll(',', ''));
    return n == null ? s : _fmtNum(n);
  }

  String _timeAgo(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    DateTime? dt;
    try {
      dt = DateTime.parse(iso).toLocal();
    } catch (_) {}
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return '${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return '${diff.inHours} ساعة';
    return '${diff.inDays} يوم';
  }

  String _categoryLabel(Object m) {
    if (m is MyAuctionModel) {
      switch (m.typeAuctions) {
        case 'car':
          return 'سيارات';
        case 'real_estate':
          return 'عقارات';
        default:
          return 'مزاد';
      }
    } else if (m is MyAdsModel) {
      const map = {
        5: 'سيارات',
        1: 'سيارات',
        2: 'قطع غيار',
        3: 'عقارات',
        4: 'أخرى',
      };
      return map[m.categoryId] ?? 'إعلان';
    }
    return '';
  }

  // NEW: نوع الإعلان للحذف حسب categoryId
  String? _adTypeForDelete(MyAdsModel ad) {
    switch (ad.categoryId) {
      case 5:
      case 1:
        return 'car';          // {{base_url}}/api/car-ads/{id}
      case 2:
        return 'car_part';     // {{base_url}}/api/car-part-ads/car-part-ads/{id}
      case 3:
        return 'real_estate';  // {{base_url}}/api/real-estate-ads/{id}
      case 4:
        return 'other';        // {{base_url}}/api/other-ads/{id}
      default:
        return null;
    }
  }

  IconData _categoryIcon(Object m) {
    final label = _categoryLabel(m);
    if (label == 'سيارات') return Icons.directions_car_filled_rounded;
    if (label == 'عقارات') return Icons.home_work_rounded;
    if (label == 'قطع غيار') return Icons.build_rounded;
    return Icons.category_rounded;
  }

  void _openDetails(BuildContext context) {
    if (model is MyAdsModel) {
      final m = model as MyAdsModel;
      final id = m.id;
      switch (m.categoryId) {
        case 5:
        case 1:
          NavX(context).pushNamed(Routes.carDetailsScreen, arguments: id);
          break;
        case 2:
          NavX(context).pushNamed(Routes.carPartDetailsScreen, arguments: id);
          break;
        case 3:
          NavX(context).pushNamed(Routes.realEstateDetailsScreen, arguments: id);
          break;
        case 4:
        default:
          NavX(context).pushNamed(Routes.otherAdDetailsScreen, arguments: id);
      }
    } else if (model is MyAuctionModel) {
      _showAuctionDialog(context, model as MyAuctionModel);
    }
  }

  void _showAuctionDialog(BuildContext context, MyAuctionModel m) {
    showDialog(
      context: context,
      builder: (ctx) {
        final repo = getIt<MyAuctionsRepo>();
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: FutureBuilder<AuctionDetailsModel>(
            future: repo.fetchDetails(id: m.id, auctionType: m.typeAuctions),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return SizedBox(height: 220.h, child: const Center(child: CircularProgressIndicator.adaptive()));
              }
              if (snap.hasError || !snap.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('تعذر جلب تفاصيل المزاد: ${snap.error ?? ''}'),
                );
              }

              final d = snap.data!;
              final participantsCount = d.items.length;
              final highestBid = d.maxBid ?? 0;
              final firstItem = d.items.isNotEmpty ? d.items.first : null;
              final imageUrl = (firstItem?.thumbnail.isNotEmpty ?? false)
                  ? firstItem!.thumbnail
                  : m.thumbnail;

              final location = [
                if ((firstItem?.cityName ?? '').isNotEmpty) firstItem!.cityName,
                if ((firstItem?.regionName ?? '').isNotEmpty) firstItem!.regionName,
              ].whereType<String>().where((e) => e.isNotEmpty).join(' - ');

              Duration remainingTime = Duration.zero;
              final endStr = firstItem?.expiresAt;
              if (endStr != null && endStr.isNotEmpty) {
                try {
                  final end = DateTime.parse(endStr).toLocal();
                  final diff = end.difference(DateTime.now());
                  remainingTime = diff.isNegative ? Duration.zero : diff;
                } catch (_) {}
              }

              final carTypeDetails = m.typeAuctions == 'real_estate'
                  ? 'عقارات (${d.items.length})'
                  : 'سيارات (${d.items.length})';

              bool submitting = false;
              final int itemId = firstItem?.id ?? 0;
              final String auctionType = m.typeAuctions;
              final int auctionId = m.id;

              return StatefulBuilder(
                builder: (sbCtx, setSB) {
                  Future<void> _handleAction({required bool accept}) async {
                    if (itemId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تعذر تحديد عنصر المزاد (item_id)')),
                      );
                      return;
                    }
                    setSB(() => submitting = true);
                    try {
                      final res = await repo.approveAuction(
                        auctionId: auctionId,
                        auctionType: auctionType,
                        itemId: itemId,
                        action: accept ? 'accept' : 'reject',
                      );
                      if (Navigator.of(sbCtx).canPop()) Navigator.of(sbCtx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res.message.isNotEmpty ? res.message : (accept ? 'تم قبول المزاد' : 'تم رفض المزاد'))),
                      );
                    } catch (e) {
                      setSB(() => submitting = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                      );
                    }
                  }

                  return SingleChildScrollView(
                    child: AuctionReviewCard(
                      title: m.title.isNotEmpty ? m.title : 'مزاد #${d.id}',
                      imageUrl: imageUrl,
                      participantsCount: participantsCount,
                      highestBid: highestBid,
                      carTypeDetails: carTypeDetails,
                      location: location,
                      remainingTime: remainingTime,
                      isLoading: submitting,
                      onAccept: () => _handleAction(accept: true),
                      onReject: () => _handleAction(accept: false),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // NEW: BottomSheet حذف الإعلان (من دون رقم جوال)
  void _showDeleteAdSheet(BuildContext context, MyAdsModel ad) {
    final adsRepo = getIt<AdsRepo>();
    final adType = _adTypeForDelete(ad);

    if (adType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نوع الإعلان غير مدعوم للحذف')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        bool submitting = false;

        return StatefulBuilder(
          builder: (ctx, setSB) => Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h + bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(100))),
                verticalSpace(12),
                Row(
                  children: [
                    Container(
                      width: 40.w, height: 40.w,
                      decoration: BoxDecoration(color: ColorsManager.errorColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.delete_outline, color: ColorsManager.errorColor),
                    ),
                    horizontalSpace(10),
                    Expanded(child: Text('حذف الإعلان', style: TextStyles.font18Black500Weight)),
                  ],
                ),
                verticalSpace(8),
                Text(
                  'هل أنت متأكد من حذف هذا الإعلان؟ لا يمكن التراجع عن هذه العملية.',
                  style: TextStyles.font12DarkGray400Weight,
                  textAlign: TextAlign.center,
                ),
                verticalSpace(16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: submitting ? null : () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('إلغاء', style: TextStyles.font14Black500Weight),
                      ),
                    ),
                    horizontalSpace(12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: submitting
                            ? null
                            : () async {
                          setSB(() => submitting = true);
                          try {
                            await adsRepo.deleteAd(adType: adType, id: ad.id);
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم حذف الإعلان بنجاح')),
                              );
                              context.read<ProfileCubit>().loadProfile();
                            }
                          } catch (e) {
                            setSB(() => submitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsManager.errorColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: Size(double.infinity, 46.h),
                        ),
                        icon: const Icon(Icons.delete_rounded),
                        label: Text(submitting ? 'جاري الحذف...' : 'حذف'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuction = model is MyAuctionModel;
    final category = _categoryLabel(model);
    final categoryIcon = _categoryIcon(model);

    String title = '';
    String createdAt = '';
    String priceText = '';
    String? imageUrl;

    if (model is MyAdsModel) {
      final m = model as MyAdsModel;
      title = m.title;
      createdAt = m.createdAt;
      priceText = _fmtPrice(m.price);
      imageUrl = m.imageUrls.isNotEmpty ? m.imageUrls.first : null;
    } else if (model is MyAuctionModel) {
      final m = model as MyAuctionModel;
      title = m.title;
      createdAt = m.createdAt;
      priceText = _fmtPrice(m.startingPrice);
      imageUrl = m.thumbnail.isNotEmpty ? m.thumbnail : null;
    }

    return InkWell(
      onTap: () => _openDetails(context),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 11 / 9,
                    child: imageUrl == null || imageUrl.isEmpty
                        ? Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported))
                        : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator.adaptive()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  Positioned(
                    left: 8.w,
                    top: 8.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: ColorsManager.secondary50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: ColorsManager.secondary200),
                      ),
                      child: Row(
                        children: [
                          Icon(categoryIcon, size: 14, color: ColorsManager.secondary600),
                          horizontalSpace(4),
                          Text(category, style: TextStyles.font10Yellow400Weight),
                        ],
                      ),
                    ),
                  ),
                  // زر الحذف - فقط للإعلانات وليس المزادات
                  if (!isAuction)
                    Positioned(
                      right: 8.w,
                      top: 8.h,
                      child: InkWell(
                        onTap: () => _showDeleteAdSheet(context, model as MyAdsModel),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: ColorsManager.errorColor.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: ColorsManager.errorColor.withOpacity(0.25), blurRadius: 8)],
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // العنوان
            Padding(
              padding: EdgeInsets.only(top: 8.h, right: 10.w, left: 10.w),
              child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyles.font14Black500Weight),
            ),

            // الصف السفلي
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 10.h),
              child: Row(
                children: [
                  Row(
                    children: [
                      MySvg(image: 'clock', width: 14.w, height: 14.w),
                      horizontalSpace(4),
                      Text(_timeAgo(createdAt), style: TextStyles.font10Dark600Grey400Weight),
                    ],
                  ),
                  const Spacer(),
                  if (!isAuction) ...[
                    Row(
                      children: [
                        Text('﷼ ', style: TextStyles.font10Secondary500700Weight),
                        Text(priceText, style: TextStyles.font10Secondary500700Weight),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      height: 34.h,
                      child: OutlinedButton(
                        onPressed: () => _showAuctionDialog(context, model as MyAuctionModel),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          side: BorderSide(color: ColorsManager.primary200),
                          foregroundColor: ColorsManager.primary400,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                        child: Text('عرض التفاصيل', style: TextStyles.font12Blue400Weight),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}