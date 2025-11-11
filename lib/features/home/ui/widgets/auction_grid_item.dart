import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/features/home/data/models/home_data_model.dart';
import 'package:mushtary/features/home/ui/widgets/list_view_item_data_widget.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/router/routes.dart';
import 'package:mushtary/core/dependency_injection/injection_container.dart';

// نفس ريبو التفاصيل المستخدمة في الليست
import 'package:mushtary/features/product_details/data/repo/car_auction_repo.dart';
import 'package:mushtary/features/product_details/data/repo/real_estate_auction_repo.dart';

class AuctionGridItem extends StatefulWidget {
  final HomeAdModel adModel;
  final bool isFavorited;
  final VoidCallback? onFavoriteTap;

  const AuctionGridItem({
    super.key,
    required this.adModel,
    this.isFavorited = false,
    this.onFavoriteTap,
  });

  @override
  State<AuctionGridItem> createState() => _AuctionGridItemState();
}

class _AuctionGridItemState extends State<AuctionGridItem> {
  DateTime? _startAt;
  DateTime? _endAt;
  num _highestValue = 0;

  bool _hydrating = false;
  bool _didHydrate = false;

  @override
  void initState() {
    super.initState();
    // قيم مبدئية من الـ Home payload
    _startAt = _readDateFlex(widget.adModel, const [
      'startAt','start_at','start_time','startTime','start_date','auctionStartAt','auction_start_at','startDate'
    ]);
    _endAt = _readDateFlex(widget.adModel, const [
      'endsAt','end_at','end_time','endTime','end_date','auctionEndAt','auction_end_at','endDate'
    ]);

    final initBid = _readNum(widget.adModel, const [
      'highestBid','maxBid','max_bid','currentBid','current_bid','startPrice','startingPrice','minBidValue','min_bid_value','price'
    ]) ?? 0;
    _highestValue = initBid > 0 ? initBid : 0;

    _debugLog(stage: 'GRID_HOME_INITIAL');
    _hydrateFromDetails();
  }

