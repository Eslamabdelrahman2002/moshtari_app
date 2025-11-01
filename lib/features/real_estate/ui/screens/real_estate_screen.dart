// file: real_estate_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

// 👇 إضافة الاستيراد الخاص باللوكيشن
import 'package:mushtary/core/location/logic/cubit/location_cubit.dart';
import 'package:mushtary/core/location/logic/cubit/location_state.dart';

import '../../../../core/widgets/primary/my_svg.dart';

class RealEstateScreen extends StatelessWidget {
  const RealEstateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 👇 تصحيح: إضافة (context) كمعامل للدالة
        BlocProvider<RealEstateListingsCubit>(
          create: (context) => getIt<RealEstateListingsCubit>()..init(type: 'ad'),
        ),
        // 👇 تصحيح: إضافة (context) كمعامل للدالة
        BlocProvider<FavoritesCubit>(
          create: (context) => getIt<FavoritesCubit>()..fetchFavorites(),
        ),
        // 👇 تصحيح: إضافة (context) كمعامل للدالة (حتى لو لم نستخدمه)
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
  String _tab = 'ad'; // ad | request
  String _combo = 'all';

  // 👇 القائمة المحدثة للـ _combos مع جميع الأنواع (من الرد السابق)
  final List<_Combo> _combos = const [
    _Combo('all', 'الكل', null, null),

    // شقق
    _Combo('apartment_sell', 'شقق للبيع', 'apartment', 'sell'),
    _Combo('apartment_rent', 'شقق للإيجار', 'apartment', 'rent'),

    // فلل
    _Combo('villa_sell', 'فلل للبيع', 'villa', 'sell'),
    _Combo('villa_rent', 'فلل للإيجار', 'villa', 'rent'),

    // أراضي سكنية
    _Combo('residential_land_sell', 'أراضي سكنية للبيع', 'residential_land', 'sell'),
    _Combo('residential_land_rent', 'أراضي سكنية للإيجار', 'residential_land', 'rent'),

    // أراضي (عامة)
    _Combo('lands_sell', 'أراضي للبيع', 'lands', 'sell'),
    _Combo('lands_rent', 'أراضي للإيجار', 'lands', 'rent'),

    // شقق وغرف
    _Combo('apartments_and_rooms_sell', 'شقق وغرف للبيع', 'apartments_and_rooms', 'sell'),
    _Combo('apartments_and_rooms_rent', 'شقق وغرف للإيجار', 'apartments_and_rooms', 'rent'),

    // فلل وقصور
    _Combo('villas_and_palaces_sell', 'فلل وقصور للبيع', 'villas_and_palaces', 'sell'),
    _Combo('villas_and_palaces_rent', 'فلل وقصور للإيجار', 'villas_and_palaces', 'rent'),

    // طابق
    _Combo('floor_sell', 'طابق للبيع', 'floor', 'sell'),
    _Combo('floor_rent', 'طابق للإيجار', 'floor', 'rent'),

    // مباني وأبراج
    _Combo('buildings_and_towers_sell', 'مباني وأبراج للبيع', 'buildings_and_towers', 'sell'),
    _Combo('buildings_and_towers_rent', 'مباني وأبراج للإيجار', 'buildings_and_towers', 'rent'),

    // شاليهات ومنازل إجازة
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
      requestType: c.purpose, // 👈 يتوافق مع purpose في النماذج
    );
  }

  Future<void> _pickCity() async {
    // خد نفس النسخة اللي فوق في الشجرة
    final locationCubit = context.read<LocationCubit>();

    // ممكن تجهّز تحميل المناطق قبل فتح الشيت
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
    // لو حابب ترجع "الكل" لما المستخدم يقفل الشيت بدون اختيار:
    // else {
    //   await context.read<RealEstateListingsCubit>().applyCity(null);
    // }
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
                blurRadius: 5,
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
      body: Column(
        children: [
          // تبويبات
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 0),
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: ColorsManager.dark50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  _segBtn('إعلانات', _tab == 'ad', () => _onTab('ad')),
                  _segBtn('طلبات', _tab == 'request', () => _onTab('request')),
                ],
              ),
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

          // شريط عرض + مدينة
          BlocBuilder<RealEstateListingsCubit, RealEstateListingsState>(
            buildWhen: (prev, curr) => prev != curr,
            builder: (context, state) {
              final bool isGrid = state is ListingsLoaded ? state.isGrid : cubit.isGrid;
              return RealEstateActionBar(
                onGridViewTap: () => cubit.setLayout(true),
                onListViewTap: () => cubit.setLayout(false),
                isGridView: isGrid,
                isListView: !isGrid,
                onMapViewTap: () {},
                onCityTap: _pickCity, // 👈 تفتح بيكر المدن الديناميكي
                isMapView: false,
                isApplications: false,
              );
            },
          ),
          verticalSpace(8),

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

                final bool isGrid = state is ListingsLoaded ? state.isGrid : cubit.isGrid;
                List<RealEstateListModel> properties = [];
                if (state is ListingsLoaded) {
                  properties = state.items.cast<RealEstateListModel>();
                }

                if (properties.isEmpty) {
                  return const Center(child: Text('لا توجد نتائج مطابقة'));
                }

                return RealEstateAds(
                  isListView: !isGrid,
                  isGridView: isGrid,
                  isMapView: false,
                  isApplications: false,
                  properties: properties,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _segBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 44.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? ColorsManager.primary400 : ColorsManager.dark50,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: active
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
                : null,
          ),
          child: Text(
            label,
            style: active ? TextStyles.font14White500Weight : TextStyles.font14Black500Weight,
          ),
        ),
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

  const _CombosBar({
    super.key,
    required this.combos,
    required this.selectedKey,
    required this.onSelected,
  });

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          );
        },
      ),
    );
  }
}

