// lib/features/real_estate/ui/widgets/real_estate_map_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart' as latlng;

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/features/real_estate/data/model/real_estate_ad_model.dart';

import '../../../../core/theme/text_styles.dart';

class RealEstateMapView extends StatefulWidget {
  final List<RealEstateListModel> listings;
  final latlng.LatLng? center;
  final double? zoom;

  final bool logPlotted;
  final ValueChanged<List<RealEstateListModel>>? onClusterTap;

  const RealEstateMapView({
    super.key,
    required this.listings,
    this.center,
    this.zoom,
    this.logPlotted = false,
    this.onClusterTap,
  });

  static const latlng.LatLng _defaultCenter = latlng.LatLng(24.714648, 46.667786);

  @override
  State<RealEstateMapView> createState() => _RealEstateMapViewState();
}

class _RealEstateMapViewState extends State<RealEstateMapView> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  @override
  void didUpdateWidget(covariant RealEstateMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listings != widget.listings) {
      _buildMarkers();
    }
    if (widget.center != null) {
      final oldC = oldWidget.center;
      final newC = widget.center!;
      final centerChanged = oldC == null || oldC.latitude != newC.latitude || oldC.longitude != newC.longitude;
      final zoomChanged = (oldWidget.zoom ?? 0) != (widget.zoom ?? 0);
      if (centerChanged || zoomChanged) {
        _mapController.move(newC, widget.zoom ?? _mapController.camera.zoom);
      }
    }
  }

  void _buildMarkers() {
    _markers = [];

    final valid = widget.listings.where((l) => l.latitude != null && l.longitude != null).toList();
    if (valid.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    // تجميع بسيط بتقريب الإحداثيات
    final Map<String, List<RealEstateListModel>> groups = {};
    for (final l in valid) {
      final key = _coordKey(l.latitude!, l.longitude!);
      (groups[key] ??= []).add(l);
    }

    for (final entry in groups.entries) {
      final group = entry.value;
      final base = group.first;
      final pos = latlng.LatLng(base.latitude!, base.longitude!);

      _markers.add(
        Marker(
          point: pos,
          width: 100.w,
          height: 44.h,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // تحريك الكاميرا لاحتواء المجموعة
              final pts = group
                  .where((e) => e.latitude != null && e.longitude != null)
                  .map((e) => latlng.LatLng(e.latitude!, e.longitude!))
                  .toList();

              if (pts.length == 1) {
                _mapController.move(pts.first, 13.5);
              } else {
                _mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: LatLngBounds.fromPoints(pts),
                    padding: const EdgeInsets.all(36),
                    maxZoom: 13.5,
                  ),
                );
              }

              widget.onClusterTap?.call(group);
            },
            child: _buildClusterWidget(group),
          ),
        ),
      );
    }

    if (mounted) setState(() {});
  }

  // مفتاح تجميع بسيط
  String _coordKey(double lat, double lon) => '${lat.toStringAsFixed(5)}|${lon.toStringAsFixed(5)}';

  // يبني ويدجت الماركر بحيث يطابق الصورة الأولى
  Widget _buildClusterWidget(List<RealEstateListModel> group) {
    if (group.length == 1) {
      // عنصر واحد => كابسولة سعر
      final p = _tryParsePrice(group.first.price);
      return _buildPriceChip(_formatSinglePrice(p));
    }

    // مجموعة: لو نقدر نطلع رنج أسعار واضح نعرضه ككابسولة، وإلا نعرض دائرة بالعدد
    final prices = group.map((e) => _tryParsePrice(e.price)).whereType<double>().toList()..sort();
    if (prices.length >= 2) {
      final minP = prices.first;
      final maxP = prices.last;
      final label = _formatPriceRange(minP, maxP);
      return _buildPriceChip(label);
    }

    // fallback: دائرة بعدد العناصر
    return _buildCountBubble(group.length);
  }

  // دائرة صفراء بعدد العناصر
  Widget _buildCountBubble(int count) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: ColorsManager.secondary500,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _toArabicDigits(count.toString()),
        style: TextStyles.font14Black500Weight.copyWith(color: Colors.black),
      ),
    );
  }

  // كابسولة صفراء للسعر/رنج السعر
  Widget _buildPriceChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: ColorsManager.secondary500,
        borderRadius: BorderRadius.circular(18.r),

      ),
      child: Text(
        label,
        style: TextStyles.font12Black400Weight, // نص غامق أسود على الأصفر
        textAlign: TextAlign.center,
      ),
    );
  }

  double? _tryParsePrice(String? price) {
    if (price == null) return null;
    final clean = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean);
  }

  // تنسيق سعر مفرد
  String _formatSinglePrice(double? v) {
    if (v == null) return _toArabicDigits('غير محدد');
    if (v >= 1e6) {
      return _toArabicDigits(' ${_trimZero((v / 1e6).toStringAsFixed(1))}مليون');
    } else if (v >= 1e3) {
      return _toArabicDigits(' ${_trimZero((v / 1e3).toStringAsFixed(1))}ألف');
    } else {
      return _toArabicDigits(_thousands(v.toInt()));
    }
  }

  // تنسيق رنج أسعار: "مليون 1,5 - 3,0" أو "ألف 200 - 950"
  String _formatPriceRange(double minP, double maxP) {
    if (minP >= 1e6 && maxP >= 1e6) {
      final a = _trimZero((minP / 1e6).toStringAsFixed(1));
      final b = _trimZero((maxP / 1e6).toStringAsFixed(1));
      return _toArabicDigits(' $a - $bمليون');
    }
    if (minP >= 1e3 && maxP >= 1e3) {
      final a = _trimZero((minP / 1e3).toStringAsFixed(1));
      final b = _trimZero((maxP / 1e3).toStringAsFixed(1));
      return _toArabicDigits(' $a - $bألف');
    }
    // وحدات مباشرة
    final a = _thousands(minP.round());
    final b = _thousands(maxP.round());
    return _toArabicDigits('$a - $b');
  }

  String _trimZero(String s) => s.replaceAll(RegExp(r'\.0$'), '').replaceAll('.', ',');

  String _thousands(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final left = s.length - i;
      b.write(s[i]);
      if (left > 1 && left % 3 == 1) b.write(',');
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.center ?? _initialCenter(),
          initialZoom: widget.zoom ?? 10,
          minZoom: 3,
          maxZoom: 18,
        ),
        children: [
          // بلاطات فاتحة قريبة من شكل الصورة الأولى
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.mushtary.app',
            tileProvider: NetworkTileProvider(
              headers: {'User-Agent': 'Mushtary/1.0 (support@yourdomain.com)'},
            ),
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }

  latlng.LatLng _initialCenter() {
    final firstValid = widget.listings.firstWhere(
          (e) => e.latitude != null && e.longitude != null,
      orElse: () => RealEstateListModel(id: 0),
    );
    if (firstValid.latitude != null && firstValid.longitude != null) {
      return latlng.LatLng(firstValid.latitude!, firstValid.longitude!);
    }
    return RealEstateMapView._defaultCenter;
  }

  String _toArabicDigits(String input) {
    const map = {'0':'٠','1':'١','2':'٢','3':'٣','4':'٤','5':'٥','6':'٦','7':'٧','8':'٨','9':'٩', ',': '،', '.' : ','};
    return input.split('').map((c) => map[c] ?? c).join();
  }
}