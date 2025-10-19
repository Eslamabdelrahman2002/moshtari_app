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

  static const String _uaHeader = 'com.example.mushtary/1.0 (contact: you@example.com)';
  static const String _uaPackage = 'com.example.mushtary';

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
    } catch (_) {}
    if (!mounted) return;
    setState(() { _cameraCenter = c; _ready = true; });
  }

  void _onMapEvent(MapEvent e) {
    if (e is MapEventMove || e is MapEventFlingAnimation || e is MapEventRotate) {
      setState(() { _moving = true; _cameraCenter = e.camera.center; });
    }
    if (e is MapEventMoveEnd || e is MapEventFlingAnimationEnd) {
      setState(() => _moving = false);
    }
  }

  Future<String?> _reverseGeocodeArabic(ll.LatLng p) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
            '?format=jsonv2&accept-language=ar&lat=${p.latitude}&lon=${p.longitude}',
      );
      final res = await http.get(uri, headers: {'User-Agent': _uaHeader});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final name = (data['display_name'] ?? '').toString();
        return name.isEmpty ? null : name;
      }
    } catch (_) {}
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

  void _onSearchChanged(String q) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () => _search(q));
  }

  Future<void> _submitSearch(String v) async {
    await _search(v);
    if (!mounted) return;
    if (_suggestions.isNotEmpty) _chooseSuggestion(_suggestions.first);
  }

  Future<void> _search(String q) async {
    final s = q.trim();
    if (s.length < 2) {
      setState(() { _suggestions.clear(); _showResults = false; });
      return;
    }
    setState(() { _searching = true; _showResults = true; });
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json'
            '&addressdetails=1&accept-language=ar&limit=8&q=${Uri.encodeComponent(s)}',
      );
      final res = await http.get(uri, headers: {'User-Agent': _uaHeader});
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body) as List;
        _suggestions
          ..clear()
          ..addAll(
            data.map((e) => _SearchResult(
              (e['display_name'] ?? '').toString(),
              ll.LatLng(double.tryParse('${e['lat']}') ?? 0, double.tryParse('${e['lon']}') ?? 0),
            )),
          );
      } else {
        _suggestions.clear();
      }
    } catch (_) {
      _suggestions.clear();
    }
    if (!mounted) return;
    setState(() { _searching = false; _showResults = _suggestions.isNotEmpty; });
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
        backgroundColor: Colors.transparent, elevation: 0, surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          splashColor: Colors.transparent, highlightColor: Colors.transparent, hoverColor: Colors.transparent,
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
          IgnorePointer(
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.location_pin, color: Colors.red, size: 40),
                AnimatedOpacity(
                  opacity: _moving ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(3))),
                ),
              ]),
            ),
          ),
          Positioned(
            top: topPad, left: 16, right: 16,
            child: Material(
              elevation: 6, borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 52, padding: const EdgeInsetsDirectional.only(start: 12, end: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.search, color: Colors.grey), const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl, focusNode: _searchFocus,
                      onChanged: _onSearchChanged, onSubmitted: _submitSearch, textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(hintText: 'ابحث عن موقع...', border: InputBorder.none, isDense: true),
                    ),
                  ),
                  if (_searching) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  if (_searchCtrl.text.isNotEmpty && !_searching)
                    IconButton(
                      onPressed: () { setState(() { _searchCtrl.clear(); _suggestions.clear(); _showResults = false; }); _searchFocus.requestFocus(); },
                      icon: const Icon(Icons.close, color: Colors.grey),
                      splashColor: Colors.transparent, highlightColor: Colors.transparent, hoverColor: Colors.transparent,
                    ),
                ]),
              ),
            ),
          ),
          if (_showResults)
            Positioned(
              top: topPad + 60, left: 16, right: 16,
              child: Material(
                elevation: 8, borderRadius: BorderRadius.circular(14),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.separated(
                    shrinkWrap: true, padding: const EdgeInsets.symmetric(vertical: 8), itemCount: _suggestions.length,
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
            right: 16, bottom: 100,
            child: FloatingActionButton(
              heroTag: 'myLoc', onPressed: _goToMyLocation,
              backgroundColor: ColorsManager.primaryColor, child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          Positioned(
            left: 16, right: 16, bottom: 16,
            child: SafeArea(child: SizedBox(height: 52, child: PrimaryButton(onPressed: _confirm, text: 'تحديد الموقع'))),
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