// 👇 BottomSheet ديناميكي لاختيار المدينة باستخدام LocationCubit
class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet({super.key});

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  int? _selectedRegionId;

  @override
  void initState() {
    super.initState();
    final loc = context.read<LocationCubit>();
    final st = loc.state;
    // لو المناطق لسه متحمّلتش، حمّلها
    if (!st.regionsLoading && (st.regions.isEmpty)) {
      loc.loadRegions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر المدينة', style: TextStyles.font16Dark400Weight),
            verticalSpace(12),

            // اختيار المنطقة
            BlocBuilder<LocationCubit, LocationState>(
              buildWhen: (p, c) =>
              p.regions != c.regions ||
                  p.regionsLoading != c.regionsLoading ||
                  p.regionsError != c.regionsError,
              builder: (context, state) {
                if (state.regionsLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  );
                }
                if (state.regionsError != null) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(state.regionsError!, style: TextStyles.font14Black500Weight),
                      TextButton(
                        onPressed: () => context.read<LocationCubit>().loadRegions(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  );
                }

                return DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'اختر المنطقة',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  ),
                  value: _selectedRegionId,
                  items: state.regions
                      .map((r) => DropdownMenuItem<int>(
                    value: r.id,
                    // NOTE: لو اسم الحقل مختلف استخدمه هنا بدلاً من nameAr
                    child: Text(r.nameAr ?? r.nameAr ?? 'بدون اسم'),
                  ))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _selectedRegionId = v);
                    if (v != null) {
                      context.read<LocationCubit>().loadCities(v);
                    }
                  },
                );
              },
            ),

            verticalSpace(16),

            // اختيار المدينة
            BlocBuilder<LocationCubit, LocationState>(
              buildWhen: (p, c) =>
              p.cities != c.cities ||
                  p.citiesLoading != c.citiesLoading ||
                  p.citiesError != c.citiesError,
              builder: (context, state) {
                if (_selectedRegionId == null) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text('من فضلك اختر المنطقة أولاً', style: TextStyles.font14Black500Weight),
                    ),
                  );
                }

                if (state.citiesLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  );
                }

                if (state.citiesError != null) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(state.citiesError!, style: TextStyles.font14Black500Weight),
                      TextButton(
                        onPressed: () {
                          if (_selectedRegionId != null) {
                            context.read<LocationCubit>().loadCities(_selectedRegionId!);
                          }
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  );
                }

                // لستة المدن
                return SizedBox(
                  height: 300.h, // ارتفاع مناسب داخل الـ BottomSheet
                  child: ListView.builder(
                    itemCount: state.cities.length + 1, // +1 لخيار "الكل"
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // "الكل" => null
                        return ListTile(
                          title: const Text('الكل'),
                          onTap: () => Navigator.of(context).pop<int?>(null),
                        );
                      }
                      final city = state.cities[index - 1];
                      return ListTile(
                        // NOTE: لو اسم الحقل مختلف استخدمه بدلاً من nameAr
                        title: Text(city.nameAr ?? city.nameAr ?? 'بدون اسم'),
                        onTap: () => Navigator.of(context).pop<int?>(city.id),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}