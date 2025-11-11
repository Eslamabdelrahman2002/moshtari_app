import 'dart:developer' as dev;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

import 'package:mushtary/features/home/data/models/home_data_model.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/features/product_details/data/repo/car_auction_repo.dart';
import 'package:mushtary/features/product_details/data/repo/real_estate_auction_repo.dart';

class HomeAuctionListViewItem extends StatefulWidget {
  final HomeAdModel adModel;
  final bool isFavorited;
  final VoidCallback? onFavoriteTap;

  const HomeAuctionListViewItem({
    super.key,
    required this.adModel,
    this.isFavorited = false,
    this.onFavoriteTap,
  });

  @override
  State<HomeAuctionListViewItem> createState() => _HomeAuctionListViewItemState();
}

class _HomeAuctionListViewItemState extends State<HomeAuctionListViewItem> {
  DateTime? _startAt;
  DateTime? _endAt;
  num _highestValue = 0;

  bool _hydrating = false;
  bool _didHydrate = false;

  @override
  void initState() {
    super.initState();
    _startAt = _readDateFlex(widget.adModel, const [
      'startAt','start_at','start_time','startTime','start_date','auctionStartAt','auction_start_at','startDate','start_date'
    ]);
    _endAt = _readDateFlex(widget.adModel, const [
      'endsAt','end_at','end_time','endTime','end_date','auctionEndAt','auction_end_at','endDate','end_date'
    ]);
    final initBid = _readNum(widget.adModel, const [
      'highestBid','maxBid','max_bid','currentBid','current_bid','startPrice','startingPrice','minBidValue','min_bid_value','price'
    ]) ?? 0;
    _highestValue = initBid > 0 ? initBid : 0;

    _debugLog(stage: 'HOME_INITIAL');
    _hydrateFromDetails();
  }

