// file: real_estate_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart' as latlng;

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';

import 'package:mushtary/features/real_estate/logic/cubit/real_estate_listings_cubit.dart';
import 'package:mushtary/features/real_estate/logic/cubit/real_estate_listings_state.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_ads.dart';
import 'package:mushtary/features/real_estate/ui/widgets/real_estate_action_bar.dart';
import 'package:mushtary/features/real_estate/data/model/real_estate_ad_model.dart';
import 'package:mushtary/features/favorites/ui/logic/cubit/favorites_cubit.dart';

import 'package:mushtary/core/location/logic/cubit/location_cubit.dart';
import 'package:mushtary/core/location/logic/cubit/location_state.dart';

import '../../../../core/widgets/primary/my_svg.dart';
import '../widgets/real_estate_map_view.dart';
import '../widgets/map_details_sheet.dart';

class RealEstateScreen extends StatelessWidget {
  const RealEstateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RealEstateListingsCubit>(
          create: (context) => getIt<RealEstateListingsCubit>()..init(type: 'ad'),
        ),
        BlocProvider<FavoritesCubit>(
          create: (context) => getIt<FavoritesCubit>()..fetchFavorites(),
        ),
        BlocProvider<LocationCubit>(
          create: (context) => getIt<LocationCubit>(),
        ),
      ],
      child: const _RealEstateView(),
    );
  }
}

class _RealEstateView extends StatefulWidget {
  const _RealEstateView();

  @override
  State<_RealEstateView> createState() => _RealEstateViewState();
}

class _RealEstateViewState extends State<_RealEstateView> {
  String _tab = 'ad';
  String _combo = 'all';
  bool _showMap = false;

  List<RealEstateListModel> _selectedListings = [];

  // فلترة الإحداثيات الشاذّة (لتثبيت الكاميرا فقط)
  List<RealEstateListModel> _filterOutliers(List<RealEstateListModel> items) {
    final pts = items.where((e) => e.latitude != null && e.longitude != null).toList();
    if (pts.length <= 2) return pts;

    // حدود السعودية أولاً إن أمكن
    final inKSA = pts.where((e) {
      final lat = e.latitude!, lon = e.longitude!;
      return lat >= 15 && lat <= 33 && lon >= 34 && lon <= 56;
    }).toList();
    if (inKSA.length >= 3) return inKSA;

    // Median Window fallback
    final lats = pts.map((e) => e.latitude!).toList()..sort();
    final lons = pts.map((e) => e.longitude!).toList()..sort();
    final latMedian = lats[lats.length ~/ 2];
    final lonMedian = lons[lons.length ~/ 2];

    const maxDelta = 5.0; // ~550km
    return pts.where((e) =>
    (e.latitude! - latMedian).abs() <= maxDelta &&
        (e.longitude! - lonMedian).abs() <= maxDelta
    ).toList();
  }

  void _handleMarkerClusterTap(List<RealEstateListModel> listings) {
    setState(() {
      final isSameCluster = _selectedListings.isNotEmpty &&
          listings.isNotEmpty &&
          _selectedListings.first.id == listings.first.id &&
          _selectedListings.length == listings.length;
      _selectedListings = isSameCluster ? [] : listings;
    });
  }

  void _handleCloseSheet() {
    setState(() {
      _selectedListings = [];
    });
  }

  final List<_Combo> _combos = const [
    _Combo('all', 'الكل', null, null),
    _Combo('apartment_sell', 'شقق للبيع', 'apartment', 'sell'),
    _Combo('apartment_rent', 'شقق للإيجار', 'apartment', 'rent'),
    _Combo('villa_sell', 'فلل للبيع', 'villa', 'sell'),
    _Combo('villa_rent', 'فلل للإيجار', 'villa', 'rent'),
    _Combo('residential_land_sell', 'أراضي سكنية للبيع', 'residential_land', 'sell'),
    _Combo('residential_land_rent', 'أراضي سكنية للإيجار', 'residential_land', 'rent'),
    _Combo('lands_sell', 'أراضي للبيع', 'lands', 'sell'),
    _Combo('lands_rent', 'أراضي للإيجار', 'lands', 'rent'),
    _Combo('apartments_and_rooms_sell', 'شقق وغرف للبيع', 'apartments_and_rooms', 'sell'),
    _Combo('apartments_and_rooms_rent', 'شقق وغرف للإيجار', 'apartments_and_rooms', 'rent'),
    _Combo('villas_and_palaces_sell', 'فلل وقصور للبيع', 'villas_and_palaces', 'sell'),
    _Combo('villas_and_palaces_rent', 'فلل وقصور للإيجار', 'villas_and_palaces', 'rent'),
    _Combo('floor_sell', 'طابق للبيع', 'floor', 'sell'),
    _Combo('floor_rent', 'طابق للإيجار', 'floor', 'rent'),
    _Combo('buildings_and_towers_sell', 'مباني وأبراج للبيع', 'buildings_and_towers', 'sell'),
    _Combo('buildings_and_towers_rent', 'مباني وأبراج للإيجار', 'buildings_and_towers', 'rent'),
    _Combo('chalets_and_resthouses_sell', 'شاليهات ومنازل إجازة للبيع', 'chalets_and_resthouses', 'sell'),
    _Combo('chalets_and_resthouses_rent', 'شاليهات ومنازل إجازة للإيجار', 'chalets_and_resthouses', 'rent'),
  ];

