import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as ll;

import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

// إعدادات سريعة
const bool kEnableSearch = false;             // لو حابب توقف البحث تمامًا خلّيها false
const bool kUseLocationIq = false;           // فعلها لو عندك مفتاح LocationIQ
const String kLocationIqKey = 'YOUR_KEY_HERE'; // ضع مفتاح LocationIQ هنا لو فعلت السطر السابق

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapCtrl = MapController();

  bool _ready = false;
  ll.LatLng _cameraCenter = const ll.LatLng(24.7136, 46.6753); // Riyadh
  bool _moving = false;

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final List<_SearchResult> _suggestions = [];
  Timer? _searchDebounce;
  bool _searching = false;
  bool _showResults = false;

  // Nominatim headers and UA
  static const String _uaHeader = 'Mushtary/1.0 (+https://mushtary.app; contact: support@mushtary.app)';
  static const String _uaPackage = 'com.example.mushtary';
  static const Map<String, String> _httpHeaders = {
    'User-Agent': _uaHeader,
    'Accept': 'application/json',
    'Referer': 'https://mushtary.app',
  };

  // منع تراكب ردود قديمة على أحدث نتيجة
  int _searchToken = 0;

  @override
  void initState() {
    super.initState();
    _initCenter();
  }

  Future<void> _initCenter() async {
    var c = _cameraCenter;
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (enabled) {
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
          final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          c = ll.LatLng(p.latitude, p.longitude);
        }
      }
    } catch (e) {
      debugPrint('initCenter error: $e');
    }
    if (!mounted) return;
    setState(() {
      _cameraCenter = c;
      _ready = true;
    });
  }

  void _onMapEvent(MapEvent e) {
    if (e is MapEventMove || e is MapEventFlingAnimation || e is MapEventRotate) {
      setState(() {
        _moving = true;
        _cameraCenter = e.camera.center;
      });
    }
    if (e is MapEventMoveEnd || e is MapEventFlingAnimationEnd) {
      setState(() => _moving = false);
    }
  }

  // ============= Reverse Geocoding =============
  Future<String?> _reverseGeocodeArabic(ll.LatLng p) async {
    if (kUseLocationIq && kLocationIqKey.isNotEmpty) {
      return _reverseGeocodeLocationIq(p);
    }
    return _reverseGeocodeNominatim(p);
  }

  Future<String?> _reverseGeocodeNominatim(ll.LatLng p) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
            '?format=jsonv2'
            '&accept-language=ar'
            '&lat=${p.latitude}'
            '&lon=${p.longitude}'
            '&email=support@mushtary.app',
      );
      final res = await http.get(uri, headers: _httpHeaders).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final name = (data['display_name'] ?? '').toString();
        return name.isEmpty ? null : name;
      } else {
        debugPrint('Reverse(Nominatim) failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('Reverse(Nominatim) error: $e');
    }
    return null;
  }

  Future<String?> _reverseGeocodeLocationIq(ll.LatLng p) async {
    try {
      final uri = Uri.parse(
        'https://us1.locationiq.com/v1/reverse'
            '?key=$kLocationIqKey'
            '&lat=${p.latitude}'
            '&lon=${p.longitude}'
            '&format=json'
            '&accept-language=ar',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final name = (data['display_name'] ?? '').toString();
        return name.isEmpty ? null : name;
      } else {
        debugPrint('Reverse(LocationIQ) failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('Reverse(LocationIQ) error: $e');
    }
    return null;
  }

  Future<void> _confirm() async {
    final center = _cameraCenter;
    final addressAr = await _reverseGeocodeArabic(center);
    if (!mounted) return;
    Navigator.pop(
      context,
      PickedLocation(
        latLng: gmap.LatLng(center.latitude, center.longitude),
        addressAr: addressAr,
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    try {
      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final me = ll.LatLng(p.latitude, p.longitude);
      _mapCtrl.move(me, 16);
      setState(() => _cameraCenter = me);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تحديد موقعي: $e')));
    }
  }

  // ============= Search =============
  void _onSearchChanged(String q) {
    if (!kEnableSearch) return;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 700), () => _search(q));
  }

  Future<void> _submitSearch(String v) async {
    if (!kEnableSearch) return;
    await _search(v);
    if (!mounted) return;
    if (_suggestions.isNotEmpty) _chooseSuggestion(_suggestions.first);
  }

  Future<void> _search(String q) async {
    if (!kEnableSearch) return;
    final s = q.trim();
    if (s.length < 2) {
      setState(() {
        _suggestions.clear();
        _showResults = false;
      });
      return;
    }

    final myToken = ++_searchToken;

    setState(() {
      _searching = true;
      _showResults = true;
    });

    bool ok = false;

    // 1) Provider الأساسي
    if (!kUseLocationIq) {
      ok = await _searchNominatim(s, myToken);
      // 2) Fallback لـ LocationIQ لو فشل وكان فيه مفتاح
      if (!ok && kLocationIqKey.isNotEmpty) {
        ok = await _searchLocationIq(s, myToken);
      }
    } else {
      // العكس: لو LocationIQ مفعّل أولاً
      ok = await _searchLocationIq(s, myToken);
      if (!ok) {
        ok = await _searchNominatim(s, myToken);
      }
    }

    if (!ok && mounted) {
      setState(() {
        _searching = false;
        _suggestions.clear();
        _showResults = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر جلب نتائج البحث الآن. حاول لاحقًا.')),
      );
    }
  }

  Future<bool> _searchNominatim(String s, int myToken) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
            '?format=jsonv2'
            '&addressdetails=1'
            '&accept-language=ar'
            '&limit=8'
            '&countrycodes=sa'
            '&q=${Uri.encodeComponent(s)}'
            '&email=support@mushtary.app',
      );
      final res = await http.get(uri, headers: _httpHeaders).timeout(const Duration(seconds: 10));
      debugPrint('Search(Nominatim) status=${res.statusCode}');
      if (myToken != _searchToken) return true; // تجاهل لأنه قديم

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body) as List;
        _suggestions
          ..clear()
          ..addAll(data.map((e) => _SearchResult(
            (e['display_name'] ?? '').toString(),
            ll.LatLng(double.tryParse('${e['lat']}') ?? 0, double.tryParse('${e['lon']}') ?? 0),
          )));
        setState(() {
          _searching = false;
          _showResults = _suggestions.isNotEmpty;
        });
        return true;
      } else {
        debugPrint('Search(Nominatim) failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('Search(Nominatim) error: $e');
    }
    return false;
  }

  Future<bool> _searchLocationIq(String s, int myToken) async {
    if (kLocationIqKey.isEmpty) return false;
    try {
      final uri = Uri.parse(
        'https://us1.locationiq.com/v1/search'
            '?key=$kLocationIqKey'
            '&q=${Uri.encodeComponent(s)}'
            '&format=json'
            '&limit=8'
            '&accept-language=ar',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      debugPrint('Search(LocationIQ) status=${res.statusCode}');
      if (myToken != _searchToken) return true;

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body) as List;
        _suggestions
          ..clear()
          ..addAll(data.map((e) => _SearchResult(
            (e['display_name'] ?? '').toString(),
            ll.LatLng(double.tryParse('${e['lat']}') ?? 0, double.tryParse('${e['lon']}') ?? 0),
          )));
        setState(() {
          _searching = false;
          _showResults = _suggestions.isNotEmpty;
        });
        return true;
      } else {
        debugPrint('Search(LocationIQ) failed: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('Search(LocationIQ) error: $e');
    }
    return false;
  }

  void _chooseSuggestion(_SearchResult r) {
    _mapCtrl.move(r.point, 16);
    setState(() {
      _cameraCenter = r.point;
      _showResults = false;
      _searchCtrl.text = r.title;
    });
    _searchFocus.unfocus();
  }

  TileLayer _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: _uaPackage,
      maxZoom: 19,
      minZoom: 2,
      tileBuilder: (context, tileWidget, tile) => Image(
        image: tile.imageProvider,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.map_outlined, color: Colors.grey)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final topPad = MediaQuery.of(context).padding.top + 12;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: _cameraCenter,
              initialZoom: 14,
              onMapEvent: _onMapEvent,
            ),
            children: [_buildTileLayer()],
          ),
          // المؤشر في المنتصف
          IgnorePointer(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  AnimatedOpacity(
                    opacity: _moving ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (kEnableSearch)
            Positioned(
              top: topPad,
              left: 16,
              right: 16,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 52,
                  padding: const EdgeInsetsDirectional.only(start: 12, end: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          focusNode: _searchFocus,
                          onChanged: _onSearchChanged,
                          onSubmitted: _submitSearch,
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            hintText: 'ابحث عن موقع...',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searching)
                        const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      else if (_searchCtrl.text.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _searchCtrl.clear();
                              _suggestions.clear();
                              _showResults = false;
                            });
                            _searchFocus.requestFocus();
                          },
                          icon: const Icon(Icons.close, color: Colors.grey),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (kEnableSearch && _showResults)
            Positioned(
              top: topPad + 60,
              left: 16,
              right: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(14),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final r = _suggestions[i];
                      return ListTile(
                        leading: const Icon(Icons.place, color: Colors.blue),
                        title: Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: () => _chooseSuggestion(r),
                      );
                    },
                  ),
                ),
              ),
            ),
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton(
              heroTag: 'myLoc',
              onPressed: _goToMyLocation,
              backgroundColor: ColorsManager.primaryColor,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: SizedBox(
                height: 52,
                child: PrimaryButton(onPressed: _confirm, text: 'تحديد الموقع'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PickedLocation {
  final gmap.LatLng latLng;
  final String? addressAr;
  const PickedLocation({required this.latLng, this.addressAr});
}

class _SearchResult {
  final String title;
  final ll.LatLng point;
  _SearchResult(this.title, this.point);
}