  Future<void> _hydrateFromDetails() async {
    if (_hydrating || _didHydrate) return;
    _hydrating = true;
    try {
      final ad = widget.adModel;
      final auctionId = ad.auctionId ?? ad.id;

      if (ad.categoryId == 1) {
        final repo = getIt<CarAuctionRepo>();
        final a = await repo.getAuctionDetails(auctionId);
        final start = a.startDate;
        final endAt = a.endDate;
        final highest = a.maxBid ?? num.tryParse(a.activeItem.startingPrice ?? '') ?? num.tryParse(a.minBidValue) ?? 0;

        if (!mounted) return;
        setState(() {
          _startAt = start.toLocal();
          _endAt = endAt.toLocal();
          _highestValue = highest > 0 ? highest : _highestValue;
          _didHydrate = true;
        });
      } else if (ad.categoryId == 2) {
        final repo = getIt<RealEstateAuctionRepo>();
        final r = await repo.fetch(auctionId);
        final start = r.startTime;
        final endAt = r.endTime;
        final highest = r.maxBid ?? num.tryParse(r.startPrice) ?? 0;

        if (!mounted) return;
        setState(() {
          _startAt = start?.toLocal();
          _endAt = endAt.toLocal();
          _highestValue = highest > 0 ? highest : _highestValue;
          _didHydrate = true;
        });
      }
    } catch (e, st) {
      _debugLog(stage: 'DETAILS_ERROR', extra: {'error': e.toString(), 'stack': st.toString()});
    } finally {
      _hydrating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final adModel = widget.adModel;

    final hasImage = adModel.imageUrls.isNotEmpty;
    final imageUrl = hasImage ? adModel.imageUrls.first : '';

    // نوع المزاد
    final displayType = (adModel.auctionDisplayType ?? '').toLowerCase();
    final isMultiple = displayType == 'multiple';
    final isSingle   = displayType == 'single';
    final String? dispTypeLabel = isMultiple ? 'مزاد متعدد' : (isSingle ? 'مزاد فردي' : null);

    // الحالة
    final status = _statusByDates(
      startAt: _startAt,
      endAt: _endAt,
      statusText: _readString(widget.adModel, const ['auctionStatus','status']),
    );
    final ended   = status == _AuctionStatus.ended;
    final live    = status == _AuctionStatus.live;
    final upcoming= status == _AuctionStatus.ongoing;

    // الموقع
    final locationText = _readString(widget.adModel, const [
      'city','city_name','cityName','cityNameAr','city_name_ar','location','location_name', 'address'
    ])?.trim() ?? '';

    final locationLabel = locationText.isNotEmpty ? locationText : 'مزاد عبر الإنترنت';

    final rightName = (adModel.username.isNotEmpty ? adModel.username : 'اسم المستخدم');

    final highestText = _highestValue > 0 ? _fmt(_highestValue) : '';
    final statusTextLower = _buildStatusText(ended: ended, live: live, startAt: _startAt, endAt: _endAt);

    final showHighestBar = (!ended && _highestValue > 0);
    final typeBadgeColor = ended
        ? ColorsManager.redButton
        : ColorsManager.success500;

    final auctionId  = adModel.auctionId ?? adModel.id;

    return InkWell(
      onTap: () {
        if (adModel.categoryId == 1) {
          Navigator.of(context).pushNamed(Routes.carAuctionDetailsScreen, arguments: auctionId);
        } else if (adModel.categoryId == 2) {
          Navigator.of(context).pushNamed(Routes.realEstateAuctionDetailsScreen, arguments: auctionId);
        } else {
          Navigator.of(context).pushNamed(Routes.otherAdDetailsScreen, arguments: adModel.id);
        }
      },
      child: Container(
        padding: EdgeInsets.all(10.r),
        margin: EdgeInsets.only(bottom: 14.h, left: 16.w, right: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),

        // **الـ Row الرئيسي: المحتوى النصي يمين، الصورة يسار**
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **1. النصوص والمحتوى (جهة اليمين)**
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // محاذاة كل العناصر لليمين (RTL)
                children: [
                  // **السطر الأول: العنوان فقط**
                  Text(
                    adModel.title.isEmpty ? 'بدون عنوان' : adModel.title,
                    style: TextStyles.font18Black500Weight ?? const TextStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),

                  verticalSpace(8),

                  // **السطر الثاني: الموقع (يمين) + نوع المزاد (يسار)**
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // نوع المزاد (يسار)


                      // الموقع (يمين)
                      Row(
                        children: [
                          MySvg(image: 'location', height: 16, width: 16, color: ColorsManager.darkGray300),
                          horizontalSpace(4),
                          Text(locationLabel, style: TextStyles.font12DarkGray400Weight),


                        ],
                      ),
                      if (dispTypeLabel != null)
                        _typeBadge(
                          dispTypeLabel,
                          typeBadgeColor,
                        ),
                    ],
                  ),

                  verticalSpace(8),

                  // **السطر الثالث: التوقيت/الحالة (يسار) + اسم المستخدم (يمين)**
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (rightName.isNotEmpty)
                        Row(
                          children: [
                            MySvg(image: 'person', width: 14, height: 14, color: ColorsManager.darkGray300),
                            horizontalSpace(4),
                            Text(rightName, style: TextStyles.font12DarkGray400Weight, overflow: TextOverflow.ellipsis),


                          ],
                        ),
                      // التوقيت/الحالة (يسار)
                      if (statusTextLower.isNotEmpty)
                        Row(
                          children: [
                            MySvg(image:  "timer-error" , height: 16, color:  ColorsManager.redButton ),

                            horizontalSpace(4),
                            Text(
                              statusTextLower,
                              style: TextStyle(
                                color:  ColorsManager.redButton ,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                      // اسم المستخدم (يمين)

                    ],
                  ),

                  // **السطر الرابع: أعلى مزايدة (Expand/Full width)**
                  if (showHighestBar) ...[
                    verticalSpace(8),
                    Align(
                      alignment: Alignment.centerRight, // لضمان ظهوره بشكل مناسب في الـ RTL
                      child: _highestBidPill(highestText),
                    ),
                  ],
                ],
              ),
            ),

            horizontalSpace(12),

            // **2. الصورة يسار + منبّه**
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: Container(
                    width: 90.w,
                    height: 100.w,
                    color: Colors.grey.shade200,
                    child: hasImage
                        ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey.shade200),
                      errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.error)),
                    )
                        : Icon(Icons.image_not_supported, color: Colors.grey[400]),
                  ),
                ),
                Positioned(
                  top: 6.h,
                  left: 6.w,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const MySvg(image: 'actions_notification'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // الدوال المساعدة (بدون تغيير)
  void _debugLog({required String stage, Map<String, Object?>? extra}) {
    if (!kDebugMode) return;
    final ad = widget.adModel;
    final map = _asMap(ad);
    final sb = StringBuffer()
      ..writeln('========== [$stage] ==========')
      ..writeln('title: ${ad.title}')
      ..writeln('id: ${ad.id} | auctionId: ${ad.auctionId ?? ad.id} | categoryId: ${ad.categoryId}')
      ..writeln('type: ${ad.auctionDisplayType} | startAt=$_startAt | endAt=$_endAt')
      ..writeln('username: ${ad.username} | image=${ad.imageUrls.isNotEmpty}')
      ..writeln('highest(home): ${_get(map,"highestBid")} | maxBid: ${_get(map,"maxBid")} | currentBid: ${_get(map,"currentBid")} | price: ${ad.price}')
      ..writeln('highest(final): $_highestValue');
    extra?.forEach((k, v) => sb.writeln('$k: ${v?.toString() ?? "null"}'));
    dev.log(sb.toString(), name: 'HOME_SNAPSHOT');
  }

  String _fmt(num? v) {
    if (v == null) return '0';
    final s = v.toString();
    return s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  Widget _typeBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.gavel, size: 14, color: Colors.white),
          horizontalSpace(6),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _highestBidPill(String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [ ColorsManager.primary100,ColorsManager.primary50,ColorsManager.primary100]),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('أعلى مزايدة', style: TextStyles.font12Primary400400Weight),
          horizontalSpace(4),
          MySvg(image: 'send',color: ColorsManager.primaryColor,),
          horizontalSpace(6),
          Text(value, style:  TextStyles.font12Primary400400Weight),
          horizontalSpace(2),
          MySvg(image: 'saudi_riyal', width: 14, height: 14, color:ColorsManager.primary400),
        ],
      ),
    );
  }

  Map<String, dynamic>? _asMap(HomeAdModel m) {
    try {
      final map = (m as dynamic).toJson() as Map?;
      return map?.cast<String, dynamic>();
    } catch (_) {
      return null;
    }
  }

  String? _get(Map<String, dynamic>? map, String key) => map?[key]?.toString();

  DateTime? _readDateFlex(HomeAdModel m, List<String> keys) {
    try {
      final map = (m as dynamic).toJson() as Map?;
      if (map == null) return null;
      for (final k in keys) {
        final v = map[k];
        final d = _parseDateDynamic(v);
        if (d != null) return d;
      }
    } catch (_) {}
    return null;
  }

  DateTime? _parseDateDynamic(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v.toLocal();
    if (v is String) {
      if (v.trim().isEmpty) return null;
      final d = DateTime.tryParse(v);
      if (d != null) return d.toLocal();
      final n = int.tryParse(v);
      if (n != null) return _fromEpoch(n);
    }
    if (v is num) return _fromEpoch(v.toInt());
    return null;
  }

  DateTime _fromEpoch(int n) {
    final isMs = n > 1000000000000;
    return DateTime.fromMillisecondsSinceEpoch(isMs ? n : n * 1000, isUtc: true).toLocal();
  }

  String? _readString(HomeAdModel m, List<String> keys) {
    try {
      final map = (m as dynamic).toJson() as Map?;
      if (map != null) {
        for (final k in keys) {
          final v = map[k];
          if (v != null && v.toString().trim().isNotEmpty) {
            return v.toString();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  num? _readNum(HomeAdModel m, List<String> keys) {
    try {
      final map = (m as dynamic).toJson() as Map?;
      if (map != null) {
        for (final k in keys) {
          final v = map[k];
          if (v is num) return v;
          if (v is String) {
            final cleaned = v.replaceAll(RegExp(r'[^\d\.\-]'), '').replaceAll(',', '');
            final n = num.tryParse(cleaned);
            if (n != null) return n;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  int? _readInt(HomeAdModel m, List<String> keys) => _readNum(m, keys)?.toInt();

  String _categoryLabel(int? id) {
    if (id == 1) return 'سيارات';
    if (id == 2) return 'عقارات';
    return 'أخرى';
  }

  String _categorySingular(int? id) {
    if (id == 1) return 'سيارة';
    if (id == 2) return 'عقار';
    return 'عنصر';
  }

  String _arabicNumber(int n) => NumberFormat.decimalPattern('ar').format(n);

  String _buildStatusText({
    required bool ended,
    required bool live,
    required DateTime? startAt,
    required DateTime? endAt,
  }) {
    final now = DateTime.now();
    if (ended) return 'منتهي';
    if (live) {
      if (endAt != null && endAt.isAfter(now)) {
        return _timeLeftString(endAt);
      }
      return 'جار';
    }
    if (startAt != null && startAt.isAfter(now)) {
      final diff = startAt.difference(now);
      return 'يبدأ بعد ${_formatDiff(diff)}';
    }
    return '';
  }

  String _timeLeftString(DateTime end) {
    final now = DateTime.now();
    if (end.isBefore(now)) return 'منتهي';
    final diff = end.difference(now);
    return _formatDiff(diff);
  }

  String _formatDiff(Duration diff) {
    final d = diff.inDays;
    final h = diff.inHours % 24;
    final m = diff.inMinutes % 60;
    final parts = <String>[];
    if (d > 0) parts.add('$d يوم');
    if (h > 0 || d > 0) parts.add('$h ساعة');
    parts.add('$m دقيقة');
    return parts.join(' ');
  }
}

enum _AuctionStatus { live, ongoing, ended }

_AuctionStatus _statusByDates({
  DateTime? startAt,
  DateTime? endAt,
  String? statusText,
}) {
  final now = DateTime.now();
  final s = statusText?.toLowerCase().trim();
  if (s == 'ended' || s == 'finished' || s == 'closed') return _AuctionStatus.ended;
  if (s == 'live' || s == 'running' || s == 'in_progress' || s == 'active' || s == 'open') return _AuctionStatus.live;
  if (s == 'upcoming' || s == 'scheduled' || s == 'pending') return _AuctionStatus.ongoing;

  if (endAt != null && endAt.isBefore(now)) return _AuctionStatus.ended;
  if (startAt != null && startAt.isBefore(now) && (endAt == null || endAt.isAfter(now))) return _AuctionStatus.live;
  return _AuctionStatus.ongoing;
}