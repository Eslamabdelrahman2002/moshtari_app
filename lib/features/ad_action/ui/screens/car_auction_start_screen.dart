import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/primary_text_form_field.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

import '../../../../core/car/data/model/car_model.dart';
import '../../../../core/car/data/model/car_type.dart';
import '../../../../core/car/logic/cubit/car_catalog_cubit.dart';
import '../../../../core/car/logic/cubit/car_catalog_state.dart';
import '../../../create_ad/ui/widgets/steps_header_rtl.dart';
import '../logic/cubit/auction_start_state.dart';
import '../logic/cubit/car_auction_start_cubit.dart';
import '../widgets/auction_ui_parts.dart'; // يحتوي على DashedActionBox
import 'package:flutter/services.dart' show FilteringTextInputFormatter;

import '../widgets/car_step_classify.dart';

class CarAuctionStartScreen extends StatefulWidget {
  const CarAuctionStartScreen({super.key});

  @override
  State<CarAuctionStartScreen> createState() => _CarAuctionStartScreenState();
}

class _CarAuctionStartScreenState extends State<CarAuctionStartScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isPickerOpen = false;

  int _step = 0;
  final PageController _pageController = PageController();

  final List<String> _stepLabels = const [
    'حدد التصنيف',
    'تفاصيل متقدمة',
    'معلومات العرض',
  ];

  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _carType = TextEditingController();
  final _carModel = TextEditingController();

  CarType? _selectedBrand;
  CarModel? _selectedModel;

  final _color = TextEditingController();
  final _bodyType = TextEditingController();
  final _year = TextEditingController();
  final _mileage = TextEditingController();
  final _engineCapacity = TextEditingController();
  final _cylinders = TextEditingController();
  final _driveType = TextEditingController();
  final _descAdv = TextEditingController();

  final _startDate = TextEditingController();
  final _endDate = TextEditingController();

  final _startPrice = TextEditingController();
  final _hiddenLimit = TextEditingController();
  final _bidStep = TextEditingController();
  final _minBid = TextEditingController();

  bool _autoApproval = false;
  String _auctionType = 'single';

  File? _thumbnail;
  final List<File> _images = [];
  final List<File> _pdfs = [];

  final List<Map<String, dynamic>> _carItems = [];

  int? _editingIndex;
  bool get _isEditingItem => _editingIndex != null;

  bool _argsApplied = false;

  // NEW: هل المزاد متعدد؟
  bool get _isMultiple => _auctionType == 'multiple';

  // ===================== Helpers (Arabic normalization) =====================
  String _stripParens(String s) => s.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();

  String _engineCapacityToString(String text) {
    final s = _toAsciiDigits(text).replaceAll('+', '');
    final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(s);
    return m == null ? '' : m.group(1)!;
  }

  // ===================== Navigation =====================
  void _goToStep(int i, {bool animate = true}) {
    if (i < 0 || i > 2) return;
    if (mounted) setState(() => _step = i);
    if (animate && _pageController.hasClients) {
      _pageController.animateToPage(i, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  // ===================== Error extraction =====================
  String _extractErrorDetails(String rawError) {
    try {
      final jsonStart = rawError.indexOf("Response Text:");
      String jsonString = rawError;
      if (jsonStart != -1) {
        jsonString = rawError.substring(jsonStart + "Response Text:".length).trim();
      }
      final serverJson = jsonDecode(jsonString);
      String primaryMsg = serverJson['message']?.toString() ?? 'تعذر إنشاء المزاد';
      final details = <String>[];

      final errors = serverJson['errors'];
      if (errors is Map) {
        errors.forEach((k, v) {
          if (v is List) details.add('$k: ${v.join(', ')}');
          else if (v != null) details.add('$k: $v');
        });
      }

      if (details.isNotEmpty) {
        return '$primaryMsg:\n\nالتفاصيل:\n- ${details.join('\n- ')}';
      }
      return primaryMsg;
    } catch (_) {
      return 'تعذر إنشاء المزاد. ${rawError.contains('DioException') ? 'الرجاء التحقق من المدخلات أو الاتصال.' : rawError}';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsApplied) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['auctionType'] is String) {
      final at = args['auctionType'] as String;
      if (at == 'single' || at == 'multiple') {
        _auctionType = at;
      }
    }
    _argsApplied = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _title.dispose();
    _desc.dispose();
    _carType.dispose();
    _carModel.dispose();
    _color.dispose();
    _bodyType.dispose();
    _year.dispose();
    _mileage.dispose();
    _engineCapacity.dispose();
    _cylinders.dispose();
    _driveType.dispose();
    _descAdv.dispose();
    _startDate.dispose();
    _endDate.dispose();
    _startPrice.dispose();
    _hiddenLimit.dispose();
    _bidStep.dispose();
    _minBid.dispose();
    super.dispose();
  }

  // ===================== Pickers =====================
  Future<void> _pickThumbnail() async {
    if (_isPickerOpen) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري فتح المعرض...')));
      return;
    }
    setState(() => _isPickerOpen = true);
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (image != null) {
        setState(() => _thumbnail = File(image.path));
        debugPrint('Picked thumbnail -> ${_thumbnail!.path}');
      }
    } on PlatformException catch (e) {
      if (e.code == 'already_active') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نافذة الصور مفتوحة بالفعل')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر اختيار الصورة: ${e.message ?? e.code}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر اختيار الصورة: $e')));
    } finally {
      if (mounted) setState(() => _isPickerOpen = false);
    }
  }

  Future<void> _pickImages() async {
    if (_isPickerOpen) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري فتح المعرض...')));
      return;
    }
    setState(() => _isPickerOpen = true);
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 85);
      if (images.isNotEmpty) {
        setState(() {
          _images.addAll(images.map((x) => File(x.path)));
        });
        debugPrint('Picked ${images.length} images');
        for (final f in _images) debugPrint('image -> ${f.path}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إضافة ${images.length} صور')));
      }
    } on PlatformException catch (e) {
      if (e.code == 'already_active') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نافذة الصور مفتوحة بالفعل')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر اختيار الصور: ${e.message ?? e.code}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر اختيار الصور: $e')));
    } finally {
      if (mounted) setState(() => _isPickerOpen = false);
    }
  }

  Future<void> _pickDateTime(TextEditingController ctrl) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    final dt = DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0).toUtc();
    ctrl.text = dt.toIso8601String();
  }

  // ===================== Utils =====================
  String _toAsciiDigits(String input) {
    const eastern = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    const western = ['0','1','2','3','4','5','6','7','8','9'];
    var s = input.trim();
    for (var i = 0; i < eastern.length; i++) {
      s = s.replaceAll(eastern[i], western[i]);
    }
    s = s.replaceAll('٬', '').replaceAll(',', '').replaceAll('،', '');
    s = s.replaceAll('٫', '.');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s;
  }

  num _parseNumSafe(String input) {
    final txt = _toAsciiDigits(input).replaceAll(' ', '');
    return num.tryParse(txt) ?? 0;
  }

  int _normalizeKilometersToInt(String text) {
    final s = _toAsciiDigits(text);
    final match = RegExp(r'(\d+(?:\.\d+)?)').allMatches(s).toList();
    if (match.isEmpty) return 0;
    final first = match.first.group(1) ?? '0';
    final intPart = first.split('.').first;
    return int.tryParse(intPart) ?? 0;
  }

  double _normalizeEngineCapacityLiters(String text) {
    final s = _toAsciiDigits(text).replaceAll('+', '');
    final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(s);
    if (m == null) return 0;
    return double.tryParse(m.group(1)!) ?? 0;
  }

  bool _validateTimes() {
    final endStr = _endDate.text.trim();
    final end = DateTime.tryParse(endStr);
    if (end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('صيغة تاريخ نهاية المزاد غير صحيحة')),
      );
      return false;
    }
    final startStr = _startDate.text.trim();
    if (startStr.isNotEmpty) {
      final start = DateTime.tryParse(startStr);
      if (start == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('صيغة تاريخ بداية المزاد غير صحيحة')),
        );
        return false;
      }
      if (!end.isAfter(start)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب أن يكون تاريخ نهاية المزاد بعد تاريخ البداية')),
        );
        return false;
      }
    } else {
      if (!end.isAfter(DateTime.now().toUtc())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب أن يكون تاريخ نهاية المزاد بعد الوقت الحالي')),
        );
        return false;
      }
    }
    return true;
  }

  // ===================== Validation =====================
  bool _validateVehicleRequiredFields() {
    final missing = <String>[];

    if (_selectedBrand == null) missing.add('الماركة');
    if (_selectedModel == null) missing.add('الموديل');
    if (_year.text.trim().isEmpty) missing.add('سنة الصنع');
    if (_color.text.trim().isEmpty) missing.add('اللون');
    if (_bodyType.text.trim().isEmpty) missing.add('هيكل المركبة');
    if (_mileage.text.trim().isEmpty) missing.add('عدد الكيلومترات');
    if (_engineCapacity.text.trim().isEmpty) missing.add('سعة المحرك');
    if (_cylinders.text.trim().isEmpty) missing.add('عدد السلندرات');
    if (_driveType.text.trim().isEmpty) missing.add('نوع الدفع');
    if (_descAdv.text.trim().isEmpty) missing.add('وصف المركبة');

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('أكمل الحقول التالية: ${missing.join('، ')}')),
      );
      return false;
    }

    final invalid = <String>[];
    final y = int.tryParse(_year.text.trim()) ?? 0;
    final nowY = DateTime.now().year + 1;
    if (y < 1950 || y > nowY) invalid.add('سنة الصنع');

    final km = _normalizeKilometersToInt(_mileage.text.trim());
    if (km <= 0) invalid.add('عدد الكيلومترات');

    final liters = _normalizeEngineCapacityLiters(_engineCapacity.text.trim());
    if (liters <= 0) invalid.add('سعة المحرك');

    final cyl = int.tryParse(_cylinders.text.trim()) ?? 0;
    if (cyl <= 0) invalid.add('عدد السلندرات');

    if (invalid.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حقول غير صالحة: ${invalid.join('، ')}')),
      );
      return false;
    }

    return true;
  }

  // ===================== Building/Managing Items =====================
  Map<String, dynamic> _buildCurrentCarItem() {
    final yearVal = int.tryParse(_year.text.trim()) ?? 0;
    final kmVal = _normalizeKilometersToInt(_mileage.text.trim());
    final engineStr = _engineCapacityToString(_engineCapacity.text.trim());
    final cylindersVal = int.tryParse(_cylinders.text.trim()) ?? 0;

    final colorAr = _color.text.trim();
    final bodyAr = _bodyType.text.trim();
    final driveAr = _stripParens(_driveType.text.trim());

    return {
      if (_selectedBrand != null) 'brand_id': _selectedBrand!.id,
      if (_selectedModel != null) 'model_id': _selectedModel!.id,
      'make': _selectedBrand?.name ?? _carType.text.trim(),
      'model': _selectedModel?.displayName ?? _carModel.text.trim(),
      'year': yearVal,
      'color': colorAr,
      'body_type': bodyAr,
      'kilometers': kmVal,
      'engine_capacity': engineStr,
      'cylinders': cylindersVal,
      'drivetrain': driveAr,
      'description': _descAdv.text.trim(),
    };
  }

  Map<String, dynamic> _toApiItem(
      Map<String, dynamic> it, {
        required num startPrice,
        required num hiddenLimit,
        String? itemStartDate,
        required String itemEndDate,
      }) {
    final m = <String, dynamic>{
      'brand_id': it['brand_id']?.toString(),
      'model_id': it['model_id']?.toString(),
      'year': it['year'],
      'color': it['color'],
      'body_type': it['body_type'],
      'title': _title.text.trim(),
      'kilometers': it['kilometers'],
      'engine_capacity': it['engine_capacity']?.toString(),
      'cylinders': it['cylinders'],
      'drivetrain': it['drivetrain'],
      'specs': 'خليجي', // مؤقتًا
      'description': it['description'],
      'starting_price': startPrice,
      'hidden_min_price': hiddenLimit,
      if (itemStartDate != null && itemStartDate.trim().isNotEmpty) 'start_date': itemStartDate.trim(),
      'end_date': itemEndDate.trim(),
    };

    m.removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));
    return m;
  }

  void _clearCarItemFields() {
    _carType.clear();
    _carModel.clear();
    _selectedBrand = null;
    _selectedModel = null;
    _color.clear();
    _bodyType.clear();
    _year.clear();
    _mileage.clear();
    _engineCapacity.clear();
    _cylinders.clear();
    _driveType.clear();
    _descAdv.clear();
  }

  void _saveEditedCarItem({bool silent = false}) {
    if (_editingIndex == null) return;
    if (!_validateVehicleRequiredFields()) return;
    final updated = _buildCurrentCarItem();
    setState(() {
      _carItems[_editingIndex!] = updated;
      _editingIndex = null;
      _clearCarItemFields();
    });
    if (!silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التعديل على العنصر')),
      );
    }
  }

  // UPDATED: أضف عنصر وانتقل (أو ابق) في خطوة التفاصيل لإدخال عنصر جديد
  void _addAnotherCarItem({int navigateToStep = 1}) {
    if (_isEditingItem) {
      _saveEditedCarItem();
      setState(() => _step = navigateToStep);
      if (_pageController.hasClients) {
        _pageController.animateToPage(navigateToStep, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
      return;
    }
    if (!_validateVehicleRequiredFields()) return;

    final item = _buildCurrentCarItem();
    setState(() {
      _carItems.add(item);
      _clearCarItemFields();
      _step = navigateToStep; // ابقِ المستخدم في خطوة التفاصيل
    });

    if (_pageController.hasClients) {
      _pageController.animateToPage(navigateToStep, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت إضافة عنصر رقم ${_carItems.length}. املأ بيانات عنصر جديد.')),
    );
  }

  void _editCarItem(int index) {
    final item = _carItems[index];
    setState(() {
      _editingIndex = index;
      _carType.text = (item['make'] ?? '').toString();
      _carModel.text = (item['model'] ?? '').toString();
      _selectedBrand = null;
      _selectedModel = null;
      _year.text = (item['year']?.toString() ?? '');
      _color.text = (item['color'] ?? '').toString();
      _bodyType.text = (item['body_type'] ?? '').toString();
      _mileage.text = (item['kilometers']?.toString() ?? '');
      _engineCapacity.text = (item['engine_capacity']?.toString() ?? '');
      _cylinders.text = (item['cylinders']?.toString() ?? '');
      _driveType.text = (item['drivetrain'] ?? '').toString();
      _descAdv.text = (item['description'] ?? '').toString();
      _step = 1; // حمّل للتعديل واذهب لخطوة التفاصيل مباشرة
    });
    if (_pageController.hasClients) {
      _pageController.animateToPage(1, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحميل العنصر للتعديل (رقم ${index + 1})')),
    );
  }

  void _removeCarItem(int index) {
    setState(() {
      _carItems.removeAt(index);
      if (_editingIndex != null) {
        if (_editingIndex == index) {
          _editingIndex = null;
          _clearCarItemFields();
        } else if (_editingIndex! > index) {
          _editingIndex = _editingIndex! - 1;
        }
      }
    });
  }

  String _buildItemsJsonForSend({
    required num startPrice,
    required num hiddenLimit,
    String? itemStartDate,
    required String itemEndDate,
  }) {
    final baseList = (_auctionType == 'multiple')
        ? [
      ..._carItems,
      if (_selectedBrand != null ||
          _carType.text.trim().isNotEmpty ||
          _carModel.text.trim().isNotEmpty)
        _buildCurrentCarItem(),
    ]
        : [_buildCurrentCarItem()];

    final list = baseList
        .map((it) => _toApiItem(
      it,
      startPrice: startPrice,
      hiddenLimit: hiddenLimit,
      itemStartDate: itemStartDate,
      itemEndDate: itemEndDate,
    ))
        .toList();

    final s = jsonEncode(list);
    debugPrint('Car items JSON -> $s');
    return s;
  }

  // ===================== Dialogs: اختيار ماركة/موديل =====================
  void _showCarTypeScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return BlocProvider<CarCatalogCubit>(
          create: (_) => getIt<CarCatalogCubit>()..loadBrands(autoSelectFirst: false),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.w, right: 16.w, top: 12.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 12.h,
              ),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44, height: 4,
                        decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text('اختر الماركة', style: TextStyles.font16Black500Weight),
                    SizedBox(height: 8.h),
                    Expanded(
                      child: BlocBuilder<CarCatalogCubit, CarCatalogState>(
                        builder: (context, state) {
                          if (state.brandsLoading) {
                            return const Center(child: CircularProgressIndicator.adaptive());
                          }
                          if (state.error != null) {
                            return Center(child: Text(state.error!, style: TextStyles.font14Dark500Weight));
                          }
                          final brands = state.brands;
                          if (brands.isEmpty) {
                            return Center(child: Text('لا توجد ماركات', style: TextStyles.font14Dark500Weight));
                          }
                          return ListView.separated(
                            itemCount: brands.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final b = brands[i];
                              final selected = _selectedBrand?.id == b.id;
                              return ListTile(
                                title: Text(b.name),
                                trailing: selected ? const Icon(Icons.check, color: ColorsManager.primary400) : null,
                                onTap: () {
                                  setState(() {
                                    _selectedBrand = b;
                                    _carType.text = b.name;
                                    _selectedModel = null;
                                    _carModel.clear();
                                  });
                                  Navigator.pop(ctx);
                                  Future.delayed(const Duration(milliseconds: 150), _showCarModelScreen);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCarModelScreen() {
    if (_selectedBrand == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر النوع أولًا')));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return BlocProvider<CarCatalogCubit>(
          create: (_) => getIt<CarCatalogCubit>()..loadModels(_selectedBrand!.id, autoSelectFirst: false),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.w, right: 16.w, top: 12.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 12.h,
              ),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44, height: 4,
                        decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text('اختر الموديل', style: TextStyles.font16Black500Weight),
                    SizedBox(height: 8.h),
                    Expanded(
                      child: BlocBuilder<CarCatalogCubit, CarCatalogState>(
                        builder: (context, state) {
                          if (state.modelsLoading) {
                            return const Center(child: CircularProgressIndicator.adaptive());
                          }
                          if (state.error != null) {
                            return Center(child: Text(state.error!, style: TextStyles.font14Dark500Weight));
                          }
                          final models = state.models;
                          if (models.isEmpty) {
                            return Center(child: Text('لا توجد موديلات', style: TextStyles.font14Dark500Weight));
                          }
                          return ListView.separated(
                            itemCount: models.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final m = models[i];
                              final selected = _selectedModel?.id == m.id;
                              return ListTile(
                                title: Text(m.displayName),
                                trailing: selected ? const Icon(Icons.check, color: ColorsManager.primary400) : null,
                                onTap: () {
                                  setState(() {
                                    _selectedModel = m;
                                    _carModel.text = m.displayName;
                                  });
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===================== UI Helpers =====================
  Future<String?> showOptionsDialog(
      BuildContext context, {
        required List<String> options,
        String? selected,
      }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => OptionSelectDialog(
        options: options,
        selected: selected,
      ),
    );
  }

  InputDecoration _auctionFieldDecoration({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      prefixIcon: prefixIcon == null
          ? null
          : Padding(
        padding: EdgeInsetsDirectional.only(start: 8.w),
        child: prefixIcon,
      ),
      suffixIcon: suffixIcon == null
          ? null
          : Padding(
        padding: EdgeInsetsDirectional.only(end: 8.w),
        child: suffixIcon,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: ColorsManager.dark200, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: ColorsManager.dark200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: ColorsManager.dark200, width: 1),
      ),
    );
  }

  Widget _priceInput(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.font14Dark500Weight),
        SizedBox(height: 6.h),
        TextField(
          controller: c,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\u0660-\u0669\.\,٬٫،]')),
          ],
          decoration: _auctionFieldDecoration(
            hint: label,
            suffixIcon: MySvg(image: 'ic_riyal', width: 18.w, height: 18.h),
          ),
        ),
      ],
    );
  }

  Widget _dateInput(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.font14Dark500Weight),
        SizedBox(height: 6.h),
        TextField(
          controller: c,
          readOnly: true,
          onTap: () => _pickDateTime(c),
          decoration: _auctionFieldDecoration(
            hint: label,
            prefixIcon: const Icon(Icons.calendar_month),
          ),
        ),
      ],
    );
  }

  Widget _selectField({
    required String hint,
    required TextEditingController controller,
    required List<String> options,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6.h),
          PrimaryTextFormField(
            validationError: '',
            label: hint,
            controller: controller,
            isReadOnly: true,
            onTap: () async {
              final res = await showOptionsDialog(
                context,
                options: options,
                selected: controller.text.isEmpty ? null : controller.text,
              );
              if (res != null) {
                setState(() => controller.text = res);
              }
            },
            suffixIcon: const Icon(Icons.keyboard_arrow_down),
            fillColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _bottomNav({
    required VoidCallback onNext,
    VoidCallback? onBack,
    String nextText = 'التالي',
    bool loading = false,
  }) {
    return Row(
      children: [
        if (onBack != null)
          Expanded(
            child: PrimaryButton(
              text: 'رجوع',
              onPressed: onBack,
              backgroundColor: Colors.grey.shade200,
              textColor: Colors.black87,
            ),
          ),
        if (onBack != null) SizedBox(width: 8.w),
        Expanded(
          child: PrimaryButton(
            text: loading ? 'جارٍ الإرسال...' : nextText,
            onPressed: loading ? () {} : onNext,
          ),
        ),
      ],
    );
  }

  Widget _carItemsSummary() {
    if (!_isMultiple || _carItems.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('العناصر المضافة (${_carItems.length})', style: TextStyles.font14Dark500Weight),
        SizedBox(height: 8.h),
        ...List.generate(_carItems.length, (i) {
          final it = _carItems[i];
          final title = '${it['make'] ?? ''} ${it['model'] ?? ''}'.trim();
          final sub = 'سنة: ${it['year'] ?? '-'} • اللون: ${it['color'] ?? '-'} • الهيكل: ${it['body_type'] ?? '-'}';
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: ColorsManager.dark200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title.isEmpty ? 'عنصر #${i + 1}' : title, style: TextStyles.font14Black500Weight),
                      SizedBox(height: 4.h),
                      Text(sub, style: TextStyles.font12DarkGray400Weight),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'تعديل',
                  onPressed: () => _editCarItem(i),
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                ),
                IconButton(
                  tooltip: 'حذف',
                  onPressed: () => _removeCarItem(i),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 8.h),
      ],
    );
  }

  // NEW: كارت لإضافة عنصر جديد في وضع المزاد المتعدد
  Widget _multiAddCard() {
    if (!_isMultiple) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_carItems.isNotEmpty) ...[
          Text('العناصر المضافة: ${_carItems.length}', style: TextStyles.font12DarkGray400Weight),
          SizedBox(height: 8.h),
        ],
        DashedActionBox(
          title: 'إضافة مزاد آخر',
          onTap: () => _addAnotherCarItem(navigateToStep: 1), // البقاء في خطوة التفاصيل
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  // ===================== Steps =====================
  Widget _step0() {
    return CarStepClassify(
      titleCtrl: _title,
      descCtrl: _desc,
      typeCtrl: _carType,
      modelCtrl: _carModel,
      onAddThumb: _pickThumbnail,
      onAddImages: _pickImages,
      onPickType: _showCarTypeScreen,
      onPickModel: _showCarModelScreen,
      onNext: () {
        if (_title.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('أدخل عنوان المزاد')),
          );
          return;
        }
        _goToStep(1);
      },
    );
  }

  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _selectField(hint: 'اللون', controller: _color, options: _colorOptions),
        _selectField(hint: 'هيكل المركبة', controller: _bodyType, options: _bodyTypeOptions),
        _selectField(hint: 'سنة الصنع', controller: _year, options: _yearOptions),
        _selectField(hint: 'عدد الكيلومترات', controller: _mileage, options: _mileageOptions),
        _selectField(hint: 'سعة المحرك', controller: _engineCapacity, options: _engineCapacityOptions),
        _selectField(hint: 'عدد السلندرات', controller: _cylinders, options: _cylindersOptions),
        _selectField(hint: 'نوع الدفع', controller: _driveType, options: _driveTypeOptions),
        _area('وصف المركبة', _descAdv),
        SizedBox(height: 8.h),

        // NEW: الكارت يظهر لو مزاد متعدد
        _multiAddCard(),

        SizedBox(height: 8.h),
        _bottomNav(
          onBack: () => _goToStep(0),
          onNext: () => _goToStep(2),
        ),
      ],
    );
  }

  Widget _step2() {
    return BlocProvider<CarAuctionStartCubit>(
      create: (context) => getIt<CarAuctionStartCubit>(),
      child: BlocConsumer<CarAuctionStartCubit, AuctionStartState>(
        listenWhen: (p, c) =>
        p.submitting != c.submitting || p.success != c.success || p.error != c.error,
        listener: (context, state) async {
          if (state.success) {
            await showAuctionSuccessDialog(
              context,
              title: 'تم إنشاء المزاد بنجاح!',
              message: 'سيبدأ المزاد تلقائيًا في الوقت المحدد. يمكنك متابعة حالة المزاد من لوحة التحكم.',
              onBackHome: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            );
          } else if (state.error != null) {
            final finalMessage = _extractErrorDetails(state.error!);
            await showAuctionErrorDialog(context, message: finalMessage);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _priceInput('بداية المزاد', _startPrice),
              SizedBox(height: 12.h),
              _priceInput('الحد (غير ظاهر للمستخدم)', _hiddenLimit),
              SizedBox(height: 12.h),
              _dateInput('تاريخ بداية المزاد', _startDate),
              SizedBox(height: 12.h),
              _dateInput('تاريخ نهاية المزاد', _endDate),
              SizedBox(height: 12.h),
              _priceInput('قيمة المزايدة الواحدة', _bidStep),
              SizedBox(height: 12.h),
              _priceInput('الحد الأدنى للمزايدة', _minBid),
              SizedBox(height: 12.h),

              _carItemsSummary(),

              if (_isMultiple) ...[
                DashedActionBox(
                  title: 'إضافة مزاد آخر',
                  onTap: () => _addAnotherCarItem(navigateToStep: 1), // إبقِ المستخدم في خطوة التفاصيل
                ),
                SizedBox(height: 12.h),
              ],

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'البيع التلقائي عند الوصول للحد أو أكثر',
                      style: TextStyles.font14Dark500Weight,
                    ),
                  ),
                  Switch(
                    value: _autoApproval,
                    onChanged: (v) => setState(() => _autoApproval = v),
                    activeColor: Colors.yellow,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'الحد غير ظاهر للمستخدم داخل المزاد',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              SizedBox(height: 12.h),

              _bottomNav(
                onBack: () => _goToStep(1),
                onNext: () {
                  if (_isEditingItem) {
                    _saveEditedCarItem(silent: true);
                  }

                  if (_auctionType == 'single') {
                    if (!_validateVehicleRequiredFields()) return;
                  } else {
                    final sendingCurrentItem = _selectedBrand != null && _selectedModel != null;
                    if (_carItems.isEmpty && !sendingCurrentItem) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('الرجاء إضافة عنصر واحد على الأقل وتعبئة كامل بياناته')),
                      );
                      return;
                    }
                    if (sendingCurrentItem && !_validateVehicleRequiredFields()) return;
                  }

                  if (_endDate.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('أدخل تاريخ نهاية المزاد')),
                    );
                    return;
                  }
                  if (!_validateTimes()) return;

                  final startPriceVal = _parseNumSafe(_startPrice.text);
                  final hiddenLimitVal = _parseNumSafe(_hiddenLimit.text);
                  final bidStepVal = _parseNumSafe(_bidStep.text);
                  final rawMinBid = _minBid.text.trim();
                  final minBidVal = rawMinBid.isEmpty ? bidStepVal : _parseNumSafe(rawMinBid);

                  if (startPriceVal <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('أدخل بداية المزاد رقمًا أكبر من صفر')),
                    );
                    return;
                  }
                  if (hiddenLimitVal <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('أدخل الحد (غير الظاهر) رقمًا أكبر من صفر')),
                    );
                    return;
                  }
                  if (bidStepVal <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('أدخل قيمة المزايدة الواحدة رقمًا أكبر من صفر')),
                    );
                    return;
                  }
                  if (minBidVal <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('أدخل الحد الأدنى للمزايدة رقمًا أكبر من صفر')),
                    );
                    return;
                  }

                  final itemsJson = _buildItemsJsonForSend(
                    startPrice: startPriceVal,
                    hiddenLimit: hiddenLimitVal,
                    itemStartDate: _startDate.text.trim().isEmpty ? null : _startDate.text.trim(),
                    itemEndDate: _endDate.text.trim(),
                  );

                  // Debug
                  debugPrint('----- SENDING CAR AUCTION -----');
                  debugPrint('type=$_auctionType');
                  debugPrint('title=${_title.text.trim()}');
                  debugPrint('desc=${_desc.text.trim()}');
                  debugPrint('is_auto_approval=$_autoApproval');
                  debugPrint('start_date(top)=${_startDate.text.trim()}');
                  debugPrint('end_date(top)=${_endDate.text.trim()}');
                  debugPrint('min_bid_value=$minBidVal');
                  debugPrint('bid_step=$bidStepVal');
                  debugPrint('images_count=${_images.length}, pdfs_count=${_pdfs.length}');
                  debugPrint('thumbnail=${_thumbnail?.path}');
                  debugPrint('--------------------------------');

                  context.read<CarAuctionStartCubit>().submit(
                    type: _auctionType,
                    title: _title.text.trim(),
                    description: _desc.text.trim(),
                    isAutoApproval: _autoApproval,
                    startDateIso: _startDate.text.trim().isEmpty ? null : _startDate.text.trim(),
                    endDateIso: _endDate.text.trim(),
                    minBidValue: minBidVal,
                    bidStep: bidStepVal,
                    itemsJson: itemsJson,
                    thumbnail: _thumbnail,
                    images: _images,
                    pdfs: _pdfs,
                  );
                },
                nextText: 'إرسال',
                loading: state.submitting,
              ),
            ],
          );
        },
      ),
    );
  }

  // ===================== ثابتات الخيارات =====================
  List<String> get _yearOptions {
    final now = DateTime.now().year;
    final start = 1990;
    return List.generate(now - start + 1, (i) => (now - i).toString());
  }

  final List<String> _colorOptions = const [
    'أبيض','أسود','فضي','رمادي','أزرق','أحمر','أخضر','ذهبي','بني','بيج','أصفر','برتقالي','بنفسجي','نحاسي','نبيتي'
  ];
  final List<String> _bodyTypeOptions = const [
    'سيدان','هاتشباك','كوبيه','كشف','SUV','Crossover','بيك أب','فان','ميني فان','Wagon'
  ];
  final List<String> _mileageOptions = const [
    'أقل من 10,000 كم',
    '10,000 - 50,000 كم',
    '50,000 - 100,000 كم',
    '100,000 - 150,000 كم',
    '150,000 - 200,000 كم',
    'أكثر من 200,000 كم',
  ];
  final List<String> _engineCapacityOptions = const [
    '1.0 لتر','1.2 لتر','1.4 لتر','1.6 لتر','1.8 لتر','2.0 لتر','2.4 لتر','2.5 لتر','3.0 لتر','3.5 لتر','4.0 لتر+'
  ];
  final List<String> _cylindersOptions = const ['3','4','6','8','10','12'];

  final List<String> _driveTypeOptions = const [
    'دفع أمامي',
    'دفع خلفي',
    'دفع رباعي',
    'دفع كلي',
  ];

  // ===================== Widgets =====================
  Widget _area(String label, TextEditingController c) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyles.font14Dark500Weight),
          SizedBox(height: 6.h),
          SecondaryTextFormField(
            hint: 'اكتب $label',
            maxheight: 120,
            minHeight: 48,
            maxLines: 5,
            controller: c,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = [_step0(), _step1(), _step2()];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(onPressed:()=>Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new),color: ColorsManager.darkGray300,),
            title:  Text('إنشاء مزاد',style: TextStyles.font20Black500Weight,)),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              StepsHeaderRtl(
                labels: _stepLabels,
                current: _step,
                onTap: (i) => _goToStep(i),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _step = i),
                  children: steps
                      .map((stepWidget) =>
                      SingleChildScrollView(padding: EdgeInsets.all(16.w), child: stepWidget))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dialog اختيار خيارات بقائمة راديو (Top-level Widget)