  Future<void> _onTab(String t) async {
    setState(() => _tab = t);
    await context.read<RealEstateListingsCubit>().switchTab(t);
  }

  Future<void> _onCombo(_Combo c) async {
    setState(() => _combo = c.key);
    await context.read<RealEstateListingsCubit>().applyCombo(
      realEstateType: c.type,
      requestType: c.purpose,
    );
  }

  Future<void> _pickCity() async {
    final locationCubit = context.read<LocationCubit>();
    if (locationCubit.state.regions.isEmpty && !locationCubit.state.regionsLoading) {
      locationCubit.loadRegions();
    }

    final sel = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: locationCubit,
        child: const _CityPickerSheet(),
      ),
    );

    if (sel != null) {
      await context.read<RealEstateListingsCubit>().applyCity(sel);
    }
  }

  latlng.LatLng? _computeCenter(List<RealEstateListModel> items) {
    final pts = items.where((e) => e.latitude != null && e.longitude != null).toList();
    if (pts.isEmpty) return null;
    if (pts.length == 1) {
      return latlng.LatLng(pts.first.latitude!, pts.first.longitude!);
    }
    double minLat = pts.first.latitude!, maxLat = pts.first.latitude!;
    double minLng = pts.first.longitude!, maxLng = pts.first.longitude!;
    for (final e in pts) {
      minLat = math.min(minLat, e.latitude!);
      maxLat = math.max(maxLat, e.latitude!);
      minLng = math.min(minLng, e.longitude!);
      maxLng = math.max(maxLng, e.longitude!);
    }
    return latlng.LatLng((minLat + maxLat) / 2.0, (minLng + maxLng) / 2.0);
  }

  double? _estimateZoom(List<RealEstateListModel> items) {
    final pts = items.where((e) => e.latitude != null && e.longitude != null).toList();
    if (pts.isEmpty) return null;
    if (pts.length == 1) return 13.5;

    double minLat = pts.first.latitude!, maxLat = pts.first.latitude!;
    double minLng = pts.first.longitude!, maxLng = pts.first.longitude!;
    for (final e in pts) {
      minLat = math.min(minLat, e.latitude!);
      maxLat = math.max(maxLat, e.latitude!);
      minLng = math.min(minLng, e.longitude!);
      maxLng = math.max(maxLng, e.longitude!);
    }
    final latSpan = (maxLat - minLat).abs();
    final lngSpan = (maxLng - minLng).abs();
    final span = math.max(latSpan, lngSpan);

    if (span < 0.10) return 13.5;
    if (span < 0.50) return 12.0;
    if (span < 1.50) return 11.0;
    if (span < 4.00) return 9.5;
    if (span < 10.0) return 7.5;
    return 5.5;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RealEstateListingsCubit>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: ColorsManager.white,
            boxShadow: [
              BoxShadow(
                color: ColorsManager.black.withOpacity(0.03),
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const MySvg(
            image: 'realstate-logo',
            isImage: false,
          ),
        ),
      ),
      body: BlocBuilder<RealEstateListingsCubit, RealEstateListingsState>(
        buildWhen: (prev, curr) => (prev is! ListingsLoaded || curr is! ListingsLoaded) || prev.isGrid != curr.isGrid,
        builder: (context, state) {
          final bool isGrid = state is ListingsLoaded ? state.isGrid : cubit.isGrid;

          return Column(
            children: [
              // تبويبات
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child:  _TabItem(label: 'إعلانات', isActive: _tab == 'ad', onTap: () => _onTab('ad'))),
                    horizontalSpace(16),
                    Expanded(child: _TabItem(label: 'طلبات', isActive: _tab == 'request', onTap: () => _onTab('request'))),
                  ],
                ),
              ),
              verticalSpace(8),

              // الكومبو
              _CombosBar(
                combos: _combos,
                selectedKey: _combo,
                onSelected: (c) => _onCombo(c),
              ),
              verticalSpace(8),

              // شريط الأكشن
              RealEstateActionBar(
                onGridViewTap: () => cubit.setLayout(true),
                onListViewTap: () => cubit.setLayout(false),
                isGridView: isGrid,
                isListView: !isGrid,
                onMapViewTap: () {
                  setState(() {
                    _showMap = !_showMap;
                    if (!_showMap) _selectedListings = [];
                  });
                },
                onCityTap: _pickCity,
                isMapView: _showMap,
                isApplications: false,
              ),
              verticalSpace(8),

              // الخريطة أو القائمة
              if (_showMap)
                BlocBuilder<RealEstateListingsCubit, RealEstateListingsState>(
                  builder: (context, state) {
                    if (state is ListingsLoaded) {
                      final listings = state.listings;

                      final focus = _filterOutliers(listings);
                      final target = focus.isNotEmpty ? focus : listings;
                      final center = _computeCenter(target);
                      final zoom = _estimateZoom(target);

                      return Expanded(
                        child: Stack(
                          children: [
                            // إطار أصفر حول الخريطة + قص الزوايا
                            Positioned.fill(
                              child: RealEstateMapView(
                                listings: listings,
                                center: center,
                                zoom: zoom,
                                logPlotted: false,
                                onClusterTap: _handleMarkerClusterTap,
                              ),
                            ),

                            if (_selectedListings.isNotEmpty)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: MapDetailsSheet(
                                  listings: _selectedListings,
                                  onClose: _handleCloseSheet,
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                    if (state is ListingsLoading) {
                      return SizedBox(height: 200.h, child: const Center(child: CircularProgressIndicator.adaptive()));
                    }
                    return const SizedBox.shrink();
                  },
                )
              else
                Expanded(
                  child: BlocBuilder<RealEstateListingsCubit, RealEstateListingsState>(
                    builder: (context, state) {
                      if (state is ListingsLoading) {
                        return const Center(child: CircularProgressIndicator.adaptive());
                      }
                      if (state is ListingsError) {
                        return Center(child: Text(state.message));
                      }
                      if (state is ListingsEmpty) {
                        return const Center(child: Text('لا توجد نتائج مطابقة'));
                      }
                      if (state is ListingsLoaded) {
                        return RealEstateAds(
                          isListView: !state.isGrid,
                          isGridView: state.isGrid,
                          isMapView: false,
                          isApplications: false,
                          properties: state.listings,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _TabItem({required this.label, required this.isActive, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? ColorsManager.primary400 : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isActive
              ? [BoxShadow(color: ColorsManager.primary400.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
              : null,
        ),
        child: Text(label, style: isActive ? TextStyles.font14White500Weight : TextStyles.font14Black500Weight, textAlign: TextAlign.center,),
      ),
    );
  }
}

class _Combo {
  final String key;
  final String label;
  final String? type;
  final String? purpose;
  const _Combo(this.key, this.label, this.type, this.purpose);
}

class _CombosBar extends StatelessWidget {
  final List<_Combo> combos;
  final String selectedKey;
  final ValueChanged<_Combo> onSelected;
  const _CombosBar({super.key, required this.combos, required this.selectedKey, required this.onSelected});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: combos.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final c = combos[i];
          final sel = c.key == selectedKey;
          return ChoiceChip(
            label: Text(c.label),
            selected: sel,
            onSelected: (_) => onSelected(c),
            selectedColor: ColorsManager.primary50,
            labelStyle: sel ? TextStyles.font14Blue500Weight : TextStyles.font14Black500Weight,
            backgroundColor: Colors.white,
            side: BorderSide(color: sel ? ColorsManager.primary400 : ColorsManager.dark200),
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          );
        },
      ),
    );
  }
}

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet();
  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  int? _selectedRegionId;
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: ColorsManager.dark200,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 120.w,
                    child: BlocBuilder<LocationCubit, LocationState>(
                      builder: (context, state) {
                        if (state.regionsLoading) {
                          return const Center(child: CircularProgressIndicator.adaptive());
                        }
                        if (state.regionsError != null) {
                          return Center(child: Text(state.regionsError!));
                        }
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: state.regions.length,
                          itemBuilder: (context, index) {
                            final region = state.regions[index];
                            final isSelected = _selectedRegionId == region.id;
                            return GestureDetector(
                              onTap: () {
                                setState(() {_selectedRegionId = region.id;});
                                context.read<LocationCubit>().loadCities(region.id);
                              },
                              child: Container(
                                color: isSelected ? ColorsManager.primary50 : Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                                child: Text(region.nameAr ?? 'بدون اسم', style: isSelected ? TextStyles.font14Blue500Weight : TextStyles.font14Black500Weight),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Container(width: 1.w, color: ColorsManager.dark50),
                  Expanded(
                    child: BlocBuilder<LocationCubit, LocationState>(
                      builder: (context, state) {
                        if (_selectedRegionId == null) {
                          return Padding(padding: EdgeInsets.symmetric(vertical: 8.h), child: Text('من فضلك اختر المنطقة أولاً', style: TextStyles.font14Black500Weight));
                        }
                        if (state.citiesLoading) {
                          return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Center(child: CircularProgressIndicator.adaptive()));
                        }
                        if (state.citiesError != null) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(state.citiesError!, style: TextStyles.font14Black500Weight),
                              TextButton(
                                onPressed: () {
                                  if (_selectedRegionId != null) {context.read<LocationCubit>().loadCities(_selectedRegionId!);}
                                },
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          );
                        }
                        return Expanded(
                          child: ListView.builder(
                            itemCount: state.cities.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) return ListTile(title: const Text('الكل'), onTap: () => Navigator.of(context).pop<int?>(null));
                              final city = state.cities[index - 1];
                              return ListTile(title: Text(city.nameAr ?? 'بدون اسم'), onTap: () => Navigator.of(context).pop<int?>(city.id));
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}