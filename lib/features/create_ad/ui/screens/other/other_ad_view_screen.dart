import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/utils/helpers/spacing.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/features/create_ad/ui/widgets/create_real_estate_ad_add_photo_video.dart';
import 'package:mushtary/features/create_ad/ui/widgets/next_button_bar.dart';

// Location
import 'package:mushtary/core/location/logic/cubit/location_cubit.dart';
import 'package:mushtary/core/location/logic/cubit/location_state.dart';
import 'package:mushtary/core/location/data/model/location_models.dart';

import 'logic/cubit/other_ads_cubit.dart';
import 'logic/cubit/other_ads_state.dart';

class OtherAdViewScreen extends StatefulWidget {
  const OtherAdViewScreen({super.key});

  @override
  State<OtherAdViewScreen> createState() => _OtherAdViewScreenState();
}

class _OtherAdViewScreenState extends State<OtherAdViewScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File> picked = [];

  // controllers لعرض القيم القديمة
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _phoneCtrl;

  bool chat = false;
  bool whatsapp = false;
  bool phone = false;

  String priceType = 'fixed';
  bool allowComments = true;
  bool allowMarketing = true;

  Region? _selectedRegion;
  City? _selectedCity;

  int? _selectedSubCategoryId;
  String? subCategoryName;

  final subCategories = const [
    {'id': 81, 'name': 'أدوات منزلية'},
    {'id': 82, 'name': 'عجلات'},
    {'id': 83, 'name': 'هواتف'},
    {'id': 84, 'name': 'كتب'},
    {'id': 85, 'name': 'مستلزمات أطفال'},
    {'id': 86, 'name': 'إلكترونيات'},
  ];

  static const List<String> kAllowedMediaExt = ['.jpg', '.jpeg', '.png', '.mp4'];

  bool get _isEditing {
    try {
      // يدعم الحالة حتى لو OtherAdsState لا تحتوي isEditing (يرجع false)
      return (context.read<OtherAdsCubit>().state as dynamic).isEditing == true;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    final s = context.read<OtherAdsCubit>().state;

    _titleCtrl = TextEditingController(text: s.title ?? '');
    _descCtrl = TextEditingController(text: s.description ?? '');
    _priceCtrl = TextEditingController(text: s.price?.toString() ?? '');
    _phoneCtrl = TextEditingController(text: s.phone ?? '');

    // تهيئة التبديلات من الحالة
    final methods = s.communicationMethods;
    chat = methods.contains('chat');
    whatsapp = methods.contains('whatsapp');
    phone = methods.contains('call') || methods.contains('phone');

    priceType = s.priceType.isNotEmpty ? s.priceType : 'fixed';
    allowComments = s.allowComments;
    allowMarketing = s.allowMarketing;

    // تهيئة التصنيف الفرعي (لو موجود في الحالة)
    _selectedSubCategoryId = s.subCategoryId;
    if (_selectedSubCategoryId != null) {
      try {
        subCategoryName = subCategories
            .firstWhere((e) => e['id'] == _selectedSubCategoryId)['name'] as String?;
      } catch (_) {}
    }

    // تهيئة المنطقة/المدينة بحسب IDs من الحالة بعد تحميل البيانات
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loc = getIt<LocationCubit>();
      // استخدم Provider للـ LocationCubit في هذه الشاشة
      context.read<LocationCubit>(); // تأكد من وجوده في الشجرة

      await context.read<LocationCubit>().loadRegions();
      final st = context.read<LocationCubit>().state;

      if (s.regionId != null) {
        try {
          final reg = st.regions.firstWhere((r) => r.id == s.regionId);
          setState(() => _selectedRegion = reg);
          await context.read<LocationCubit>().loadCities(reg.id);
          final st2 = context.read<LocationCubit>().state;
          if (s.cityId != null) {
            try {
              final c = st2.cities.firstWhere((x) => x.id == s.cityId);
              setState(() => _selectedCity = c);
            } catch (_) {}
          }
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade600),
    );
  }

  Future<void> pickImages() async {
    final images = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
      limit: 10,
    );
    if (images.isNotEmpty) {
      final cubit = context.read<OtherAdsCubit>();
      for (final x in images) {
        final file = File(x.path);
        if (!kAllowedMediaExt.contains(p.extension(file.path).toLowerCase())) {
          _showError('الملف ${p.basename(file.path)} ليس بصيغة مدعومة (png, jpg, mp4).');
          continue;
        }
        picked.add(file);
        cubit.addImage(file);
      }
      setState(() {});
    } else if (picked.length >= 10) {
      _showError('تم الوصول للحد الأقصى (10 صور)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OtherAdsCubit>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationCubit>(create: (_) => getIt<LocationCubit>()..loadRegions()),
      ],
      child: BlocListener<OtherAdsCubit, OtherAdsState>(
        listenWhen: (p, c) => p.submitting != c.submitting || p.success != c.success || p.error != c.error,
        listener: (context, state) {
          if (state.submitting) {
            final msg = _isEditing ? 'جارٍ حفظ التغييرات...' : 'جاري نشر الإعلان...';
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
          } else if (state.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_isEditing ? 'تم حفظ التغييرات' : 'تم نشر الإعلان بنجاح')),
            );
            Navigator.pop(context, _isEditing ? true : null);
            if (!_isEditing && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          } else if (state.error != null && state.error!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            title: Text(
              _isEditing ? 'تعديل إعلان' : 'إنشاء إعلان',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
            ),
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: MySvg(image: 'arrow-right', color: ColorsManager.black),
              tooltip: 'رجوع',
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                // الصور/الفيديو
                if (picked.isEmpty)
                  InkWell(
                    onTap: pickImages,
                    child: Container(
                      width: MediaQuery.of(context).size.width * .89,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorsManager.primary200),
                      ),
                      child: Column(
                        children: [
                          const MySvg(image: 'add_photo_video'),
                          verticalSpace(8),
                          Text('إضافة صوره او مقطع فيديو (حتى 10)', style: TextStyles.font12Primary300400Weight),
                          Text(
                            'ندعم فقط الانواع التالية من الصور والفيديو: png, jpg, mp4 \n ويشترط على حجم الملف ان يكون اقل من 2:00 ميغا بايت',
                            style: TextStyles.font10DarkGray400Weight,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  CreateRealEstateAdAddPhotoVideo(
                    pickImage: pickImages,
                    remove: (i) {
                      setState(() => picked.removeAt(i));
                      cubit.removeImageAt(i);
                    },
                    pickedImages: picked,
                  ),
                verticalSpace(16),

                // التصنيف الفرعي
                _OutlinedSelectorField(
                  label: 'التصنيف الفرعي',
                  hint: subCategoryName ?? 'اختر التصنيف الفرعي',
                  onTap: () async {
                    final chosen = await _showSelectSheet(
                      context: context,
                      title: 'اختر التصنيف الفرعي',
                      hint: 'ابحث اسم التصنيف...',
                      items: subCategories,
                      multi: false,
                    );
                    if (chosen == null || chosen.isEmpty) return;
                    final id = chosen.first;
                    final name = subCategories.firstWhere((e) => e['id'] == id)['name'] as String;
                    setState(() {
                      _selectedSubCategoryId = id;
                      subCategoryName = name;
                    });
                    cubit.setSubCategoryId(id);
                  },
                ),
                verticalSpace(12),

                SecondaryTextFormField(
                  label: 'عنوان الاعلان',
                  hint: 'عنوان الاعلان',
                  maxheight: 56.h,
                  minHeight: 56.h,
                  controller: _titleCtrl,
                  onChanged: cubit.setTitle,
                ),
                verticalSpace(12),

                SecondaryTextFormField(
                  label: 'وصف العرض',
                  hint: 'أكتب وصف للمنتج...',
                  maxheight: 96.w,
                  minHeight: 96.w,
                  maxLines: 4,
                  controller: _descCtrl,
                  onChanged: cubit.setDescription,
                ),
                verticalSpace(12),

                BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, locState) {
                    final isLoading = locState.regionsLoading;
                    final regionHint = _selectedRegion?.nameAr ??
                        (isLoading ? 'جاري تحميل المناطق...' : 'اختر المنطقة');
                    return _OutlinedSelectorField(
                      label: 'المنطقة',
                      hint: regionHint,
                      onTap: isLoading
                          ? null
                          : () async {
                        FocusScope.of(context).unfocus();
                        if (locState.regions.isEmpty && !locState.regionsLoading) {
                          await context.read<LocationCubit>().loadRegions();
                        }
                        final res = await _openRegionDialog(context);
                        if (res != null) {
                          setState(() {
                            _selectedRegion = res;
                            _selectedCity = null;
                          });
                          cubit.setRegionId(res.id);
                          cubit.setCityId(null);
                        }
                      },
                    );
                  },
                ),
                verticalSpace(12),

                BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, locState) {
                    final canPickCity = _selectedRegion != null;
                    final citiesLoading = locState.citiesLoading;
                    final cityHint = _selectedCity?.nameAr ??
                        (!canPickCity
                            ? 'اختر المنطقة أولًا'
                            : (citiesLoading ? 'جاري تحميل المدن...' : 'اختر المدينة'));
                    return _OutlinedSelectorField(
                      label: 'المدينة',
                      hint: cityHint,
                      onTap: !canPickCity
                          ? null
                          : () async {
                        FocusScope.of(context).unfocus();
                        await context.read<LocationCubit>().loadCities(_selectedRegion!.id);
                        final st = context.read<LocationCubit>().state;
                        if (st.cities.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('لا توجد مدن متاحة للمنطقة المحددة')),
                          );
                          return;
                        }
                        final res = await _openCityDialog(context, _selectedRegion!);
                        if (res != null) {
                          setState(() => _selectedCity = res);
                          cubit.setCityId(res.id);
                        }
                      },
                    );
                  },
                ),
                verticalSpace(12),

                SecondaryTextFormField(
                  label: 'السعر',
                  hint: '250',
                  maxheight: 56.h,
                  minHeight: 56.h,
                  isNumber: true,
                  controller: _priceCtrl,
                  onChanged: (v) => cubit.setPrice(num.tryParse(v)),
                ),
                verticalSpace(12),

                SecondaryTextFormField(
                  label: 'رقم الهاتف',
                  hint: 'مثال: 0555555555',
                  maxheight: 56.h,
                  minHeight: 56.h,
                  isPhone: true,
                  controller: _phoneCtrl,
                  onChanged: cubit.setPhone,
                ),
                verticalSpace(16),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text('التواصل', style: TextStyles.font16Black500Weight),
                ),
                verticalSpace(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _chip('محادثة', chat, (v) {
                        setState(() => chat = v);
                        _updateComms(cubit);
                      }),
                    ),
                    Expanded(
                      child: _chip('واتساب', whatsapp, (v) {
                        setState(() => whatsapp = v);
                        _updateComms(cubit);
                      }),
                    ),
                    Expanded(
                      child: _chip('جوال', phone, (v) {
                        setState(() => phone = v);
                        _updateComms(cubit);
                      }),
                    ),
                  ],
                ),
                verticalSpace(16),

                _switchTile(
                  title: 'السماح بالتعليق على الاعلان',
                  value: allowComments,
                  onChanged: (v) {
                    setState(() => allowComments = v);
                    cubit.setAllowComments(v);
                  },
                ),
                _switchTile(
                  title: 'استقبال عروض للتسويق',
                  value: allowMarketing,
                  onChanged: (v) {
                    setState(() => allowMarketing = v);
                    cubit.setAllowMarketing(v);
                  },
                ),
                verticalSpace(16),

                NextButtonBar(
                  title: _isEditing ? 'حفظ التغييرات' : 'نشر الاعلان',
                  onPressed: () {
                    final missing = <String>[];
                    if (_selectedSubCategoryId == null) missing.add('التصنيف الفرعي');
                    if (_selectedRegion == null) missing.add('المنطقة');
                    if (_selectedCity == null) missing.add('المدينة');
                    if (!_isEditing && picked.isEmpty) missing.add('صورة واحدة على الأقل');
                    if (!chat && !whatsapp && !phone) missing.add('طريقة تواصل واحدة على الأقل');

                    if (missing.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('يرجى استكمال: ${missing.join(' • ')}')),
                      );
                      return;
                    }

                    cubit.setPriceType(priceType);
                    // مزامنة أخيرة مع الكونترولرز (لو عدلها المستخدم)
                    cubit
                      ..setTitle(_titleCtrl.text)
                      ..setDescription(_descCtrl.text)
                      ..setPhone(_phoneCtrl.text)
                      ..setPrice(num.tryParse(_priceCtrl.text));
                    cubit.submit();
                  },
                ),
                verticalSpace(16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // حوار اختيار المنطقة
  Future<Region?> _openRegionDialog(BuildContext context) async {
    final locCubit = context.read<LocationCubit>();
    String query = '';

    return showModalBottomSheet<Region>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: locCubit,
          child: StatefulBuilder(
            builder: (ctx, setSheet) {
              final s = locCubit.state;
              if (s.regionsLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }
              final filtered = s.regions
                  .where((e) => e.nameAr.toLowerCase().contains(query.toLowerCase()))
                  .toList();

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    top: 8.h,
                    left: 16.w,
                    right: 16.w,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close, color: ColorsManager.black),
                          ),
                          Expanded(
                            child: Center(
                              child: Text('اختر المنطقة', style: TextStyles.font18Black500Weight),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      verticalSpace(8),
                      TextField(
                        onChanged: (q) => setSheet(() => query = q.trim()),
                        decoration: InputDecoration(
                          hintText: 'ابحث باسم المنطقة...',
                          prefixIcon: const Icon(Icons.search, color: ColorsManager.darkGray),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        ),
                      ),
                      verticalSpace(8),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final it = filtered[i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(it.nameAr),
                              trailing: const Icon(Icons.chevron_left_rounded),
                              onTap: () => Future.microtask(() => Navigator.pop(ctx, it)),
                            );
                          },
                        ),
                      ),
                      verticalSpace(12),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // حوار اختيار المدينة
  Future<City?> _openCityDialog(BuildContext context, Region region) async {
    final locCubit = context.read<LocationCubit>();
    String query = '';

    return showModalBottomSheet<City>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: locCubit,
          child: StatefulBuilder(
            builder: (ctx, setSheet) {
              final s = locCubit.state;
              if (s.citiesLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }
              final filtered = s.cities
                  .where((e) => e.nameAr.toLowerCase().contains(query.toLowerCase()))
                  .toList();

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    top: 8.h,
                    left: 16.w,
                    right: 16.w,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close, color: ColorsManager.black),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'اختر المدينة في ${region.nameAr}',
                                style: TextStyles.font18Black500Weight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      verticalSpace(8),
                      TextField(
                        onChanged: (q) => setSheet(() => query = q.trim()),
                        decoration: InputDecoration(
                          hintText: 'ابحث باسم المدينة...',
                          prefixIcon: const Icon(Icons.search, color: ColorsManager.darkGray),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        ),
                      ),
                      verticalSpace(8),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final it = filtered[i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(it.nameAr),
                              trailing: const Icon(Icons.chevron_left_rounded),
                              onTap: () => Future.microtask(() => Navigator.pop(ctx, it)),
                            );
                          },
                        ),
                      ),
                      verticalSpace(12),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // UI helpers

  Widget _chip(String label, bool selected, ValueChanged<bool> onSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 40.h,
        child: OutlinedButton(
          onPressed: () => onSelected(!selected),
          style: OutlinedButton.styleFrom(
            backgroundColor: selected ? ColorsManager.primaryColor : Colors.white,
            foregroundColor: selected ? Colors.white : Colors.black87,
            side: BorderSide(
              color: selected ? Colors.transparent : ColorsManager.dark200,
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
          ),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Transform.scale(
          scale: 0.8,
          child: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            inactiveTrackColor: ColorsManager.lightGrey,
            activeTrackColor: ColorsManager.secondary200,
            thumbColor: ColorsManager.secondary500,
          ),
        ),
        horizontalSpace(8),
        Expanded(
          child: Text(title, style: TextStyles.font14Dark500Weight),
        ),
      ],
    );
  }

  Widget _OutlinedSelectorField({
    required String label,
    required String hint,
    required VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.font12Dark500400Weight),
        SizedBox(height: 6.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 56.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: ColorsManager.dark100),
            ),
            child: Row(
              children: [
                const MySvg(image: 'arrow-left'),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyles.font14Dark400400Weight,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<Set<int>?> _showSelectSheet({
    required BuildContext context,
    required String title,
    required String hint,
    required List<Map<String, Object>> items,
    bool multi = false,
    String? multiNote,
  }) async {
    final controller = TextEditingController();
    var filtered = List<Map<String, Object>>.from(items);
    final selected = <int>{};

    return showModalBottomSheet<Set<int>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(builder: (ctx, setStateSheet) {
          void filter(String q) {
            filtered = items
                .where((e) => (e['name'] as String).toLowerCase().contains(q.toLowerCase()))
                .toList();
            setStateSheet(() {});
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 8.h,
                left: 16.w,
                right: 16.w,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: ColorsManager.black),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(title, style: TextStyles.font18Black500Weight),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  if (multiNote != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(multiNote, style: TextStyles.font12Dark500400Weight),
                    ),
                  verticalSpace(8),
                  TextField(
                    controller: controller,
                    onChanged: filter,
                    decoration: InputDecoration(
                      hintText: hint,
                      prefixIcon: const Icon(Icons.search, color: ColorsManager.darkGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    ),
                  ),
                  verticalSpace(8),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final item = filtered[i];
                        final id = item['id'] as int;
                        final name = item['name'] as String;
                        final isSelected = selected.contains(id);

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(name),
                          trailing: multi
                              ? InkWell(
                            onTap: () {
                              setStateSheet(() {
                                if (isSelected) {
                                  selected.remove(id);
                                } else {
                                  selected.add(id);
                                }
                              });
                            },
                            child: MySvg(
                              image: isSelected ? 'tick-square-check' : 'tick-square',
                            ),
                          )
                              : Radio<int>(
                            value: id,
                            groupValue: selected.isEmpty ? null : selected.first,
                            onChanged: (v) {
                              setStateSheet(() {
                                selected
                                  ..clear()
                                  ..add(id);
                              });
                            },
                          ),
                          onTap: () {
                            if (multi) {
                              setStateSheet(() {
                                if (isSelected) {
                                  selected.remove(id);
                                } else {
                                  selected.add(id);
                                }
                              });
                            } else {
                              setStateSheet(() {
                                selected
                                  ..clear()
                                  ..add(id);
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                  verticalSpace(8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, selected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: const Text('حفظ', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  verticalSpace(12),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _updateComms(OtherAdsCubit cubit) {
    final list = <String>[];
    if (chat) list.add('chat');
    if (whatsapp) list.add('whatsapp');
    if (phone) list.add('call');
    cubit.setCommunicationMethods(list);
  }
}