  Future<void> _hydrateFromDetails() async {
    if (_hydrating || _didHydrate) return;
    _hydrating = true;
    try {
      final ad = widget.adModel;
      final auctionId = ad.auctionId ?? ad.id;

      if (ad.categoryId == 1) {
        _debugLog(stage: 'GRID_CAR_CALL', extra: {'auctionId': auctionId});
        final repo = getIt<CarAuctionRepo>();
        final a = await repo.getAuctionDetails(auctionId);

        final start = a.startDate;
        final endAt = a.endDate;
        final highest = a.maxBid
            ?? num.tryParse(a.activeItem.startingPrice ?? '')
            ?? num.tryParse(a.minBidValue) ?? 0;

        if (!mounted) return;
        setState(() {
          _startAt = start.toLocal();
          _endAt = endAt.toLocal();
          _highestValue = highest > 0 ? highest : _highestValue;
          _didHydrate = true;
        });

        _debugLog(stage: 'GRID_CAR_DETAILS', extra: {
          'a.startDate': start.toIso8601String(),
          'a.endDate': endAt.toIso8601String(),
          'a.maxBid': a.maxBid,
          'a.minBidValue': a.minBidValue,
          'a.activeItem.startingPrice': a.activeItem.startingPrice,
        });

      } else if (ad.categoryId == 2) {
        _debugLog(stage: 'GRID_REA_CALL', extra: {'auctionId': auctionId});
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

        _debugLog(stage: 'GRID_REA_DETAILS', extra: {
          'r.startTime': start?.toIso8601String(),
          'r.endTime': endAt.toIso8601String(),
          'r.maxBid': r.maxBid,
          'r.startPrice': r.startPrice,
        });
      }
    } catch (e, st) {
      _debugLog(stage: 'GRID_DETAILS_ERROR', extra: {'error': e.toString(), 'stack': st.toString()});
    } finally {
      _hydrating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final adModel = widget.adModel;

    // صورة
    final hasImage = adModel.imageUrls.isNotEmpty;
    final imageUrl = hasImage ? adModel.imageUrls.first : '';

    // نوع المزاد
    final displayType = (adModel.auctionDisplayType ?? '').toLowerCase();
    final isMultiple = displayType == 'multiple';
    final isSingle = displayType == 'single';
    final typeLabel = isMultiple ? 'مزاد متعدد' : (isSingle ? 'مزاد فردي' : null);

    // حالة
    final status = _statusByDates(
      startAt: _startAt,
      endAt: _endAt,
      statusText: _readString(adModel, const ['auctionStatus','status']),
    );
    final ended   = status == _AuctionStatus.ended;
    final live    = status == _AuctionStatus.live;
    final upcoming= status == _AuctionStatus.ongoing;

    // المدينة/المستخدم
    final city = _readString(adModel, const [
      'city','city_name','cityName','cityNameAr','city_name_ar','location','location_name'
    ])?.trim() ?? '';
    final username = adModel.username.isNotEmpty ? adModel.username : 'المستخدم';
    final rightName = city.isNotEmpty ? city : username;

    // أعلى مزايدة (نستخدم قيمة رقمية بعد الـ snapshot)
    final showHighest = (!ended && _highestValue > 0);
    final highestBidText = showHighest ? _fmt(_highestValue) : 'N/A';

    // لون بادج النوع (طلبت أخضر أثناء السريان)
    Color typeColor;
    if (ended)      typeColor = ColorsManager.redButton;
    else if (live)  typeColor = ColorsManager.success500; // أخضر عند السريان
    else            typeColor = ColorsManager.primary400; // محايد للقادم

    // نص الحالة أسفل (يسار)
    final statusBottom = ended
        ? 'منتهي'
        : (live
        ? _timeLeftString(_endAt) ?? ''
        : (_startAt != null && _startAt!.isAfter(DateTime.now())
        ? 'يبدأ بعد ${_formatDiff(_startAt!.difference(DateTime.now()))}'
        : ''));

    return InkWell(
      onTap: () {
        final auctionId = adModel.auctionId ?? adModel.id;
        if (adModel.categoryId == 1) {
          Navigator.of(context).pushNamed(Routes.carAuctionDetailsScreen, arguments: auctionId);
        } else if (adModel.categoryId == 2) {
          Navigator.of(context).pushNamed(Routes.realEstateAuctionDetailsScreen, arguments: auctionId);
        } else {
          Navigator.of(context).pushNamed(Routes.otherAdDetailsScreen, arguments: adModel.id);
        }
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16.r, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة + أوفريليز
            Expanded(
              child: Stack(
                children: [
                  // Image
                  SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: hasImage
                          ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: ColorsManager.grey200),
                        errorWidget: (_, __, ___) => Container(color: ColorsManager.grey200, child: const Icon(Icons.error)),
                      )
                          : Container(color: ColorsManager.grey200, child: Icon(Icons.image_not_supported, color: Colors.grey[400])),
                    ),
                  ),

                  // جرس
                  Positioned(
                    top: 6.h,
                    left: 6.w,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: const MySvg(image: 'actions_notification'),
                    ),
                  ),

                  // بادج النوع
                  if (typeLabel != null)
                    Positioned(
                      top: 6.h,
                      right: 6.w,
                      child: _typeBadge(typeLabel, typeColor),
                    ),

                  // وقت متبقي (داخل الصورة) عند live
                  if (live && _endAt != null)
                    Positioned(
                      left: 8.w,
                      right: 8.w,
                      bottom: 6.h,
                      child: _timeOverlay(_timeLeftString(_endAt!) ?? '...'),
                    ),

                  // منتهي: تغطية حمراء ونص
                  if (ended)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text('منتهي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16.sp)),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            verticalSpace(8),
            // العنوان
            Text(
              adModel.title.isEmpty ? 'بدون عنوان' : adModel.title,
              style: TextStyles.font12Black400Weight?.copyWith(fontWeight: FontWeight.w800) ?? TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            verticalSpace(6),

            // سطر: المدينة + اسم المستخدم
            Row(
              children: [
                Expanded(
                  child: ListViewItemDataWidget(image: 'location-dark', text: city.isNotEmpty ? city : '-'),
                ),
                horizontalSpace(8),
                Expanded(
                  child: ListViewItemDataWidget(image: 'user', text: username),
                ),
              ],
            ),

            verticalSpace(6),

            // شريط أعلى مزايدة (داخل الكارت) — الآن يعتمد على القيمة الرقمية + not ended
            if (showHighest)
              Row(
                children: [
                  Expanded(child: _highestBidBottomPill(highestBidText)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Widgets صغيرة
  Widget _typeBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.gavel, size: 14, color: Colors.white),
          horizontalSpace(6),
          Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _timeOverlay(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MySvg(image:"timer-error",height: 14, color: Colors.white),
          horizontalSpace(5.w),
          Text(text, style: TextStyles.font10White500Weight),

        ],
      ),
    );
  }

  Widget _highestBidBottomPill(String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [ ColorsManager.primary100,ColorsManager.primary50,ColorsManager.primary100]),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('أعلى مزايدة', style: TextStyles.font10Primary400Weight),
          horizontalSpace(2),
          MySvg(image: 'send',color: ColorsManager.primaryColor,),
          Spacer(),
          Text(value, style:  TextStyles.font12Primary400400Weight,overflow: TextOverflow.ellipsis,),
          horizontalSpace(2),
          MySvg(image: 'saudi_riyal', width: 14, height: 14, color:ColorsManager.primary400),
        ],
      ),
    );
  }

  // Helpers (نفس الـ list)
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
    dev.log(sb.toString(), name: 'GRID_SNAPSHOT');
  }

  String _fmt(num v) => NumberFormat.decimalPattern('ar').format(v);

  String? _readString(HomeAdModel m, List<String> keys) {
    try {
      final map = (m as dynamic).toJson() as Map?;
      if (map != null) {
        for (final k in keys) {
          final v = map[k]?.toString();
          if (v != null) return v;
        }
      }
    } catch (_) {}
    return null;
  }

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

  String? _timeLeftString(DateTime? end) {
    if (end == null) return null;
    final now = DateTime.now();
    if (end.isBefore(now)) return null;
    return _formatDiff(end.difference(now));
  }

  String _formatDiff(Duration diff) {
    final d = diff.inDays;
    final h = diff.inHours % 24;
    final m = diff.inMinutes % 60;
    final parts = <String>[];
    if (d > 0) parts.add('$d يوم');
    parts.add('$h ساعة');
    parts.add('$m دقيقة');
    return parts.join(' ');
  }

  Map<String, dynamic>? _asMap(HomeAdModel m) {
    try {
      final map = (m as dynamic).toJson() as Map?;
      return map?.cast<String, dynamic>();
    } catch (_) { return null; }
  }

  String? _get(Map<String, dynamic>? map, String key) => map?[key]?.toString();

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

  _AuctionStatus _statusByDates({DateTime? startAt, DateTime? endAt, String? statusText}) {
    final now = DateTime.now();
    final s = statusText?.toLowerCase().trim();
    if (s == 'ended' || s == 'finished' || s == 'closed') return _AuctionStatus.ended;
    if (s == 'live' || s == 'running' || s == 'in_progress' || s == 'active' || s == 'open') return _AuctionStatus.live;
    if (s == 'upcoming' || s == 'scheduled' || s == 'pending') return _AuctionStatus.ongoing;
    if (endAt != null && endAt.isBefore(now)) return _AuctionStatus.ended;
    if (startAt != null && startAt.isBefore(now) && (endAt == null || endAt.isAfter(now))) return _AuctionStatus.live;
    return _AuctionStatus.ongoing;
  }
}

enum _AuctionStatus { live, ongoing, ended }