class OptionSelectDialog extends StatefulWidget {
  final List<String> options;
  final String? selected;

  const OptionSelectDialog({
    super.key,
    required this.options,
    this.selected,
  });

  @override
  State<OptionSelectDialog> createState() => _OptionSelectDialogState();
}

class _OptionSelectDialogState extends State<OptionSelectDialog> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.6;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ColorsManager.dark200, width: 1.2),
                ),
                constraints: BoxConstraints(maxHeight: maxH),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: widget.options.length,
                  separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFEDEDED)),
                  itemBuilder: (context, i) {
                    final v = widget.options[i];
                    final selected = v == _selected;
                    return RadioListTile<String>(
                      value: v,
                      groupValue: _selected,
                      onChanged: (val) {
                        setState(() => _selected = val);
                        Navigator.pop(context, val); // اختيار فوري وإغلاق
                      },
                      title: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          v,
                          style: selected
                              ? TextStyles.font14Blue500Weight.copyWith(
                            color: ColorsManager.primary400,
                            fontWeight: FontWeight.w700,
                          )
                              : TextStyles.font14Black500Weight,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: ColorsManager.primary400,
                      visualDensity: VisualDensity.compact,
                      contentPadding:
                      const EdgeInsetsDirectional.only(start: 12, end: 8),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}