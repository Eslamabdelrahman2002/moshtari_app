// lib/features/real_estate_ads/ui/real_estate_auction_start_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mushtary/core/dependency_injection/injection_container.dart';
import 'package:mushtary/core/theme/colors.dart';
import 'package:mushtary/core/theme/text_styles.dart';
import 'package:mushtary/core/widgets/primary/primary_button.dart';
import 'package:mushtary/core/widgets/primary/primary_text_form_field.dart';
import 'package:mushtary/core/widgets/primary/secondary_text_form_field.dart';
import 'package:mushtary/core/widgets/primary/my_svg.dart';

import '../../../create_ad/ui/widgets/steps_header_rtl.dart';
import '../../../services/ui/widgets/map_picker_screen.dart';
import '../logic/cubit/auction_start_state.dart';
import '../logic/cubit/real_estate_auction_start_cubit.dart';
import '../widgets/auction_ui_parts.dart';
import '../widgets/real_estate_step_classify.dart';

class RealEstateAuctionStartScreen extends StatefulWidget {
  const RealEstateAuctionStartScreen({super.key});

  @override
  State<RealEstateAuctionStartScreen> createState() =>
      _RealEstateAuctionStartScreenState();
}

class _RealEstateAuctionStartScreenState
    extends State<RealEstateAuctionStartScreen> {
  final _pageController = PageController();
  final _picker = ImagePicker();

  int _step = 0;
  bool _isPickerOpen = false;
  // Step 0
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _estateType = TextEditingController();
  String _purpose = 'sell';

  // Step 1 (تفاصيل متقدمة)
  final _cityDistrict = TextEditingController();
  final _area = TextEditingController();
  final _floors = TextEditingController();
  final _rooms = TextEditingController();
  final _baths = TextEditingController();
  final _halls = TextEditingController();
  final _age = TextEditingController();
  final _descAdv = TextEditingController();
  final _license = TextEditingController();

  // حقول إضافية مطلوبة من الـ API
  final _numStreets = TextEditingController();
  final _streetWidth = TextEditingController();
  final _facade = TextEditingController();
  final List<String> _facadeOptionsAr = const ['شمال', 'جنوب', 'شرق', 'غرب'];
  final Map<String, String> _facadeCodeMap = const {
    'شمال': 'north',
    'جنوب': 'south',
    'شرق': 'east',
    'غرب': 'west',
  };

  // city_id — مؤقتًا ثابت للتجربة (اربطه لاحقًا باختيار مدينة)
  int? _cityId = 1;

  // Step 2 (تفاصيل المزاد)
  final _startPrice = TextEditingController();
  final _hiddenLimit = TextEditingController();
  final _bidStep = TextEditingController();
  final _minBid = TextEditingController();
  final _startTime = TextEditingController();
  final _endTime = TextEditingController();
  bool _autoApproval = false;
  String _type = 'single';

  bool _argsApplied = false;

  // وسائط
  File? _thumbnail;
  final List<File> _images = [];
  final List<File> _pdfs = [];

  // عناصر المزاد (متعدد)
  final List<Map<String, dynamic>> _reItems = [];

  // Counters + مفروش
  int _areaVal = 0, _floorsVal = 0, _roomsVal = 0, _bathsVal = 0, _hallsVal = 0;
  bool _isFurnished = false;

  // أنواع العقار (UI)
  final List<String> _propertyTypes = const [
    'شقة', 'فيلا', 'أرض', 'عمارة', 'استراحه', 'محل', 'مكتب', 'مستودع', 'أخرى'
  ];
  final Map<String, String> _estateTypeCodeMap = const {
    'شقة': 'apartment',
    'فيلا': 'villa',
    'أرض': 'land',
    'عمارة': 'building',
    'استراحه': 'rest_house',
    'محل': 'shop',
    'مكتب': 'office',
    'مستودع': 'warehouse',
    'أخرى': 'other',
  };
  Map<String, String> get _estateTypeCodeMapInverse =>
      _estateTypeCodeMap.map((k, v) => MapEntry(v, k));

  final Map<String, String> _ageApiMap = const {
    'أقل من سنة': 'lt-1',
    '1 - 5 سنوات': '1-5',
    '5 - 10 سنوات': '5-10',
    'أكثر من 10 سنوات': 'gt-10',
  };
  Map<String, String> get _ageApiMapInverse =>
      _ageApiMap.map((k, v) => MapEntry(v, k));

  final List<String> _ageOptions = const [
    'أقل من سنة',
    '1 - 5 سنوات',
    '5 - 10 سنوات',
    'أكثر من 10 سنوات',
  ];

  final List<String> _apiImportantKeys = const [
    'type',
    'title',
    'city_id',
    'district',
    'latitude',
    'longitude',
    'area',
    'num_streets',
    'num_floors',
    'num_rooms',
    'num_bathrooms',
    'street_width',
    'facade',
    'age',
    'license_number',
    'end_date',
  ];

  PickedLocation? _pickedLocation;
  String? _lastItemsJson;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsApplied) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['auctionType'] is String) {
      final at = args['auctionType'] as String;
      if (at == 'single' || at == 'multiple') {
        _type = at;
      }
    }
    _argsApplied = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _title.dispose();
    _desc.dispose();
    _estateType.dispose();
    _area.dispose();
    _floors.dispose();
    _rooms.dispose();
    _baths.dispose();
    _halls.dispose();
    _age.dispose();
    _descAdv.dispose();
    _license.dispose();
    _numStreets.dispose();
    _streetWidth.dispose();
    _facade.dispose();
    _cityDistrict.dispose();
    _startPrice.dispose();
    _hiddenLimit.dispose();
    _bidStep.dispose();
    _minBid.dispose();
    _startTime.dispose();
    _endTime.dispose();
    super.dispose();
  }

  // تنقّل
  void _goToStep(int i, {bool animate = true}) {
    if (i < 0 || i > 2) return;
    if (mounted) setState(() => _step = i);
    if (animate && _pageController.hasClients) {
      _pageController.animateToPage(i, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  // ========= Helpers: تاريخ/وقت =========
  Future<void> _pickDateTime(TextEditingController ctrl) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    final dt = DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0).toUtc();
    ctrl.text = dt.toIso8601String();
  }

  bool _validateTimes() {
    final endStr = _endTime.text.trim();
    final end = DateTime.tryParse(endStr);
    if (end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('صيغة تاريخ نهاية المزاد غير صحيحة')),
      );
      return false;
    }
    final startStr = _startTime.text.trim();
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

  // ========= Helpers: Debug & Validation =========
  String _prettyJson(Object data) {
    try {
      final dynamicObj = data is String ? jsonDecode(data) : data;
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(dynamicObj);
    } catch (_) {
      return data.toString();
    }
  }

  dynamic _extractJsonFromString(String raw) {
    try {
      final s = raw.trim();
      if (s.startsWith('{') || s.startsWith('[')) return jsonDecode(s);
      final i1 = s.indexOf('{');
      final i2 = s.lastIndexOf('}');
      if (i1 != -1 && i2 != -1 && i2 > i1) {
        return jsonDecode(s.substring(i1, i2 + 1));
      }
      final a1 = s.indexOf('[');
      final a2 = s.lastIndexOf(']');
      if (a1 != -1 && a2 != -1 && a2 > a1) {
        return jsonDecode(s.substring(a1, a2 + 1));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  List<String> _validateOneItem(Map<String, dynamic> it, int index) {
    final issues = <String>[];

    bool isNum(String k) {
      final v = it[k];
      if (v == null) return false;
      if (v is num) return true;
      return num.tryParse(v.toString()) != null;
    }

    for (final k in _apiImportantKeys) {
      final v = it[k];
      final s = v?.toString().trim() ?? '';

      if (['area','num_streets','num_floors','num_rooms','num_bathrooms','street_width','city_id'].contains(k)) {
        if (!isNum(k)) issues.add('item #${index + 1}: "$k" يجب أن يكون رقمًا (القيمة: $v)');
        continue;
      }

      if (k == 'latitude' || k == 'longitude') {
        if (!isNum(k)) issues.add('item #${index + 1}: "$k" يجب أن يكون رقمًا (القيمة: $v)');
        continue;
      }

      if (k == 'end_date' || k == 'start_date') {
        if (s.isEmpty || DateTime.tryParse(s) == null) {
          issues.add('item #${index + 1}: "$k" مفقود أو ليس بصيغة تاريخ صحيحة (ISO)');
        }
        continue;
      }

      if (k == 'facade') {
        final allowed = {'north','south','east','west'};
        if (s.isEmpty || !allowed.contains(s)) {
          issues.add('item #${index + 1}: "facade" غير صحيح (القيمة: $s)');
        }
        continue;
      }

      if (k == 'type') {
        if (s.isEmpty) issues.add('item #${index + 1}: "type" مفقود (ex: villa/apartment)');
        continue;
      }

      if (s.isEmpty) {
        issues.add('item #${index + 1}: "$k" مفقود');
      }
    }

    final age = (it['age'] ?? '').toString().trim();
    final allowedAges = {'lt-1','1-5','5-10','gt-10'};
    if (age.isNotEmpty && !allowedAges.contains(age)) {
      issues.add('item #${index + 1}: "age" بقيمة غير مدعومة: $age (المسموح: ${allowedAges.join(', ')})');
    }

    final lat = it['latitude'];
    final lng = it['longitude'];
    if ((lat != null && lng == null) || (lat == null && lng != null)) {
      issues.add('item #${index + 1}: يجب إرسال latitude و longitude معًا أو عدم إرسالهما نهائيًا');
    }

    return issues;
  }

  Future<bool> _debugLogBeforeSubmit(List<Map<String, dynamic>> items) async {
    debugPrint('===== DEBUG: Top-level fields =====');
    debugPrint('title            = ${_title.text.trim()}');
    debugPrint('description      = ${_desc.text.trim()}');
    debugPrint('start_price      = ${_startPrice.text.trim()}');
    debugPrint('hidden_limit     = ${_hiddenLimit.text.trim()}');
    debugPrint('bid_step         = ${_bidStep.text.trim()}');
    debugPrint('min_bid_value    = ${_minBid.text.trim().isEmpty ? _bidStep.text.trim() : _minBid.text.trim()}');
    debugPrint('auction.type     = $_type');
    debugPrint('is_auto_approval = $_autoApproval');
    debugPrint('start_time(top)  = ${_startTime.text.trim()}');
    debugPrint('end_time(top)    = ${_endTime.text.trim()}');

    debugPrint('===== DEBUG: ITEMS (sanitized) =====');
    debugPrint(_prettyJson(items));

    final issues = <String>[];
    for (var i = 0; i < items.length; i++) {
      issues.addAll(_validateOneItem(items[i], i));
    }

    if (issues.isNotEmpty) {
      debugPrint('===== DEBUG: Items validation issues (${issues.length}) =====');
      for (final s in issues) debugPrint('- $s');
      await showAuctionErrorDialog(context, message: 'تعذر الإرسال:\n• ${issues.join('\n• ')}');
      return false;
    }
    return true;
  }

  // ========= Helpers: أرقام =========
  String _toAsciiDigits(String input) {
    const eastern = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    const western = ['0','1','2','3','4','5','6','7','8','9'];
    var s = input.trim();
    for (var i = 0; i < eastern.length; i++) {
      s = s.replaceAll(eastern[i], western[i]);
    }
    s = s.replaceAll('٬', '').replaceAll(',', '');
    s = s.replaceAll('٫', '.').replaceAll('،', '.');
    s = s.replaceAll(RegExp(r'\s+'), '');
    return s;
  }

  num _parseNumSafe(String input) {
    final txt = _toAsciiDigits(input);
    return num.tryParse(txt) ?? 0;
  }

  // ========= بناء عناصر API =========
  Map<String, dynamic> _buildCurrentReItem() {
    final typeCode = _estateTypeCodeMap[_estateType.text.trim()] ?? 'other';
    final ageCode = _ageApiMap[_age.text.trim()];
    final startIso = _startTime.text.trim().isEmpty ? null : _startTime.text.trim();
    final endIso = _endTime.text.trim().isEmpty ? null : _endTime.text.trim();

    // city_id: مؤقتًا 1 للتجربة (اربطه لاحقًا)
    final cityId = _cityId;

    return {
      'type': typeCode,
      'title': _title.text.trim().isEmpty
          ? (_estateType.text.isEmpty ? 'عنصر' : _estateType.text.trim())
          : _title.text.trim(),
      'city_id': cityId,
      'district': _cityDistrict.text.trim().isEmpty ? null : _cityDistrict.text.trim(),
      'latitude': _pickedLocation?.latLng.latitude,
      'longitude': _pickedLocation?.latLng.longitude,

      'area': int.tryParse(_area.text.trim()),
      'num_streets': int.tryParse(_numStreets.text.trim()),
      'num_floors': int.tryParse(_floors.text.trim()),
      'num_rooms': int.tryParse(_rooms.text.trim()),
      'num_bathrooms': int.tryParse(_baths.text.trim()),
      'street_width': int.tryParse(_streetWidth.text.trim()),
      'facade': _facadeCodeMap[_facade.text.trim()],

      'age': ageCode,
      'is_furnished': _isFurnished,
      'description': _descAdv.text.trim().isEmpty ? null : _descAdv.text.trim(),
      'license_number': _license.text.trim().isEmpty ? null : _license.text.trim(),

      'start_date': startIso,
      'end_date': endIso,
    };
  }

  Map<String, dynamic> _sanitizeItem(Map<String, dynamic> src) {
    final out = <String, dynamic>{};
    void putNonEmpty(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      out[key] = value;
    }

    final type = (src['type'] ?? '').toString().trim();
    if (type.isNotEmpty) out['type'] = type;

    putNonEmpty('title', src['title']);

    // city_id رقم
    final cityId = src['city_id'];
    if (cityId != null) {
      final id = cityId is int ? cityId : int.tryParse(cityId.toString());
      if (id != null) out['city_id'] = id;
    }

    putNonEmpty('district', src['district']);

    final lat = src['latitude'];
    if (lat is num) out['latitude'] = lat.toDouble();
    final lng = src['longitude'];
    if (lng is num) out['longitude'] = lng.toDouble();

    for (final k in ['area','num_streets','num_floors','num_rooms','num_bathrooms','street_width']) {
      final v = src[k];
      if (v == null) continue;
      final asInt = (v is int) ? v : int.tryParse(v.toString());
      if (asInt != null) out[k] = asInt;
    }

    putNonEmpty('facade', src['facade']);
    putNonEmpty('age', src['age']);
    if (src['is_furnished'] is bool) out['is_furnished'] = src['is_furnished'];
    putNonEmpty('description', src['description']);
    putNonEmpty('license_number', src['license_number']);
    putNonEmpty('start_date', src['start_date']);
    putNonEmpty('end_date', src['end_date']);

    return out;
  }

  List<Map<String, dynamic>> _buildItemsListForSend() {
    if (_type == 'single') {
      final cleaned = _sanitizeItem(_buildCurrentReItem());
      if ((cleaned['type'] ?? '').toString().isEmpty ||
          (cleaned['end_date'] ?? '').toString().isEmpty) return [];
      return [cleaned];
    } else {
      final list = <Map<String, dynamic>>[];
      for (final it in _reItems) {
        final cleaned = _sanitizeItem(it);
        if ((cleaned['type'] ?? '').toString().isEmpty) continue;
        list.add(cleaned);
      }
      if (_estateType.text.trim().isNotEmpty) {
        final cleanedCurrent = _sanitizeItem(_buildCurrentReItem());
        if ((cleanedCurrent['type'] ?? '').toString().isNotEmpty) {
          list.add(cleanedCurrent);
        }
      }
      return list;
    }
  }

  String _buildItemsJsonForSend() => jsonEncode(_buildItemsListForSend());

  // ========= الإرسال =========
  Future<void> _onNextSubmit(BuildContext context) async {
    if (_endTime.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل تاريخ نهاية المزاد')),
      );
      return;
    }
    if (!_validateTimes()) return;

    final itemsList = _buildItemsListForSend();
    if (itemsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف عنصرًا واحدًا على الأقل وحدد نوع العقار')),
      );
      return;
    }

    // فحص محلي قبل الإرسال
    final ok = await _debugLogBeforeSubmit(itemsList);
    if (!ok) return;

    final startPriceVal = _parseNumSafe(_startPrice.text);
    final hiddenLimitVal = _parseNumSafe(_hiddenLimit.text);
    final bidStepVal = _parseNumSafe(_bidStep.text);
    final rawMinBid = _minBid.text.trim();
    final minBidVal = rawMinBid.isEmpty ? bidStepVal : _parseNumSafe(rawMinBid);

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

    final itemsJson = jsonEncode(itemsList);
    _lastItemsJson = itemsJson;
    debugPrint('===== DEBUG: items JSON string being sent =====');
    debugPrint(itemsJson);

    context.read<RealEstateAuctionStartCubit>().submit(
      title: _title.text.trim(),
      description: _desc.text.trim(),
      startPrice: startPriceVal,
      hiddenLimit: hiddenLimitVal,
      bidStep: bidStepVal,

      startTimeIso: _startTime.text.trim(),
      endTimeIso: _endTime.text.trim(),

      type: _type,
      minBidValue: minBidVal,
      isAutoApproval: _autoApproval,
      itemsJson: itemsJson,
      thumbnail: _thumbnail,
      images: _images,
      pdfs: _pdfs,
    );
  }

  // ---------- CRUD عناصر ----------
  void _addAnotherReItem() {
    if (_type != 'multiple') return;
    if (_estateType.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر نوع العقار قبل إضافة عنصر جديد')),
      );
      return;
    }
    final item = _sanitizeItem(_buildCurrentReItem());
    setState(() {
      _reItems.add(item);
      _goToStep(0);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت إضافة عنصر رقم ${_reItems.length}. املأ بيانات عنصر جديد.')),
    );
  }

  void _editReItem(int index) {
    final item = _reItems.removeAt(index);
    setState(() {
      final typeCode = (item['type'] ?? '').toString();
      _estateType.text = _estateTypeCodeMapInverse[typeCode] ?? '';
      _title.text = (item['title'] ?? _title.text).toString();

      _cityDistrict.text = (item['district'] ?? '').toString();
      _area.text = (item['area']?.toString() ?? '');
      _floors.text = (item['num_floors']?.toString() ?? '');
      _rooms.text = (item['num_rooms']?.toString() ?? '');
      _baths.text = (item['num_bathrooms']?.toString() ?? '');
      _numStreets.text = (item['num_streets']?.toString() ?? '');
      _streetWidth.text = (item['street_width']?.toString() ?? '');

      final ageCode = (item['age'] ?? '').toString();
      _age.text = _ageApiMapInverse[ageCode] ?? '';

      final facadeCode = (item['facade'] ?? '').toString();
      _facade.text = _facadeCodeMap.entries.firstWhere(
            (e) => e.value == facadeCode,
        orElse: () => const MapEntry('',''),
      ).key;

      _descAdv.text = (item['description'] ?? '').toString();
      _license.text = (item['license_number'] ?? '').toString();
      _isFurnished = (item['is_furnished'] ?? false) == true;

      _startTime.text = (item['start_date'] ?? _startTime.text).toString();
      _endTime.text = (item['end_date'] ?? _endTime.text).toString();

      _areaVal = int.tryParse(_area.text) ?? 0;
      _floorsVal = int.tryParse(_floors.text) ?? 0;
      _roomsVal = int.tryParse(_rooms.text) ?? 0;
      _bathsVal = int.tryParse(_baths.text) ?? 0;

      _goToStep(0);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحميل العنصر للتعديل (رقم ${index + 1})')),
    );
  }

  void _removeReItem(int index) {
    setState(() {
      _reItems.removeAt(index);
    });
  }

  Future<void> _addThumb() async {
    if (_isPickerOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري فتح المعرض، الرجاء الانتظار...')),
      );
      return;
    }
    setState(() => _isPickerOpen = true);
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (x != null) {
        setState(() => _thumbnail = File(x.path));
        debugPrint('Picked thumbnail -> ${_thumbnail!.path}');
      }
    } on PlatformException catch (e) {
      if (e.code == 'already_active') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('نافذة اختيار الصور مفتوحة بالفعل')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر اختيار الصورة: ${e.message ?? e.code}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر اختيار الصورة: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPickerOpen = false);
    }
  }

  Future<void> _addImages() async {
    if (_isPickerOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري فتح المعرض، الرجاء الانتظار...')),
      );
      return;
    }
    setState(() => _isPickerOpen = true);
    try {
      final xs = await _picker.pickMultiImage(imageQuality: 85);
      if (xs.isNotEmpty) {
        setState(() => _images.addAll(xs.map((e) => File(e.path))));
        debugPrint('Picked ${xs.length} images');
        for (final f in _images) debugPrint('image -> ${f.path}');
      }
    } on PlatformException catch (e) {
      if (e.code == 'already_active') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('نافذة اختيار الصور مفتوحة بالفعل')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر اختيار الصور: ${e.message ?? e.code}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر اختيار الصور: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPickerOpen = false);
    }
  }

  void _showPropertyTypeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        String? temp = _estateType.text.isEmpty ? null : _estateType.text;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setSheet) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(height: 4, width: 44, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 12),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text('نوع العقار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _propertyTypes.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final v = _propertyTypes[i];
                            return RadioListTile<String>(
                              value: v,
                              groupValue: temp,
                              onChanged: (val) => setSheet(() => temp = val),
                              title: Text(v),
                              activeColor: const Color(0xFF0A45A6),
                              visualDensity: VisualDensity.compact,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.primary400,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            setState(() => _estateType.text = temp ?? '');
                            Navigator.pop(context);
                          },
                          child: const Text('تأكيد'),
                        ),
                      ),
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

  Future<void> _openMapPicker() async {
    final res = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (res != null) {
      setState(() {
        _pickedLocation = res;
        _cityDistrict.text = res.addressAr ??
            '(${res.latLng.latitude.toStringAsFixed(5)}, ${res.latLng.longitude.toStringAsFixed(5)})';
      });
    }
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

  Widget _reItemsSummary() {
    if (_type != 'multiple' || _reItems.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('العناصر المضافة', style: TextStyles.font14Dark500Weight),
        SizedBox(height: 8.h),
        ...List.generate(_reItems.length, (i) {
          final it = _reItems[i];
          final typeCode = (it['type'] ?? '').toString();
          final typeAr = _estateTypeCodeMapInverse[typeCode] ?? typeCode;
          final sub = 'المساحة: ${it['area'] ?? '-'}م² • الطوابق: ${it['num_floors'] ?? '-'}';
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
                      Text('${(it['title'] ?? typeAr)} #${i + 1}', style: TextStyles.font14Black500Weight),
                      SizedBox(height: 4.h),
                      Text(sub, style: TextStyles.font12DarkGray400Weight),
                      if (it['district'] != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text('الحي: ${it['district']}', style: TextStyles.font12DarkGray400Weight),
                        ),
                    ],
                  ),
                ),
                IconButton(tooltip: 'تعديل', onPressed: () => _editReItem(i), icon: const Icon(Icons.edit, color: Colors.blueAccent)),
                IconButton(tooltip: 'حذف', onPressed: () => _removeReItem(i), icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
              ],
            ),
          );
        }),
        SizedBox(height: 8.h),
      ],
    );
  }

  // STEP 0
  Widget _step0() {
    return RealEstateStepClassify(
      titleCtrl: _title,
      descCtrl: _desc,
      estateTypeHint: _estateType.text,
      purposeText: _purpose == 'rent' ? 'إيجار' : 'بيع',
      onAddThumb: _addThumb,
      onAddImages: _addImages,
      onPickType: _showPropertyTypeSheet,
      onPurposeChange: (v) {
        setState(() => _purpose = v == 'إيجار' ? 'rent' : 'sell');
      },
      onNext: () {
        if (_title.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل عنوان المزاد')));
          return;
        }
        _goToStep(1);
      },
    );
  }

  // STEP 1
  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('المدينة / الحي', style: TextStyles.font14Dark500Weight),
        SizedBox(height: 6.h),
        PrimaryTextFormField(
          validationError: '',
          label: 'المدينة / الحي',
          controller: _cityDistrict,
          isReadOnly: false,
          suffixIcon: MySvg(image: 'ic_search', width: 16.w, height: 16.h),
          fillColor: Colors.white,
        ),
        SizedBox(height: 6.h),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: _openMapPicker,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MySvg(image: 'location', width: 16.w, height: 16.h),
                SizedBox(width: 6.w),
                Text('الموقع على الخريطة', style: TextStyle(color: ColorsManager.primary400, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),

        _counterWithInput(label: 'المساحة بالمتر', controller: _area, value: _areaVal, step: 10, onChanged: (v) {
          setState(() {
            _areaVal = v;
            _area.text = v.toString();
          });
        }),
        SizedBox(height: 12.h),

        _counterWithInput(label: 'عدد الشوارع', controller: _numStreets, value: int.tryParse(_numStreets.text) ?? 0, step: 1, onChanged: (v) {
          setState(() => _numStreets.text = v.toString());
        }),
        SizedBox(height: 12.h),

        _counterWithInput(label: 'عدد الطوابق', controller: _floors, value: _floorsVal, step: 1, onChanged: (v) {
          setState(() {
            _floorsVal = v;
            _floors.text = v.toString();
          });
        }),
        SizedBox(height: 12.h),

        _counterWithInput(label: 'عدد الغرف', controller: _rooms, value: _roomsVal, step: 1, onChanged: (v) {
          setState(() {
            _roomsVal = v;
            _rooms.text = v.toString();
          });
        }),
        SizedBox(height: 12.h),

        _counterWithInput(label: 'عدد الحمامات', controller: _baths, value: _bathsVal, step: 1, onChanged: (v) {
          setState(() {
            _bathsVal = v;
            _baths.text = v.toString();
          });
        }),
        SizedBox(height: 12.h),

        _counterWithInput(label: 'عرض الشارع (متر)', controller: _streetWidth, value: int.tryParse(_streetWidth.text) ?? 0, step: 1, onChanged: (v) {
          setState(() => _streetWidth.text = v.toString());
        }),
        SizedBox(height: 12.h),

        _dropdown('واجهة العقار', _facade, options: _facadeOptionsAr),
        SizedBox(height: 12.h),

        _dropdown('عمر العقار', _age, options: _ageOptions),
        SizedBox(height: 12.h),

        Text('مواصفات / وصف إضافي', style: TextStyles.font14Dark500Weight),
        SizedBox(height: 6.h),
        SecondaryTextFormField(hint: 'اكتب مواصفات / وصف إضافي', maxheight: 120, minHeight: 48, maxLines: 5, controller: _descAdv),
        SizedBox(height: 12.h),

        Text('هل العقار مفروش؟', style: TextStyles.font14Dark500Weight),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(child: PrimaryButton(text: 'لا', onPressed: () => setState(() => _isFurnished = false), backgroundColor: !_isFurnished ? ColorsManager.primary400 : Colors.white, textColor: !_isFurnished ? Colors.white : Colors.black)),
            SizedBox(width: 8.w),
            Expanded(child: PrimaryButton(text: 'نعم', onPressed: () => setState(() => _isFurnished = true), backgroundColor: _isFurnished ? ColorsManager.primary400 : Colors.white, textColor: _isFurnished ? Colors.white : Colors.black)),
          ],
        ),
        SizedBox(height: 12.h),

        Text('رخصة الإعلان العقاري (رقم ترخيص الهيئة)', style: TextStyles.font14Dark500Weight),
        SizedBox(height: 6.h),
        PrimaryTextFormField(validationError: '', hint: 'ادخل رخصة الإعلان العقاري (رقم ترخيص الهيئة)', controller: _license),
        SizedBox(height: 16.h),

        _bottomNav(onBack: () => _goToStep(0), onNext: () => _goToStep(2)),
      ],
    );
  }

  // STEP 2
  Widget _step2() {
    return BlocProvider<RealEstateAuctionStartCubit>(
      create: (context) => getIt<RealEstateAuctionStartCubit>(),
      child: BlocConsumer<RealEstateAuctionStartCubit, AuctionStartState>(
        listenWhen: (p, c) => p.submitting != c.submitting || p.success != c.success || p.error != c.error,
        listener: (context, state) async {
          if (state.success) {
            await showAuctionSuccessDialog(
              context,
              title: 'تم إنشاء المزاد بنجاح!',
              message: 'سيبدأ المزاد تلقائيًا أو وفقًا للوقت المحدد. يمكنك متابعة حالة المزاد من لوحة التحكم الخاصة بك.',
              onViewAuction: () { Navigator.pop(context); Navigator.pop(context); },
              onBackHome: () { Navigator.pop(context); Navigator.pop(context); },
            );
          } else if (state.error != null) {
            debugPrint('===== DEBUG: Server error (raw) =====');
            debugPrint(state.error);
            final serverObj = _extractJsonFromString(state.error!);
            if (serverObj != null) {
              debugPrint('===== DEBUG: Server error (JSON body) =====');
              debugPrint(_prettyJson(serverObj));
            }
            if (_lastItemsJson != null) {
              debugPrint('===== DEBUG: Last items sent =====');
              debugPrint(_prettyJson(_lastItemsJson!));
            }

            String primaryMsg = 'تعذر إنشاء المزاد';
            final details = <String>[];
            if (serverObj is Map) {
              if (serverObj['message'] != null) primaryMsg = serverObj['message'].toString();
              final errs = serverObj['errors'];
              if (errs is Map) {
                errs.forEach((k, v) {
                  if (v is List) details.add('$k: ${v.join(', ')}');
                  else if (v != null) details.add('$k: $v');
                });
              }
            } else if (state.error!.contains('العناصر غير صحيحة')) {
              primaryMsg = 'العناصر غير صحيحة';
            }

            final friendly = state.error!.contains('auth.unauthorized')
                ? 'الرجاء تسجيل الدخول أولًا أو إعادة تسجيل الدخول ثم حاول مرة أخرى.'
                : primaryMsg;

            final msgForDialog = details.isEmpty
                ? friendly
                : '$friendly\n\nالتفاصيل:\n- ${details.join('\n- ')}\n\nتم طباعة جسم الرد وبيانات العناصر في الـ Log.';

            await showAuctionErrorDialog(context, message: msgForDialog);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _priceInput('بداية المزاد', _startPrice),
              SizedBox(height: 12.h),
              _priceInput('الحد', _hiddenLimit),
              SizedBox(height: 8.h),
              _dateInput('تاريخ بداية المزاد', _startTime),
              SizedBox(height: 12.h),
              _dateInput('تاريخ نهاية المزاد', _endTime),
              SizedBox(height: 12.h),
              _priceInput('قيمة المزايدة الواحدة', _bidStep),
              SizedBox(height: 12.h),

              _reItemsSummary(),

              if (_type == 'multiple') ...[
                DashedActionBox(title: 'إضافة مزاد آخر', onTap: _addAnotherReItem),
                SizedBox(height: 12.h),
              ],

              Row(
                children: [
                  Expanded(child: Text('البيع التلقائي عند الوصول للحد أو أكثر', style: TextStyles.font14Dark500Weight)),
                  Switch(value: _autoApproval, onChanged: (v) => setState(() => _autoApproval = v), activeColor: Colors.yellow),
                ],
              ),

              _bottomNav(
                onBack: () => _goToStep(1),
                onNext: () => _onNextSubmit(context),
                nextText: 'إرسال',
                loading: state.submitting,
              ),
            ],
          );
        },
      ),
    );
  }

  // ============ Helpers UI ============
  InputDecoration _auctionFieldDecoration({required String hint, Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      prefixIcon: prefixIcon == null ? null : Padding(padding: EdgeInsetsDirectional.only(start: 8.w), child: prefixIcon),
      suffixIcon: suffixIcon == null ? null : Padding(padding: EdgeInsetsDirectional.only(end: 8.w), child: suffixIcon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: ColorsManager.dark200, width: 1)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: ColorsManager.dark200, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: ColorsManager.dark200, width: 1)),
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
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\u0660-\u0669\.\,٬٫،]'))],
          decoration: _auctionFieldDecoration(hint: label, suffixIcon: MySvg(image: 'ic_riyal', width: 18.w, height: 18.h)),
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
          decoration: _auctionFieldDecoration(hint: label, prefixIcon: const Icon(Icons.calendar_month)),
        ),
      ],
    );
  }

  Widget _dropdown(String label, TextEditingController c, {required List<String> options}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.font14Dark500Weight),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () => _openOptionsSheet(title: label, controller: c, options: options),
          child: AbsorbPointer(
            child: TextField(
              controller: c,
              readOnly: true,
              decoration: _auctionFieldDecoration(hint: label, suffixIcon: MySvg(image: 'ic_chevron_down', width: 16.w, height: 16.h)),
            ),
          ),
        ),
      ],
    );
  }

  void _openOptionsSheet({required String title, required TextEditingController controller, required List<String> options}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (context) {
        String? temp = controller.text.isEmpty ? null : controller.text;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setSheet) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(height: 4, width: 44, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 12),
                      Align(alignment: Alignment.centerRight, child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final v = options[i];
                            return RadioListTile<String>(
                              value: v,
                              groupValue: temp,
                              onChanged: (val) => setSheet(() => temp = val),
                              title: Text(v),
                              activeColor: const Color(0xFF0A45A6),
                              visualDensity: VisualDensity.compact,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.primary400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                          onPressed: () {
                            setState(() => controller.text = temp ?? '');
                            Navigator.pop(context);
                          },
                          child: const Text('تأكيد'),
                        ),
                      ),
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

  Widget _counterWithInput({
    required String label,
    required TextEditingController controller,
    required int value,
    required ValueChanged<int> onChanged,
    int step = 1,
    int min = 0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.font14Dark500Weight),
        SizedBox(height: 6.h),
        Container(
          height: 48.h,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: ColorsManager.dark200)),
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(hintText: '0', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                  onChanged: (t) => onChanged(int.tryParse(t.trim()) ?? 0),
                ),
              ),
              SizedBox(width: 8.w),
              _squareIncDec(label: '+', onTap: () {
                final cur = int.tryParse(controller.text.trim()) ?? value;
                final next = cur + step;
                controller.text = next.toString();
                onChanged(next);
              }),
              SizedBox(width: 8.w),
              _squareIncDec(label: '−', onTap: () {
                final cur = int.tryParse(controller.text.trim()) ?? value;
                final next = (cur - step) < min ? min : (cur - step);
                controller.text = next.toString();
                onChanged(next);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _squareIncDec({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: 48.w,
      height: double.infinity,
      child: Material(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Center(child: Text(label, style: TextStyle(fontSize: 18.sp, color: Colors.black87, fontWeight: FontWeight.w600))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      SingleChildScrollView(padding: EdgeInsets.all(16.w), child: _step0()),
      SingleChildScrollView(padding: EdgeInsets.all(16.w), child: _step1()),
      SingleChildScrollView(padding: EdgeInsets.all(16.w), child: _step2()),
    ];

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
              StepsHeaderRtl(labels: const ['حدد التصنيف', 'تفاصيل متقدمة', 'معلومات العرض'], current: _step, onTap: (i) => _goToStep(i)),
              const SizedBox(height: 8),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _step = i),
                  children: pages,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}